
#include <fog_pars_fragment>

 varying vec2 vUv;
uniform float time;
varying vec3 sphereNormal;
varying vec3 vPos;
varying vec4 color;
varying vec3 viewDirection;

float fresnelEffect(vec3 Normal, vec3 ViewDir, float Power)
{
  float t = dot(normalize(Normal), normalize(ViewDir));
    return pow((1.0 - (t)), Power);
}

void main() {      
    float dist = length(gl_PointCoord - vec2(0.5));
    if (dist > 0.5) {
    discard;
    }


      float fresnel = fresnelEffect(sphereNormal, viewDirection, 20.0);
      vec4 fresnelColor = vec4(fresnel * 10.0, fresnel * 50.0, fresnel * 90.0, 0.0);
      //float viewDot = dot(sphereNormal, viewDirection);
      gl_FragColor = color+fresnelColor ;
     #include <fog_fragment>

    // gl_FragColor = finalColor;
}

      // #include <fog_fragment>
