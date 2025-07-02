#include <x86intrin.h>

#include "wrapper-x86-256-int8.h"
#include "wrapper-x86-256-int16.h"
#include "wrapper-x86-256-int32.h"
#include "wrapper-x86-256-int64.h"
#include "wrapper-x86-256-real32.h"
#include "wrapper-x86-256-real64.h"

static inline __m128i extract128x2i0(__m256i x) {
  return _mm256_extractf128_si256(x, 0);
}
static inline __m128i extract128x2i1(__m256i x) {
  return _mm256_extractf128_si256(x, 1);
}

static inline __m256i insert128x2i0(__m256i x, __m128i y) {
  return _mm256_insertf128_si256(x, y, 0);
}
static inline __m256i insert128x2i1(__m256i x, __m128i y) {
  return _mm256_insertf128_si256(x, y, 1);
}
