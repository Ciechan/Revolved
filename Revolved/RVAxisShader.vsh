
attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform mat4 viewProjectionModelMatrix;
uniform float axisAlpha;

void main()
{
    colorVarying = color;
    colorVarying.a *= axisAlpha;
    
    gl_Position = viewProjectionModelMatrix * position;
}

