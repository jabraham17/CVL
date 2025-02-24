#ifndef WRAPPER_X86_256_INT16_H_
#define WRAPPER_X86_256_INT16_H_

#include <x86intrin.h>

static inline __m256i swapPairs_256epi16(__m256i x) {
  return _mm256_shuffle_epi32(x, 0b10110001);
}
static inline __m256i swapLowHigh_256epi16(__m256i x) {
  return _mm256_permute2f128_si256(x, x, 1);
}

static inline __m128i reverse_256epi16(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateLeft_256epi16(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateRight_256epi16(__m128i x) {
  return x; // TODO
}
static inline __m128i blendLowHigh_256epi16(__m128i x, __m128i y) {
  return x; // TODO
}

static inline __m256i hadd_256epi16(__m256i x, __m256i y) {
  // TODO: this is not right yet
  __m256i t0 = _mm256_hadd_epi16(x, y);
  __m256i t1 = swapLowHigh_256epi16(t0);
  return _mm256_unpacklo_epi16(t0, t1);
}

#endif
