import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";

gsap.registerPlugin(ScrollTrigger);

const SIZE = 124;
const number = SIZE * SIZE;
let geometry,
  material,
  points,
  targetRotation = 0,
  transProgress = 0,
  opacity = 0;
const canvas = document.getElementById("canvas");

window.addEventListener("scroll", () => {
  // const rect = console.log(canvas);
  // const scrollPos = window.scrollY - rect.top * window.innerHeight; // Add the viewport height to scrollPos
  // let normalizedScrollPos = scrollPos / (rect.height + window.innerHeight * 4); // Add the viewport height to the height of the canvas
  // normalizedScrollPos = Math.max(0, Math.min(1, normalizedScrollPos));
  // console.log(normalizedScrollPos);
  // targetRotation = (normalizedScrollPos * Math.PI) / 2;
});

ScrollTrigger.create({
  trigger: canvas,
  pin: true,
  end: "400%",
  markers: true,
  onUpdate: (self) => {
    const progress = self.progress;
    targetRotation = progress * (Math.PI / 2);
    transProgress = Math.min(1, progress * 2);
    opacity = Math.min(1, progress * 8);
    console.log(opacity);
    if (material) {
      material.uniforms.progress.value = transProgress;
      material.uniforms.opacity.value = opacity;
    }
  },
});

import fragment from "./shaders/fragment.glsl";
import vertex from "./shaders/vertex.glsl";

// Create a scene
const scene = new THREE.Scene();
scene.background = new THREE.Color("#000");

// Create a camera
const camera = new THREE.PerspectiveCamera(
  12.981,
  window.innerWidth / window.innerHeight,
  0.01,
  1000000);
camera.position.set(0, 0, 15);

// Create a renderer
const renderer = new THREE.WebGLRenderer({ canvas });

renderer.setSize(window.innerWidth, window.innerHeight);

// Add a spotlight
const spotLight = new THREE.SpotLight(0xffffff, 1);
spotLight.position.set(2, 2, 2);
spotLight.angle = 0.1;
spotLight.penumbra = 1;
scene.add(spotLight);

// Add particles

const getPointsOnModel = (modal) => {
  const data = modal.geometry.attributes.position.array;
  const data2 = new Float32Array(3 * SIZE * SIZE);
  const pointSizes = new Float32Array(number);
  const scaleArray = new Float32Array(number);

  for (let i = 0; i < SIZE; i++) {
    for (let j = 0; j < SIZE; j++) {
      const index = i * SIZE + j;

      data[3 * index] = data[3 * index] + Math.random() * 0.05;
      data[3 * index + 1] = data[3 * index + 1] + Math.random() * 0.05;
      data[3 * index + 2] = data[3 * index + 2] + Math.random() * 0.05;

      data2[3 * index + 0] = (Math.random() - 0.5) * 15;
      data2[3 * index + 1] = (Math.random() - 0.5) * 15;
      data2[3 * index + 2] = (Math.random() - 0.5) * 15;

      scaleArray[index] = Math.random();

    }
  }

  return { data, data2,scaleArray };
};

const loader = new GLTFLoader();
loader.load("model.glb", (gltf) => {
  const { data, data2,scaleArray } = getPointsOnModel(gltf.scene.children[0]);

  geometry = new THREE.BufferGeometry();
  geometry.setAttribute("position", new THREE.BufferAttribute(data2, 3));
  geometry.setAttribute('aScale', new THREE.BufferAttribute(scaleArray, 1));

  geometry.setAttribute("initPos", new THREE.BufferAttribute(data, 3));
  // const material = new THREE.PointsMaterial({ size: 0.05 });
  material = new THREE.ShaderMaterial({
    uniforms: {
      time: { value: 0 },
      progress: { value: 0 },
      opacity: { value: 0 },
      lightDirection: { value: new THREE.Vector3(.0, .0, -.1).normalize() },

      uPixelRatio: { value: Math.min(window.devicePixelRatio, 2) },

      ...THREE.UniformsLib['fog'],

    },
    fog:true,

    vertexShader: vertex,
    fragmentShader: fragment,
    transparent: true,
    depthWrite: true,
    // alphaTest: 0.5,
    depthTest: true,
    sizeAttenuation: true,
    blending: THREE.NoBlending,
  });

  points = new THREE.Points(geometry, material);
  points.rotation.y = -Math.PI / 2;
  scene.add(points);
});

// Add orbit controls

// const controls = new OrbitControls(camera, renderer.domElement);
// controls.enableDamping = true;
// scene.fog = new THREE.Fog( 0x000000, 5,15);

// Animation loop
function animate() {
  if (points) {
    points.rotation.y = THREE.MathUtils.lerp(
      points.rotation.y,
      targetRotation,
      0.05
    );
  }

  requestAnimationFrame(animate);
  if (material) material.uniforms.time.value += 0.01;

  // controls.update();
  renderer.render(scene, camera);
}

animate();
