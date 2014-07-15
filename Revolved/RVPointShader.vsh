
attribute vec4 position;
attribute vec2 texCoord;
attribute float alpha;

varying vec2 texCoordVarying;
varying float alphaVarying;

uniform mat4 viewProjectionMatrix;

void main()
{
    texCoordVarying = texCoord;
    alphaVarying = alpha;
    
    gl_Position = viewProjectionMatrix * position;
}

