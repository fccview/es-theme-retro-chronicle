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

#define TAPE     0.070
#define TRACK    0.520
#define CHROMA   0.230
#define HEAD     0.620
#define WOBBLE   0.055

void main()
{
    vec2 uv = TEX0.xy;
    float t = float(FrameCount);

    float line = floor(gl_FragCoord.y);
    float cell = floor(gl_FragCoord.x / 3.0);

    float smear = hash21(vec2(cell, line) + vec2(t * 0.021, t * 0.013));
    float lineJitter = hash21(vec2(line, floor(t * 0.25))) - 0.5;

    float trackPos = fract(uv.y * 0.65 - t * 0.0016);
    float track = smoothstep(0.055, 0.0, abs(trackPos - 0.5)) * TRACK;
    float trackNoise = step(0.62, hash21(vec2(cell, line) + t * 0.37)) * track;

    float head = smoothstep(0.965, 0.999, uv.y);
    float headNoise = step(0.42, hash21(vec2(cell * 1.7, line) + t * 0.91)) * head * HEAD;
    float headShift = head * (hash21(vec2(line, floor(t * 0.5))) - 0.5) * 2.0;

    float wob = sin(uv.y * 74.0 + t * 0.11) * WOBBLE;

    float chromaLine = mod(floor(gl_FragCoord.y / 2.0), 2.0);
    vec3 chroma = mix(vec3(0.20, 0.95, 1.00), vec3(1.00, 0.25, 0.80), chromaLine);
    float fringe = max(0.0, smear - 0.72) * CHROMA * 3.4;
    fringe += track * 0.35;

    float dark  = max(0.0, 0.5 - smear) * TAPE * 2.0 + max(0.0, -wob);
    float light = trackNoise + headNoise + max(0.0, smear - 0.5) * TAPE * 1.4
                + max(0.0, wob) + abs(headShift) * 0.30 + abs(lineJitter) * 0.012;

    float net = light - dark;
    float a = clamp(abs(net) + fringe, 0.0, 1.0);

    vec3 col = net >= 0.0 ? vec3(0.94, 0.95, 1.00) : vec3(0.02, 0.02, 0.05);
    col = mix(col, chroma, clamp(fringe * 1.6, 0.0, 0.85));

    FragColor = vec4(col, a * COL0.a);
}
#endif
