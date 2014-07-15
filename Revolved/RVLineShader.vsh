
attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform mat4 viewProjectionMatrix;

void main()
{
    colorVarying = color;
    
    gl_Position = viewProjectionMatrix * position;
}

