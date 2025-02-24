#ifndef WRAPPER_X86_256_REAL64_H_
#define WRAPPER_X86_256_REAL64_H_

#include <x86intrin.h>

static inline __m128d extract128x2d0(__m256d x) {
  return _mm256_extractf128_pd(x, 0);
}
static inline __m128d extract128x2d1(__m256d x) {
  return _mm256_extractf128_pd(x, 1);
}

static inline __m256d insert128x2d0(__m256d x, __m128d y) {
  return _mm256_insertf128_pd(x, y, 0);
}
static inline __m256d insert128x2d1(__m256d x, __m128d y) {
  return _mm256_insertf128_pd(x, y, 1);
}

static inline __m256d swapPairs_256pd(__m256d x) {
  return _mm256_permute4x64_pd(x, 0xB1);
}
static inline __m256d swapLowHigh_256pd(__m256d x) {
  return _mm256_permute4x64_pd(x, 0x4E);
}
static inline __m256d reverse_256pd(__m256d x) {
  return _mm256_permute4x64_pd(x, 0x1B);
}
static inline __m256d rotateLeft_256pd(__m256d x) {
  return _mm256_permute4x64_pd(x, 0x39);
}
static inline __m256d rotateRight_256pd(__m256d x) {
  return _mm256_permute4x64_pd(x, 0x93);
}
static inline __m256d interleaveLower_256pd(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpacklo_pd(x, y);
  __m256d t1 = _mm256_unpackhi_pd(x, y);
  return _mm256_permute2f128_pd(t0, t1, 0x20);
}
static inline __m256d interleaveUpper_256pd(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpacklo_pd(x, y);
  __m256d t1 = _mm256_unpackhi_pd(x, y);
  return _mm256_permute2f128_pd(t0, t1, 0x31);
}
static inline __m256d deinterleaveLower_256pd(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpacklo_pd(x, y);
  return _mm256_permute4x64_pd(t0, 0b11011000);
}
static inline __m256d deinterleaveUpper_256pd(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpackhi_pd(x, y);
  return _mm256_permute4x64_pd(t0, 0b11011000);
}
static inline __m256d blendLowHigh_256pd(__m256d x, __m256d y) {
  return _mm256_blend_pd(x, y, 0xC);
}


#endif
