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


static inline __m128i hadd_epi32(__m128i x, __m128i y) {
  // x = a b c d
  // y = e f g h
  // t0 = a+b c+d e+f g+h
  __m128i t0 = _mm_hadd_epi32(x, y);
  // swap the center two elements
  return _mm_shuffle_epi32(t0, 0b11011000);
}

#undef LANES

#endif
