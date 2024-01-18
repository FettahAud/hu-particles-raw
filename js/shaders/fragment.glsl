

varying vec2 vUv;
uniform float time;
varying vec3 sphereNormalF;
varying vec3 vPos;
varying vec4 color;
varying vec3 viewDirection;
uniform float opacity;
    uniform vec3 fogColor;
    uniform float fogNear;
    uniform float fogFar;
varying vec3 vViewPosition;

float fresnelEffect(vec3 Normal, vec3 ViewDir, float Power)
    {
        return pow((1.0 - (dot(normalize(Normal), normalize(ViewDir)))), Power);
    }

void main() {      

    float dist = length(gl_PointCoord - vec2(0.5));
    if (dist > 0.5) {
    discard;
    }

      float depth = gl_FragCoord.z / gl_FragCoord.w;
      float fogFactor = smoothstep(fogNear, fogFar, depth);


    vec3 normal = normalize(cross(dFdx(vViewPosition), dFdy(vViewPosition)));
    float specularStrength = 14.0; // Adjust the strength of the reflection

    vec3 reflected = reflect(viewDirection, sphereNormalF);
    float specular = pow(max(dot(reflected, normalize(cameraPosition - vViewPosition)), 0.0), 16.0);



      float fresnel = fresnelEffect(sphereNormalF, viewDirection, 20.0);
      vec4 fresnelColor = vec4(fresnel * 10.0, fresnel * 50.0, fresnel * 90.0, 0.0);
      // This is to hide the points when we are up
      vec4 transparentColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent color

      vec4 finalColor = mix(color, transparentColor, 1.0 - opacity);

        vec4 shine = vec4(vec3(specularStrength) * specular * .5,.5);
       gl_FragColor = mix(vec4(fogColor, 1.0), finalColor+shine , fogFactor);


    // gl_FragColor = finalColor;
}

      // #include <fog_fragment>
