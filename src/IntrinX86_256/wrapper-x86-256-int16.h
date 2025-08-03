#ifndef WRAPPER_X86_256_INT16_H_
#define WRAPPER_X86_256_INT16_H_

#include <x86intrin.h>

static inline __m256i swapPairs_256epi16(__m256i x) {
  const __m256i mask = _mm256_set_epi8(
    29, 28, 31, 30, 25, 24, 27, 26,
    21, 20, 23, 22, 17, 16, 19, 18,
    13, 12, 15, 14, 9, 8, 11, 10,
    5, 4, 7, 6, 1, 0, 3, 2
  );
  return _mm256_shuffle_epi8(x, mask);
}
static inline __m256i swapLowHigh_256epi16(__m256i x) {
  return _mm256_permute2f128_si256(x, x, 1);
}

static inline __m256i reverse_256epi16(__m256i x) {
  const __m256i mask = _mm256_set_epi8(
    17, 16, 19, 18, 21, 20, 23, 22,
    25, 24, 27, 26, 29, 28, 31, 30,
    1, 0, 3, 2, 5, 4, 7, 6,
    9, 8, 11, 10, 13, 12, 15, 14
  );
  return _mm256_shuffle_epi8(swapLowHigh_256epi16(x), mask);
}
static inline __m256i rotateLeft_256epi16(__m256i x) {
  __m256i t1 = _mm256_bsrli_epi128(x, 2);
  // mask out everything but the lowest 16 bits of each 128-bit half
  __m256i t2 = _mm256_and_si256(x, _mm256_set_epi8(
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0xFF, 0xFF,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0xFF, 0xFF
  ));
  // shift the mask right by 14 bytes and swap
  __m256i t3 = swapLowHigh_256epi16(_mm256_bslli_epi128(t2, 14));
  return _mm256_or_si256(t1, t3);
}
static inline __m256i rotateRight_256epi16(__m256i x) {
  __m256i t1 = _mm256_bslli_epi128(x, 2);
  __m256i t2 = _mm256_and_si256(x, _mm256_set_epi8(
    0xFF, 0xFF, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0xFF, 0xFF, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
  ));
  __m256i t3 = swapLowHigh_256epi16(_mm256_bsrli_epi128(t2, 14));
  return _mm256_or_si256(t1, t3);
}
static inline __m256i blendLowHigh_256epi16(__m256i x, __m256i y) {
  return _mm256_blend_epi32(x, y, 0xf0);
}


static inline __m256i interleaveLower_256epi16(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi16(x, y);
  __m256i t1 = _mm256_unpackhi_epi16(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x20);
}
static inline __m256i interleaveUpper_256epi16(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi16(x, y);
  __m256i t1 = _mm256_unpackhi_epi16(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x31);
}

static inline __m256i hadd_256epi16(__m256i x, __m256i y) {
  //  what we want is:
  //    [x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, xa, xb, xc, xd, xe, xf]
  //    [y0, y1, y2, y3, y4, y5, y6, y7, y8, y9, ya, yb, yc, yd, ye, yf]
  // => [x0+x1, y0+y1, x2+x3, y2+y3, x4+x5, y4+y5, x6+x7, y6+y7,
  //     x8+x9, y8+y9, xa+xb, ya+yb, xc+xd, yc+yd, xe+xf, ye+yf]

  // _mm256_hadd_epi16 does
  //    [x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, xa, xb, xc, xd, xe, xf]
  //    [y0, y1, y2, y3, y4, y5, y6, y7, y8, y9, ya, yb, yc, yd, ye, yf]
  // => [x0+x1, x2+x3, x4+x5, x6+x7, y0+y1, y2+y3, y4+y5, y6+y7,
  //     x8+x9, xa+xb, xc+xd, xe+xf, y8+y9, ya+yb, yc+yd, ye+yf]

  __m256i hadd = _mm256_hadd_epi16(x, y);
  // swap lanes 1 and 2 in each 128 bits
  __m256i res = _mm256_shuffle_epi32(hadd, 0b11011000);
  //  swap lanes 1 and 2 in each 64 bits
  __m256i t0 = _mm256_shufflelo_epi16(res, 0b11011000);
  __m256i t1 = _mm256_shufflehi_epi16(t0, 0b11011000);
  return t1;
}

#endif
