#include "wrapper-x86-256.h"

__m128 extract128x2f0(__m256 x) { return _mm256_extractf128_ps(x, 0); }
__m128 extract128x2f1(__m256 x) { return _mm256_extractf128_ps(x, 1); }

__m256 insert128x2f0(__m256 x, __m128 y) { return _mm256_insertf128_ps(x, y, 0); }
__m256 insert128x2f1(__m256 x, __m128 y) { return _mm256_insertf128_ps(x, y, 1); }

__m256 swapPairs32x8f(__m256 x) { return _mm256_permute_ps(x, 0xb1); }
__m256 swapLowHigh32x8f(__m256 x) { return _mm256_permute2f128_ps(x, x, 1); }
__m256 reverse32x8f(__m256 x) {
  __m256i mask = _mm256_set_epi32(0, 1, 2, 3, 4, 5, 6, 7);
  return _mm256_permutevar8x32_ps(x, mask);
}
__m256 rotateLeft32x8f(__m256 x) {
  __m256i mask = _mm256_set_epi32(0, 7, 6, 5, 4, 3, 2, 1);
  return _mm256_permutevar8x32_ps(x, mask);
}
__m256 rotateRight32x8f(__m256 x) {
  __m256i mask = _mm256_set_epi32(6, 5, 4, 3, 2, 1, 0, 7);
  return _mm256_permutevar8x32_ps(x, mask);
}
__m256 interleaveLower32x8f(__m256 x, __m256 y) {
  __m256 t0 = _mm256_unpacklo_ps(x, y);
  __m256 t1 = _mm256_unpackhi_ps(x, y);
  return _mm256_permute2f128_ps(t0, t1, 0x20);
}
__m256 interleaveUpper32x8f(__m256 x, __m256 y) {
  __m256 t0 = _mm256_unpacklo_ps(x, y);
  __m256 t1 = _mm256_unpackhi_ps(x, y);
  return _mm256_permute2f128_ps(t0, t1, 0x31);
}
__m256 deinterleaveLower32x8f(__m256 x, __m256 y) {
  __m256i mask = _mm256_set_epi32(14, 12, 10, 8, 6, 4, 2, 0);
  __m256 t0 = _mm256_permutevar8x32_ps(x, mask);
  __m256 t1 = _mm256_permutevar8x32_ps(y, mask);
  return _mm256_blend_ps(t0, t1, 0xF0);
}
__m256 deinterleaveUpper32x8f(__m256 x, __m256 y) {
  __m256i mask = _mm256_set_epi32(15, 13, 11, 9, 7, 5, 3, 1);
  __m256 t0 = _mm256_permutevar8x32_ps(x, mask);
  __m256 t1 = _mm256_permutevar8x32_ps(y, mask);
  return _mm256_blend_ps(t0, t1, 0xF0);
}
__m256 blendLowHigh32x8f(__m256 x, __m256 y) { return _mm256_blend_ps(x, y, 0xf0); }


__m128d extract128x2d0(__m256d x) { return _mm256_extractf128_pd(x, 0); }
__m128d extract128x2d1(__m256d x) { return _mm256_extractf128_pd(x, 1); }

__m256d insert128x2d0(__m256d x, __m128d y) { return _mm256_insertf128_pd(x, y, 0); }
__m256d insert128x2d1(__m256d x, __m128d y) { return _mm256_insertf128_pd(x, y, 1); }

__m256d swapPairs64x4d(__m256d x) { return _mm256_permute4x64_pd(x, 0xB1); }
__m256d swapLowHigh64x4d(__m256d x) { return _mm256_permute4x64_pd(x, 0x4E); }
__m256d reverse64x4d(__m256d x) { return _mm256_permute4x64_pd(x, 0x1B); }
__m256d rotateLeft64x4d(__m256d x) { return _mm256_permute4x64_pd(x, 0x39); }
__m256d rotateRight64x4d(__m256d x) { return _mm256_permute4x64_pd(x, 0x93); }
__m256d interleaveLower64x4d(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpacklo_pd(x, y);
  __m256d t1 = _mm256_unpackhi_pd(x, y);
  return _mm256_permute2f128_pd(t0, t1, 0x20);
}
__m256d interleaveUpper64x4d(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpacklo_pd(x, y);
  __m256d t1 = _mm256_unpackhi_pd(x, y);
  return _mm256_permute2f128_pd(t0, t1, 0x31);
}
__m256d deinterleaveLower64x4d(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpacklo_pd(x, y);
  return _mm256_permute4x64_pd(t0, 0b11011000);
}
__m256d deinterleaveUpper64x4d(__m256d x, __m256d y) {
  __m256d t0 = _mm256_unpackhi_pd(x, y);
  return _mm256_permute4x64_pd(t0, 0b11011000);
}
__m256d blendLowHigh64x4d(__m256d x, __m256d y) {
  return _mm256_blend_pd(x, y, 0xC);
}
