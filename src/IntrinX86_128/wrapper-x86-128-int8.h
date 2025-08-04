#ifndef WRAPPER_X86_128_INT8_H_
#define WRAPPER_X86_128_INT8_H_

#include <x86intrin.h>

#define LANES(V) \
  V(0) V(1) V(2) V(3) V(4) V(5) V(6) V(7) V(8) \
  V(9) V(10) V(11) V(12) V(13) V(14) V(15)

#define GET_LANE_8x16i(LANE) \
  static inline int8_t get_lane_8x16i##LANE(__m128i x) { \
    return (int8_t)_mm_extract_epi8(x, LANE); \
  }
LANES(GET_LANE_8x16i)
#undef GET_LANE_8x16i

#define SET_LANE_8x16i(LANE) \
  static inline __m128i set_lane_8x16i##LANE(__m128i x, int8_t y) { \
    return _mm_insert_epi8(x, y, LANE); \
  }
LANES(SET_LANE_8x16i)
#undef SET_LANE_8x16i

static inline __m128i swapPairs_epi8(__m128i x) {
  __m128i mask = _mm_set_epi8(14, 15, 12, 13, 10, 11, 8, 9,
                              6, 7, 4, 5, 2, 3, 0, 1);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i swapLowHigh_epi8(__m128i x) {
  return _mm_shuffle_epi32(x, 0b01001110);
}

static inline __m128i reverse_epi8(__m128i x) {
  __m128i mask = _mm_set_epi8(0, 1, 2, 3, 4, 5, 6, 7,
                              8, 9, 10, 11, 12, 13, 14, 15);
return _mm_shuffle_epi8(x, mask);
}
static inline __m128i rotateLeft_epi8(__m128i x) {
  __m128i mask = _mm_set_epi8(0, 15, 14, 13, 12, 11, 10, 9,
                              8, 7, 6, 5, 4, 3, 2, 1);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i rotateRight_epi8(__m128i x) {
  __m128i mask = _mm_set_epi8(14, 13, 12, 11, 10, 9, 8, 7,
                               6, 5, 4, 3, 2, 1, 0, 15);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i blendLowHigh_epi8(__m128i x, __m128i y) {
  return _mm_blend_epi32(x, y, 0b1100);
}

static inline __m128i deinterleaveLower_epi8(__m128i x, __m128i y) {
  __m128i mask = _mm_set_epi8(30, 28, 26, 24, 22, 20, 18, 16,
                              14, 12, 10, 8, 6, 4, 2, 0);
  __m128i t0 = _mm_shuffle_epi8(x, mask);
  __m128i t1 = swapLowHigh_epi8(_mm_shuffle_epi8(y, mask));
  return _mm_blend_epi32(t0, t1, 0b1100);
}
static inline __m128i deinterleaveUpper_epi8(__m128i x, __m128i y) {
  __m128i mask = _mm_set_epi8(31, 29, 27, 25, 23, 21, 19, 17,
                              15, 13, 11, 9, 7, 5, 3, 1);
  __m128i t0 = _mm_shuffle_epi8(x, mask);
  __m128i t1 = swapLowHigh_epi8(_mm_shuffle_epi8(y, mask));
  return _mm_blend_epi32(t0, t1, 0b1100);
}

#undef LANES

#endif
