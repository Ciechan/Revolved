#extension GL_EXT_draw_instanced : require

attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 colorVarying;
varying vec2 texCoordVarying;

uniform mat4 viewProjectionModelMatrix;
uniform mat3 normalModelMatrix;

uniform vec2 trig[18];

void main()
{
    float c = trig[gl_InstanceIDEXT].x;
    float s = trig[gl_InstanceIDEXT].y;
    
    mat4 spanMatrix = mat4(  c, 0.0,  -s, 0.0,
                           0.0, 1.0, 0.0, 0.0,
                             s, 0.0,   c, 0.0,
                           0.0, 0.0, 0.0, 1.0);
    
    
    vec3 worldNormal = normalize(normalModelMatrix * mat3(spanMatrix) * normal);
    
    float intensity = mix(1.0, abs(worldNormal.z), 0.3);
    
    colorVarying = color * vec4(intensity, intensity, intensity, 1.0);
    texCoordVarying = texCoord;

    gl_Position = viewProjectionModelMatrix * spanMatrix * position;
}
