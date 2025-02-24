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

static inline __m128i swapPairs_epi16(__m128i x) {
  __m128i mask = _mm_set_epi8(13, 12, 15, 14, 9, 8, 11, 10,
                               5, 4, 7, 6, 1, 0, 3, 2);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i swapLowHigh_epi16(__m128i x) {
  return _mm_shuffle_epi32(x, 0b01001110);
}

static inline __m128i reverse_epi16(__m128i x) {
  __m128i mask = _mm_set_epi8(1, 0, 3, 2, 5, 4, 7, 6,
                              9, 8, 11, 10, 13, 12, 15, 14);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i rotateLeft_epi16(__m128i x) {
  __m128i mask = _mm_set_epi8(1, 0, 15, 14, 13, 12, 11, 10,
                              9, 8, 7, 6, 5, 4, 3, 2);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i rotateRight_epi16(__m128i x) {
  __m128i mask = _mm_set_epi8(13, 12, 11, 10, 9, 8, 7, 6,
                               5, 4, 3, 2, 1, 0, 15, 14);
  return _mm_shuffle_epi8(x, mask);
}
static inline __m128i blendLowHigh_epi16(__m128i x, __m128i y) {
  return _mm_blend_epi32(x, y, 0b1100);
}

static inline __m128i hadd_epi16(__m128i x, __m128i y) {
  // x = a b c d e f g h
  // y = i j k l m n o p
  // t0 =
  __m128i t0 = _mm_hadd_epi16(x, y); // a+b c+d e+f g+h i+j k+l m+n o+p
  __m128i t1 = swapLowHigh_epi16(t0); // i+j k+l m+n o+p a+b c+d e+f g+h
  return _mm_unpacklo_epi16(t0, t1);
}


#undef LANES

#endif
