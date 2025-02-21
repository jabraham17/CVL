#ifndef WRAPPER_X86_128_REAL32_H_
#define WRAPPER_X86_128_REAL32_H_

#include <x86intrin.h>

#define LANES(V) V(0) V(1) V(2) V(3)

#define GET_LANE_32x4r(LANE) \
  static inline float get_lane_32x4r##LANE(__m128 x) { \
    union { int i; float f; } temp; \
    temp.i = _mm_extract_ps(x, LANE); \
    return temp.f; \
  }
LANES(GET_LANE_32x4r)
#undef GET_LANE_32x4r

// 0b00+LANE+0000
#define SET_LANE_32x4r(LANE) \
  static inline __m128 set_lane_32x4r##LANE(__m128 x, float y) { \
    __m128 temp = _mm_set_ss(y); \
    return _mm_insert_ps(x, temp, LANE<<16); \
  }
LANES(SET_LANE_32x4r)
#undef SET_LANE_32x4r


static inline __m128 swapPairs_ps(__m128 x) {
  return _mm_shuffle_ps(x, x, 0b10110001);
}
static inline __m128 swapLowHigh_ps(__m128 x) {
  return _mm_shuffle_ps(x, x, 0b01001110);
}
static inline __m128 reverse_ps(__m128 x) {
  return _mm_shuffle_ps(x, x, 0b00011011);
}
static inline __m128 rotateLeft_ps(__m128 x) {
  return _mm_shuffle_ps(x, x, 0b00111001);
}
static inline __m128 rotateRight_ps(__m128 x) {
  return _mm_shuffle_ps(x, x, 0b10010011);
}
static inline __m128 blendLowHigh_ps(__m128 x, __m128 y) {
  return _mm_blend_ps(x, y, 0b1100);
}

static inline __m128 haddps(__m128 x, __m128 y) {
  __m128 t0 = _mm_hadd_ps(x, y);
  return _mm_shuffle_ps(t0, t0, 0b11011000);
}

#undef LANES

#endif
