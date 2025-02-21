#ifndef WRAPPER_X86_128_INT16_H_
#define WRAPPER_X86_128_INT16_H_

#include <x86intrin.h>

#define LANES(V) V(0) V(1) V(2) V(3) V(4) V(5) V(6) V(7)

#define GET_LANE_16x8i(LANE) \
  static inline int16_t get_lane_16x8i##LANE(__m128i x) { \
    return (int16_t)_mm_extract_epi16(x, LANE); \
  }
LANES(GET_LANE_16x8i)
#undef GET_LANE_16x8i

#define SET_LANE_16x8i(LANE) \
  static inline __m128i set_lane_16x8i##LANE(__m128i x, int16_t y) { \
    return _mm_insert_epi16(x, y, LANE); \
  }
LANES(SET_LANE_16x8i)
#undef SET_LANE_16x8i

#undef LANES

#endif
