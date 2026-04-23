#ifndef WRAPPER_X86_128_INT32_H_
#define WRAPPER_X86_128_INT32_H_

#include <x86intrin.h>

#define LANES(V) V(0) V(1) V(2) V(3)

#define GET_LANE_32x4i(LANE) \
  static inline int32_t get_lane_32x4i##LANE(__m128i x) { \
    return (int32_t)_mm_extract_epi32(x, LANE); \
  }
LANES(GET_LANE_32x4i)
#undef GET_LANE_32x4i

#define SET_LANE_32x4i(LANE) \
  static inline __m128i set_lane_32x4i##LANE(__m128i x, int32_t y) { \
    return _mm_insert_epi32(x, y, LANE); \
  }
LANES(SET_LANE_32x4i)
#undef SET_LANE_32x4i


static inline __m128i swapPairs_epi32(__m128i x) {
  return _mm_shuffle_epi32(x, 0b10110001);
}
static inline __m128i swapLowHigh_epi32(__m128i x) {
  return _mm_shuffle_epi32(x, 0b01001110);
}
static inline __m128i reverse_epi32(__m128i x) {
  return _mm_shuffle_epi32(x, 0b00011011);
}
static inline __m128i rotateLeft_epi32(__m128i x) {
  return _mm_shuffle_epi32(x, 0b00111001);
}
static inline __m128i rotateRight_epi32(__m128i x) {
  return _mm_shuffle_epi32(x, 0b10010011);
}
static inline __m128i blendLowHigh_epi32(__m128i x, __m128i y) {
  return _mm_blend_epi32(x, y, 0b1100);
}


static inline __m128i hadd_epi32(__m128i x, __m128i y) {
  // x = a b c d
  // y = e f g h
  // t0 = a+b c+d e+f g+h
  __m128i t0 = _mm_hadd_epi32(x, y);
  // swap the center two elements
  return _mm_shuffle_epi32(t0, 0b11011000);
}

#define SHUFFLES(IMM) \
  static inline __m128i shiftLeft128_i_##IMM##_epi32(__m128i x) { \
    return _mm_slli_epi32(x, IMM); \
  } \
  static inline __m128i shiftRight128_i_##IMM##_epi32(__m128i x) { \
    return _mm_srli_epi32(x, IMM); \
  } \
  static inline __m128i shiftRightArith128_i_##IMM##_epi32(__m128i x) { \
    return _mm_srai_epi32(x, IMM); \
  }
#define BITS(V) V(1) V(2) V(3) V(4) V(5) V(6) V(7) V(8) \
                V(9) V(10) V(11) V(12) V(13) V(14) V(15) V(16) \
                V(17) V(18) V(19) V(20) V(21) V(22) V(23) V(24) \
                V(25) V(26) V(27) V(28) V(29) V(30) V(31)
BITS(SHUFFLES)
#undef BITS
#undef SHUFFLES

#undef LANES

#endif
