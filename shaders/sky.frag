#version 460 core
#include <flutter/runtime_effect.glsl>

// The sky behind Now: a vertical gradient into the ground colour, a soft
// glow where the light is, and (at night) sparse twinkling stars.
uniform vec2 uSize;
uniform float uTime;
uniform vec4 uTop;
uniform vec4 uBottom;
uniform float uStars;
uniform vec2 uGlow;
uniform vec4 uGlowColor;
uniform vec2 uTilt;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;
  vec3 col = mix(uTop.rgb, uBottom.rgb, smoothstep(0.0, 1.0, uv.y));

  float spread = uSize.x * 0.42;
  float d = distance(frag, uGlow + uTilt * 0.4);
  // Fade the glow out before the bottom edge so the sky meets the ground
  // colour without a seam.
  float edge = 1.0 - smoothstep(0.7, 1.0, uv.y);
  col += uGlowColor.rgb * uGlowColor.a * edge * exp(-(d * d) / (2.0 * spread * spread));

  if (uStars > 0.0) {
    vec2 p = (frag + uTilt) / 30.0;
    vec2 cell = floor(p);
    vec2 f = fract(p);
    float h = hash(cell);
    if (h > 0.84) {
      vec2 pos = vec2(hash(cell + 1.3), hash(cell + 7.1)) * 0.8 + 0.1;
      float r = length(f - pos);
      float twinkle = 0.55 + 0.45 * sin(uTime * (0.5 + h * 1.2) + h * 40.0);
      float s = smoothstep(0.07, 0.0, r) * twinkle * ((h - 0.84) / 0.16 * 0.7 + 0.3);
      col += vec3(s) * uStars * (1.0 - smoothstep(0.35, 1.0, uv.y));
    }
  }
  fragColor = vec4(col, 1.0);
}
