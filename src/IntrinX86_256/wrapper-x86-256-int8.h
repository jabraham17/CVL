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
  const __m256i mask = _mm256_set_epi8(
    0, 1, 2, 3, 4, 5, 6, 7,
    8, 9, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20, 21, 22, 23,
    24, 25, 26, 27, 28, 29, 30, 31
  );
  return _mm256_shuffle_epi8(swapLowHigh_256epi8(x), mask);
}
static inline __m256i rotateLeft_256epi8(__m256i x) {
  __m256i t1 = _mm256_bsrli_epi128(x, 1);
  // mask out everything but the lowest 8 bits of each 128-bit half
  __m256i t2 = _mm256_and_si256(x, _mm256_set_epi8(
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0xFF,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0xFF
  ));
  // shift the mask right by 15 bytes and swap
  __m256i t3 = swapLowHigh_256epi8(_mm256_bslli_epi128(t2, 15));
  return _mm256_or_si256(t1, t3);
}
static inline __m256i rotateRight_256epi8(__m256i x) {
  __m256i t1 = _mm256_bslli_epi128(x, 1);
  __m256i t2 = _mm256_and_si256(x, _mm256_set_epi8(
    0xFF, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0xFF, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
  ));
  __m256i t3 = swapLowHigh_256epi8(_mm256_bsrli_epi128(t2, 15));
  return _mm256_or_si256(t1, t3);
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

static inline __m256i deinterleaveLower_256epi8(__m256i x, __m256i y) {
  __m256i mask = _mm256_set_epi8(
    14, 12, 10, 8, 6, 4, 2, 0,
    14, 12, 10, 8, 6, 4, 2, 0,
    14, 12, 10, 8, 6, 4, 2, 0,
    14, 12, 10, 8, 6, 4, 2, 0
  );
  __m256i t0 = _mm256_permute4x64_epi64(
    _mm256_shuffle_epi8(x, mask), _MM_SHUFFLE(3, 1, 2, 0));
  __m256i t1 = _mm256_permute4x64_epi64(
    _mm256_shuffle_epi8(y, mask), _MM_SHUFFLE(3, 1, 2, 0));
  return _mm256_blend_epi32(t0, t1, 0b11110000);
}
static inline __m256i deinterleaveUpper_256epi8(__m256i x, __m256i y) {
  __m256i mask = _mm256_set_epi8(
    15, 13, 11, 9, 7, 5, 3, 1,
    15, 13, 11, 9, 7, 5, 3, 1,
    15, 13, 11, 9, 7, 5, 3, 1,
    15, 13, 11, 9, 7, 5, 3, 1
  );
  __m256i t0 = _mm256_permute4x64_epi64(
    _mm256_shuffle_epi8(x, mask), _MM_SHUFFLE(3, 1, 2, 0));
  __m256i t1 = _mm256_permute4x64_epi64(
    _mm256_shuffle_epi8(y, mask), _MM_SHUFFLE(3, 1, 2, 0));
  return _mm256_blend_epi32(t0, t1, 0b11110000);
}

#endif
