#ifndef WRAPPER_X86_128_INT64_H_
#define WRAPPER_X86_128_INT64_H_

#include <x86intrin.h>

#define LANES(V) V(0) V(1)

#define GET_LANE_64x2i(LANE) \
  static inline int64_t get_lane_64x2i##LANE(__m128i x) { \
    return (int64_t)_mm_extract_epi64(x, LANE); \
  }
LANES(GET_LANE_64x2i)
#undef GET_LANE_64x2i

#define SET_LANE_64x2i(LANE) \
  static inline __m128i set_lane_64x2i##LANE(__m128i x, int64_t y) { \
    return _mm_insert_epi64(x, y, LANE); \
  }
LANES(SET_LANE_64x2i)
#undef SET_LANE_64x2i

static inline __m128i swapPairs_epi64(__m128i x) {
  return _mm_shuffle_epi32(x, 0b01001110);
}
static inline __m128i blendLowHigh_epi64(__m128i x, __m128i y) {
  return _mm_blend_epi32(x, y, 0b1100);
}

#undef LANES

#endif
