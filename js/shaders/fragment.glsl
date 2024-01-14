

varying vec2 vUv;
uniform float time;
varying vec3 sphereNormal;
varying vec3 vPos;
varying vec4 color;
varying vec3 viewDirection;
uniform float opacity;
    uniform vec3 fogColor;
    uniform float fogNear;
    uniform float fogFar;

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

      float depth = gl_FragCoord.z / gl_FragCoord.w;
      float fogFactor = smoothstep(fogNear, fogFar, depth);

      float fresnel = fresnelEffect(sphereNormal, viewDirection, 5.0);
      vec4 fresnelColor = vec4(fresnel * 10.0, fresnel * 20.0, fresnel * 20.0, 0.0);
      // This is to hide the points when we are up
      vec4 transparentColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent color

      vec4 finalColor = mix(color, transparentColor, 1.0 - opacity);


       gl_FragColor = mix(vec4(fogColor, 1.0), finalColor , fogFactor);
      
          //    gl_FragColor = mix( finalColor, vec4(fogColor, 1.0), fogFactor );

    // gl_FragColor = finalColor;
}

      // #include <fog_fragment>
