#ifndef WRAPPER_X86_256_REAL32_H_
#define WRAPPER_X86_256_REAL32_H_

#include <x86intrin.h>

static inline __m128 extract128x2f0(__m256 x) {
  return _mm256_extractf128_ps(x, 0);
}
static inline __m128 extract128x2f1(__m256 x) {
  return _mm256_extractf128_ps(x, 1);
}

static inline __m256 insert128x2f0(__m256 x, __m128 y) {
  return _mm256_insertf128_ps(x, y, 0);
}
static inline __m256 insert128x2f1(__m256 x, __m128 y) {
  return _mm256_insertf128_ps(x, y, 1);
}

static inline __m256 swapPairs_256ps(__m256 x) {
  return _mm256_permute_ps(x, 0xb1);
}
static inline __m256 swapLowHigh_256ps(__m256 x) {
  return _mm256_permute2f128_ps(x, x, 1);
}
static inline __m256 reverse_256ps(__m256 x) {
  __m256i mask = _mm256_set_epi32(0, 1, 2, 3, 4, 5, 6, 7);
  return _mm256_permutevar8x32_ps(x, mask);
}
static inline __m256 rotateLeft_256ps(__m256 x) {
  __m256i mask = _mm256_set_epi32(0, 7, 6, 5, 4, 3, 2, 1);
  return _mm256_permutevar8x32_ps(x, mask);
}
static inline __m256 rotateRight_256ps(__m256 x) {
  __m256i mask = _mm256_set_epi32(6, 5, 4, 3, 2, 1, 0, 7);
  return _mm256_permutevar8x32_ps(x, mask);
}
static inline __m256 interleaveLower_256ps(__m256 x, __m256 y) {
  __m256 t0 = _mm256_unpacklo_ps(x, y);
  __m256 t1 = _mm256_unpackhi_ps(x, y);
  return _mm256_permute2f128_ps(t0, t1, 0x20);
}
static inline __m256 interleaveUpper_256ps(__m256 x, __m256 y) {
  __m256 t0 = _mm256_unpacklo_ps(x, y);
  __m256 t1 = _mm256_unpackhi_ps(x, y);
  return _mm256_permute2f128_ps(t0, t1, 0x31);
}
static inline __m256 deinterleaveLower_256ps(__m256 x, __m256 y) {
  __m256i mask = _mm256_set_epi32(14, 12, 10, 8, 6, 4, 2, 0);
  __m256 t0 = _mm256_permutevar8x32_ps(x, mask);
  __m256 t1 = _mm256_permutevar8x32_ps(y, mask);
  return _mm256_blend_ps(t0, t1, 0xF0);
}
static inline __m256 deinterleaveUpper_256ps(__m256 x, __m256 y) {
  __m256i mask = _mm256_set_epi32(15, 13, 11, 9, 7, 5, 3, 1);
  __m256 t0 = _mm256_permutevar8x32_ps(x, mask);
  __m256 t1 = _mm256_permutevar8x32_ps(y, mask);
  return _mm256_blend_ps(t0, t1, 0xF0);
}
static inline __m256 blendLowHigh_256ps(__m256 x, __m256 y) {
  return _mm256_blend_ps(x, y, 0xf0);
}

static inline __m256 hadd256ps(__m256 x, __m256 y) {
  __m256 t0 = _mm256_hadd_ps(x, y);
  return _mm256_permute_ps(t0, 0b11011000);
}


#endif
