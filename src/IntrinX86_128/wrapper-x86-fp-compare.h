#ifndef WRAPPER_X86_FP_COMPARE_H_
#define WRAPPER_X86_FP_COMPARE_H_

#include <x86intrin.h>

#define COMPARE_OPS(V) \
  V(cmpEq, _CMP_EQ_OQ) \
  V(cmpNe, _CMP_NEQ_OQ) \
  V(cmpLt, _CMP_LT_OQ) \
  V(cmpLe, _CMP_LE_OQ) \
  V(cmpGt, _CMP_GT_OQ) \
  V(cmpGe, _CMP_GE_OQ)

#define DEFINE_COMPARE_OP(op, cmp) \
  static inline __m128 op##128##ps(__m128 x, __m128d y) { \
    return _mm_cmp_ps(x, y, cmp); \
  } \
  static inline __m128d op##128##pd(__m128d x, __m128d y) { \
    return _mm_cmp_pd(x, y, cmp); \
  } \
  static inline __m256 op##256##ps(__m256 x, __m256 y) { \
    return _mm256_cmp_ps(x, y, cmp); \
  } \
  static inline __m256d op##256##pd(__m256d x, __m256d y) { \
    return _mm256_cmp_pd(x, y, cmp); \
  }
COMPARE_OPS(DEFINE_COMPARE_OP)
#undef DEFINE_COMPARE_OP
#undef COMPARE_OPS

#endif
