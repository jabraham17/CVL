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
  return x; // TODO
}
static inline __m128i swapLowHigh_epi8(__m128i x) {
  return x; // TODO
}

static inline __m128i reverse_epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateLeft_epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateRight_epi8(__m128i x) {
  return x; // TODO
}
static inline __m128i blendLowHigh_epi8(__m128i x, __m128i y) {
  return x; // TODO
}


#undef LANES

#endif
