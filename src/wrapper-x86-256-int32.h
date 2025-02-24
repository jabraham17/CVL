#ifndef WRAPPER_X86_256_INT32_H_
#define WRAPPER_X86_256_INT32_H_

#include <x86intrin.h>

static inline __m256i hadd_256epi32(__m256i x, __m256i y) {
  __m256i t0 = _mm256_hadd_epi32(x, y);
  return _mm256_shuffle_epi32(t0, 0b11011000);
}

#endif
