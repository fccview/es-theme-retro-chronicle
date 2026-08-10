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

#define SCAN     0.170
#define SLOT     0.055
#define VIGNETTE 0.320
#define GRAIN    0.055
#define ROLL     0.045
#define FLICKER  0.011
#define WARMTH   0.550

void main()
{
    vec2 uv  = TEX0.xy;
    float t  = float(FrameCount);

    float pitch = max(2.0, floor(OutputSize.y / 320.0));
    float scan  = 0.5 - 0.5 * cos(gl_FragCoord.y * 6.2831853 / pitch);

    float slot = 0.5 - 0.5 * cos(gl_FragCoord.x * 2.0943951);

    vec2 c = uv * 2.0 - 1.0;
    float vig = clamp((dot(c, c) - 0.30) / 1.35, 0.0, 1.0);
    vig *= vig;

    float g = hash21(gl_FragCoord.xy + vec2(t * 0.7311, t * 0.5177)) - 0.5;

    float bar = pow(fract(uv.y * 0.5 + t * ROLL * 0.004), 24.0);

    float fl = sin(t * 0.62) * 0.5 + sin(t * 1.71) * 0.5;

    float dark  = scan * SCAN + slot * SLOT + vig * VIGNETTE
                + max(0.0, -g) * GRAIN * 2.0
                + max(0.0, -fl) * FLICKER;
    float light = bar * ROLL
                + max(0.0, g) * GRAIN * 2.0
                + max(0.0, fl) * FLICKER;

    float net = dark - light;
    vec3  col = net >= 0.0 ? vec3(0.015, 0.012, 0.020)
                           : vec3(1.0, 1.0 - WARMTH * 0.10, 1.0 - WARMTH * 0.22);

    FragColor = vec4(col, clamp(abs(net), 0.0, 1.0) * COL0.a);
}
#endif
