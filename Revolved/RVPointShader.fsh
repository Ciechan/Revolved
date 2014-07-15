
varying lowp vec2 texCoordVarying;
varying lowp float alphaVarying;

uniform lowp sampler2D texSampler;

void main()
{
    lowp vec4 color = texture2D(texSampler, texCoordVarying);
    color.a *= alphaVarying;
    
    gl_FragColor = color;
}

