 varying vec2 vUv;
uniform float time;
varying vec3 sphereNormal;
varying vec3 vPos;
varying vec4 color;
varying vec3 viewDirection;
uniform vec3 fogColor;
uniform float fogNear;
uniform float fogFar;

float fresnelEffect(vec3 Normal, vec3 ViewDir, float Power)
{
    return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void main() {      
    float dist = length(gl_PointCoord - vec2(0.5));
    if (dist > 0.5) {
    discard;
    }

    // vec4 transparentColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent color
    // vec4 finalColor = mix(color, transparentColor, 1.0 - opacity);
    
      float fresnel = fresnelEffect(sphereNormal, viewDirection, 20.0);
      vec4 fresnelColor = vec4(fresnel * 10.0, fresnel * 50.0, fresnel * 90.0, 0.0);
      //float viewDot = dot(sphereNormal, viewDirection);
      gl_FragColor = mix(vec4(fogColor, 1.0), color + fresnelColor, fogFactor);

    // gl_FragColor = finalColor;
}