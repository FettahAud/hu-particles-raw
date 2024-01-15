
attribute vec3 initPos;
uniform float time;
uniform float progress;
uniform float opacity;
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPos;
varying vec4 color;
uniform vec3 lightDirection;
varying vec3 viewDirection;
varying vec3 sphereNormal;
varying vec3 sphereNormalF;

attribute float aScale;
uniform float uPixelRatio;

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
// Helper functions for permutation and fade
vec4 permute(vec4 x) {
    return mod(((x * 34.0) + 1.0) * x, 289.0);
}

vec3 fade(vec3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}
    float random (vec2 st) {
    return fract(sin(dot(st.xy,
                        vec2(12.9898,78.233)))*
        43758.5453123);
}


float classicPerlinNoise(vec3 P) {
// Hash function
vec3 Pi0 = floor(P); // Integer part for indexing
vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
Pi0 = mod(Pi0, 289.0);
Pi1 = mod(Pi1, 289.0);
vec3 Pf0 = fract(P); // Fractional part for interpolation
vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
vec4 iy = vec4(Pi0.yy, Pi1.yy);
vec4 iz0 = Pi0.zzzz;
vec4 iz1 = Pi1.zzzz;

vec4 ixy = permute(permute(ix) + iy);
vec4 ixy0 = permute(ixy + iz0);
vec4 ixy1 = permute(ixy + iz1);

vec4 gx0 = ixy0 * (1.0 / 7.0);
vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
gx0 = fract(gx0);
vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
vec4 sz0 = step(gz0, vec4(0.0));
gx0 -= sz0 * (step(0.0, gx0) - 0.5);
gy0 -= sz0 * (step(0.0, gy0) - 0.5);

vec4 gx1 = ixy1 * (1.0 / 7.0);
vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
gx1 = fract(gx1);
vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
vec4 sz1 = step(gz1, vec4(0.0));
gx1 -= sz1 * (step(0.0, gx1) - 0.5);
gy1 -= sz1 * (step(0.0, gy1) - 0.5);

vec3 g000 = vec3(gx0.x, gy0.x, gz0.x);
vec3 g100 = vec3(gx0.y, gy0.y, gz0.y);
vec3 g010 = vec3(gx0.z, gy0.z, gz0.z);
vec3 g110 = vec3(gx0.w, gy0.w, gz0.w);
vec3 g001 = vec3(gx1.x, gy1.x, gz1.x);
vec3 g101 = vec3(gx1.y, gy1.y, gz1.y);
vec3 g011 = vec3(gx1.z, gy1.z, gz1.z);
vec3 g111 = vec3(gx1.w, gy1.w, gz1.w);

vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
g000 *= norm0.x;
g010 *= norm0.y;
g100 *= norm0.z;
g110 *= norm0.w;
vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
g001 *= norm1.x;
g011 *= norm1.y;
g101 *= norm1.z;
g111 *= norm1.w;

float n000 = dot(g000, Pf0);
float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
float n111 = dot(g111, Pf1);

vec3 fade_xyz = fade(Pf0);
vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
return 2.2 * n_xyz;
}

float atan2(in float y, in float x) {
    return acos(x) * sign(y);
}

float lerp(float a, float b, float t) {
    return a * (1.0 - t) + b * t;
}

float random(float seed) {
    return random(vec2(seed));
}

float sampleColor(float time, vec3 position, float pointsCount) {
    float ftime = floor(time);
    float maxDistance = (0.5 - abs(time - ftime - 0.5)) * 0.25;
    vec3 normalizedPosition = normalize(position);

    for (float i = 0.0; i < pointsCount; i += 1.0) {
    vec3 vector = normalize(vec3(random(ftime + i * 3.0) - 0.5, random(ftime + i * 3.0 + 1.0) - 0.5, random(ftime + i * 3.0 + 2.0) - 0.5));
    float currentDistance = distance(normalizedPosition, vector);
    if (currentDistance < maxDistance)
        return 1.0;
    }

    return 0.0;
}

void main() {
    #include <begin_vertex>
    #include <project_vertex>

    float speed = 1.;
    float strengthL0 = 0.5;
    float posStrength = 0.7;
    vUv = uv;

    vec3 pos1 = position;
    vec3 pos2 = initPos;
    vec3 pos = mix(pos1, pos2, progress);
    sphereNormal = normalize(pos);

    sphereNormalF=normalize(pos1);

    vec3 lightColor = vec3(1.0, 1.0, 1.0);
    float nDotL = clamp(dot(lightDirection, sphereNormal), 0.0, 1.0);
    vec4 diffuseColor = vec4(lightColor, 1.0) * vec4(vec3(1.,0.,0.), 1.0) * nDotL;

    float noiseValue1 = classicPerlinNoise(pos1 + vec3(time * 0.25));
    float noiseValue2 = classicPerlinNoise(pos2 + vec3(time * 0.25));
    float noiseValue = mix(noiseValue1, noiseValue2, posStrength);


    vec2 direction = vec2(pos.x, pos.z);
    float lengthF = sqrt(direction.x * direction.x + direction.y * direction.y);
    direction /= vec2(lengthF);
    float angle = atan2(direction.y, direction.x);

    float noiseL0 = (sin(angle * 10.0 - pos.y * 2.5) + 1.0) / 2.0 * strengthL0;
    float noiseL1 = (sin(angle * 5. + time * speed) + 1.0) / 2.0;
    float noiseL2 = (sin(pos.y * 1.0 + time) + 1.0) / 2.0;

    float noiseL3 = (sin(angle * 10. - pos.y * 2.5 + 1.0) + 1.0) / 2.0 * strengthL0;
    float noiseL4 = (sin(angle * 5. + time * speed + 1.0) + 1.0) / 2.0;
    float noiseL5 = (sin(pos.y * 1.0 + time + 1.0) + 1.0) / 2.0;
    float noise = (noiseL0 * noiseL1 * noiseL2 + noiseL3 * noiseL4 * noiseL5) * (1.0 - abs(dot(sphereNormal, vec3(0.0, 1.0, 0.0))));
    vec2 verticalWave = vec2(noise) * direction*2.;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos.x - verticalWave.x, pos.y, pos.z - verticalWave.y, 1.0);
    vec3 newPosition = position;
    vec4 modelPosition = vec4(newPosition, 1.0);

    vec4 viewPosition = viewMatrix * modelPosition;
    gl_PointSize = 144. * aScale * uPixelRatio;
    gl_PointSize *= 0.025;
    // gl_PointSize = max(random(pos.yx), 0.5) * 7.71;

    vec4 localPosition = vec4(position, 1.0);
    vec4 worldPosition = modelMatrix * localPosition;
    vec3 look = normalize(vec3(cameraPosition) - vec3(worldPosition));
    viewDirection = look;

    vec4 noiseColorModifier = vec4(1.0 - noise);
    vec4 color1 = vec4(0.0, 1.0, 1.0, .7); // cyan
    vec4 color2 = vec4(0.5, 0.5, 0.5, .5); // gray

    color = mix(color1, color2, 1.0 - pow(min(abs(noiseValue * 2.5), 1.), 10.));    


}
