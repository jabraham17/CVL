#ifndef WRAPPER_X86_128_REAL64_H_
#define WRAPPER_X86_128_REAL64_H_

#include <x86intrin.h>

static inline double get_lane_64x2r0(__m128d x) {
  return _mm_cvtsd_f64(x);
}
static inline double get_lane_64x2r1(__m128d x) {
  __m128d temp = _mm_unpackhi_pd(x, x);
  return _mm_cvtsd_f64(temp);
}

static inline __m128d set_lane_64x2r0(__m128d x, double y) {
  __m128d temp = _mm_set_sd(y);
  return _mm_unpacklo_pd(temp, x);
}
static inline __m128d set_lane_64x2r1(__m128d x, double y) {
  __m128d temp = _mm_set_sd(y);
  return _mm_shuffle_pd(x, temp, 0);
}

static inline __m128d swapPairs_pd(__m128d x) {
  return _mm_shuffle_pd(x, x, 1);
}
static inline __m128d blendLowHigh_pd(__m128d x, __m128d y) {
  return _mm_blend_pd(x, y, 0b10);
}

#endif
