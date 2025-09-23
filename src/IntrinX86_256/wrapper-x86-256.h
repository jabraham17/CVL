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

static inline __m128i chpl_mm256_castsi256_si256(__m128i x) { return x; }
static inline __m128  chpl_mm256_castps_ps(__m128 x) { return x; }
static inline __m128d chpl_mm266_castpd_pd(__m128d x) { return x; }


// workarounds for Chapel C codegen bugs, see IntrinX86_256.chpl
typedef __m256  vec32x8r;
typedef __m256d vec64x4r;
typedef __m256i vec8x32i;
typedef __m256i vec16x16i;
typedef __m256i vec32x8i;
typedef __m256i vec64x4i;
typedef __m256i vec8x32u;
typedef __m256i vec16x16u;
typedef __m256i vec32x8u;
typedef __m256i vec64x4u;
