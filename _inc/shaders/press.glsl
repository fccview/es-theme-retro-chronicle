#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform mat4 MVPMatrix;
COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec4 COL0;

float hash21(vec2 p)
{
    p = fract(p * vec2(443.897, 441.423));
    p += dot(p, p.yx + 19.19);
    return fract((p.x + p.y) * p.x);
}

#define INK      0.240
#define PITCH    3.400
#define BLEED    0.070
#define MISREG   0.400
#define VIGNETTE 0.150
#define DRIFT    5.200
#define PULSE    0.180
#define ROLL     0.110
#define SLUR     0.550
#define SPRAY    0.090

float screenDot(vec2 p, float ang, float pitch)
{
    float s = sin(ang);
    float c = cos(ang);
    vec2 r = vec2(p.x * c - p.y * s, p.x * s + p.y * c) / pitch;
    vec2 f = fract(r) - 0.5;
    return smoothstep(0.36, 0.24, length(f));
}

void main()
{
    vec2 uv = TEX0.xy;
    vec2 p = gl_FragCoord.xy;
    float t = float(FrameCount);

    vec2 driftK = vec2(sin(t * 0.0104), cos(t * 0.0081)) * DRIFT;
    vec2 driftM = vec2(cos(t * 0.0067), sin(t * 0.0092)) * DRIFT * 0.85;

    float roll = fract(uv.y * 0.85 - t * 0.0026);
    float band = smoothstep(0.30, 0.0, abs(roll - 0.5));
    float slur = band * SLUR;

    float k = screenDot(p + driftK + vec2(slur * 2.0, 0.0), 0.7853982, PITCH);
    float m = screenDot(p + driftM + vec2(1.0 - slur * 2.4, 0.0), 0.2617994, PITCH * 1.06);

    float fibre = hash21(floor((p + vec2(0.0, t * 1.3)) * 0.5)) - 0.5;
    float spray = hash21(p + vec2(t * 3.1, t * 1.7)) - 0.5;

    vec2 c = uv * 2.0 - 1.0;
    float vig = clamp((dot(c, c) - 0.35) / 1.40, 0.0, 1.0);

    float weight = 1.0 + sin(t * 0.0212) * PULSE + band * ROLL * 2.0;

    float ink = (k * INK + m * INK * MISREG) * weight
              + max(0.0, -fibre) * BLEED + vig * VIGNETTE + band * ROLL
              + max(0.0, -spray) * SPRAY;
    float paper = max(0.0, fibre) * BLEED * 0.8 + max(0.0, spray) * SPRAY * 0.7;

    float net = ink - paper;
    vec3 col = net >= 0.0 ? vec3(0.06, 0.05, 0.05) : vec3(1.0, 0.99, 0.96);

    FragColor = vec4(col, clamp(abs(net), 0.0, 1.0) * COL0.a);
}
#endif
