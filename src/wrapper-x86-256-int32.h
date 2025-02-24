#ifndef WRAPPER_X86_256_INT32_H_
#define WRAPPER_X86_256_INT32_H_

#include <x86intrin.h>

static inline __m128i swapPairs_256epi32(__m128i x) {
  return x; // TODO
}
static inline __m128i swapLowHigh_256epi32(__m128i x) {
  return x; // TODO
}

static inline __m128i reverse_256epi32(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateLeft_256epi32(__m128i x) {
  return x; // TODO
}
static inline __m128i rotateRight_256epi32(__m128i x) {
  return x; // TODO
}
static inline __m128i blendLowHigh_256epi32(__m128i x, __m128i y) {
  return x; // TODO
}

static inline __m256i hadd_256epi32(__m256i x, __m256i y) {
  __m256i t0 = _mm256_hadd_epi32(x, y);
  return _mm256_shuffle_epi32(t0, 0b11011000);
}

#endif
