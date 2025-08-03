#ifndef WRAPPER_X86_256_INT8_H_
#define WRAPPER_X86_256_INT8_H_

#include <x86intrin.h>

static inline __m256i swapPairs_256epi8(__m256i x) {
  const __m256i mask = _mm256_set_epi8(
    30, 31, 28, 29, 26, 27, 24, 25,
    22, 23, 20, 21, 18, 19, 16, 17,
    14, 15, 12, 13, 10, 11, 8, 9,
    6, 7, 4, 5, 2, 3, 0, 1
  );
  return _mm256_shuffle_epi8(x, mask);
}
static inline __m256i swapLowHigh_256epi8(__m256i x) {
  return _mm256_permute2f128_si256(x, x, 1);
}

static inline __m256i reverse_256epi8(__m256i x) {
  return x; // TODO
}
static inline __m256i rotateLeft_256epi8(__m256i x) {
  return x; // TODO
}
static inline __m256i rotateRight_256epi8(__m256i x) {
  return x; // TODO
}
static inline __m256i blendLowHigh_256epi8(__m256i x, __m256i y) {
  return _mm256_blend_epi32(x, y, 0xf0);
}


static inline __m256i interleaveLower_256epi8(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi8(x, y);
  __m256i t1 = _mm256_unpackhi_epi8(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x20);
}
static inline __m256i interleaveUpper_256epi8(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi8(x, y);
  __m256i t1 = _mm256_unpackhi_epi8(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x31);
}

#endif
