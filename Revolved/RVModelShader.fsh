
varying lowp vec4 colorVarying;
varying lowp vec2 texCoordVarying;

uniform lowp sampler2D texSampler;

void main()
{
    lowp vec4 color = texture2D(texSampler, texCoordVarying);

    gl_FragColor = colorVarying * color;
}

