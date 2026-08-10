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

#define SPECK    0.110
#define CLUMP    0.055
#define VIGNETTE 0.130

void main()
{
    vec2 uv = TEX0.xy;
    vec2 p = gl_FragCoord.xy;

    float fine = hash21(p) - 0.5;
    float clump = hash21(floor(p / 3.0)) - 0.5;

    vec2 c = uv * 2.0 - 1.0;
    float vig = clamp((dot(c, c) - 0.40) / 1.45, 0.0, 1.0);

    float dark  = max(0.0, -fine) * SPECK + max(0.0, -clump) * CLUMP + vig * VIGNETTE;
    float light = max(0.0, fine) * SPECK * 0.55 + max(0.0, clump) * CLUMP * 0.55;

    float net = dark - light;
    vec3 col = net >= 0.0 ? vec3(0.08, 0.07, 0.06) : vec3(1.0, 1.0, 0.98);

    FragColor = vec4(col, clamp(abs(net), 0.0, 1.0) * COL0.a);
}
#endif
