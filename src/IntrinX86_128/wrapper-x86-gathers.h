#ifndef WRAPPER_X86_GATHERS_H_
#define WRAPPER_X86_GATHERS_H_

#include <x86intrin.h>

#define MAKE_I32_GATHERS(MM, VEC_TYPE, IDX_VEC_TYPE, PTR_TYPE, SUFFIX, SCALE) \
  static inline VEC_TYPE _##MM##_i32gather_##SCALE##_##SUFFIX(PTR_TYPE const* base_addr, IDX_VEC_TYPE vindex) { \
    return _##MM##_i32gather_##SUFFIX(base_addr, vindex, SCALE); \
  } \
  static inline VEC_TYPE _##MM##_mask_i32gather_##SCALE##_##SUFFIX(VEC_TYPE src, PTR_TYPE const* base_addr, IDX_VEC_TYPE vindex, VEC_TYPE mask) { \
    return _##MM##_mask_i32gather_##SUFFIX(src, base_addr, vindex, mask, SCALE); \
  }

MAKE_I32_GATHERS(mm, __m128i, __m128i, int32_t, epi32, 1)
MAKE_I32_GATHERS(mm, __m128i, __m128i, int32_t, epi32, 2)
MAKE_I32_GATHERS(mm, __m128i, __m128i, int32_t, epi32, 4)
MAKE_I32_GATHERS(mm, __m128i, __m128i, int32_t, epi32, 8)
MAKE_I32_GATHERS(mm256, __m256i, __m256i, int32_t, epi32, 1)
MAKE_I32_GATHERS(mm256, __m256i, __m256i, int32_t, epi32, 2)
MAKE_I32_GATHERS(mm256, __m256i, __m256i, int32_t, epi32, 4)
MAKE_I32_GATHERS(mm256, __m256i, __m256i, int32_t, epi32, 8)

MAKE_I32_GATHERS(mm, __m128i, __m128i, int64_t, epi64, 1)
MAKE_I32_GATHERS(mm, __m128i, __m128i, int64_t, epi64, 2)
MAKE_I32_GATHERS(mm, __m128i, __m128i, int64_t, epi64, 4)
MAKE_I32_GATHERS(mm, __m128i, __m128i, int64_t, epi64, 8)
MAKE_I32_GATHERS(mm256, __m256i, __m128i, int64_t, epi64, 1)
MAKE_I32_GATHERS(mm256, __m256i, __m128i, int64_t, epi64, 2)
MAKE_I32_GATHERS(mm256, __m256i, __m128i, int64_t, epi64, 4)
MAKE_I32_GATHERS(mm256, __m256i, __m128i, int64_t, epi64, 8)

MAKE_I32_GATHERS(mm, __m128d, __m128i, double, pd, 1)
MAKE_I32_GATHERS(mm, __m128d, __m128i, double, pd, 2)
MAKE_I32_GATHERS(mm, __m128d, __m128i, double, pd, 4)
MAKE_I32_GATHERS(mm, __m128d, __m128i, double, pd, 8)
MAKE_I32_GATHERS(mm256, __m256d, __m128i, double, pd, 1)
MAKE_I32_GATHERS(mm256, __m256d, __m128i, double, pd, 2)
MAKE_I32_GATHERS(mm256, __m256d, __m128i, double, pd, 4)
MAKE_I32_GATHERS(mm256, __m256d, __m128i, double, pd, 8)

MAKE_I32_GATHERS(mm, __m128, __m128i, float, ps, 1)
MAKE_I32_GATHERS(mm, __m128, __m128i, float, ps, 2)
MAKE_I32_GATHERS(mm, __m128, __m128i, float, ps, 4)
MAKE_I32_GATHERS(mm, __m128, __m128i, float, ps, 8)
MAKE_I32_GATHERS(mm256, __m256, __m256i, float, ps, 1)
MAKE_I32_GATHERS(mm256, __m256, __m256i, float, ps, 2)
MAKE_I32_GATHERS(mm256, __m256, __m256i, float, ps, 4)
MAKE_I32_GATHERS(mm256, __m256, __m256i, float, ps, 8)


#undef MAKE_I32_GATHERS

#endif
