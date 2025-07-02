#ifndef WRAPPER_X86_256_INT64_H_
#define WRAPPER_X86_256_INT64_H_

#include <x86intrin.h>

static inline __m256i swapPairs_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0xB1);
}
static inline __m256i swapLowHigh_256epi64(__m256i x) {
  return _mm256_permute2f128_si256(x, x, 1);
}

static inline __m256i reverse_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0x1B);
}
static inline __m256i rotateLeft_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0x39);
}
static inline __m256i rotateRight_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0x93);
}

static inline __m256i blendLowHigh_256epi64(__m256i x, __m256i y) {
  return _mm256_blend_epi32(x, y, 0xf0);
}

static inline __m256i interleaveLower_256epi64(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi64(x, y);
  __m256i t1 = _mm256_unpackhi_epi64(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x20);
}
static inline __m256i interleaveUpper_256epi64(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi64(x, y);
  __m256i t1 = _mm256_unpackhi_epi64(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x31);
}

#endif
