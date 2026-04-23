#ifndef WRAPPER_X86_128_INT64_H_
#define WRAPPER_X86_128_INT64_H_

#include <x86intrin.h>

#define LANES(V) V(0) V(1)

#define GET_LANE_64x2i(LANE) \
  static inline int64_t get_lane_64x2i##LANE(__m128i x) { \
    return (int64_t)_mm_extract_epi64(x, LANE); \
  }
LANES(GET_LANE_64x2i)
#undef GET_LANE_64x2i

#define SET_LANE_64x2i(LANE) \
  static inline __m128i set_lane_64x2i##LANE(__m128i x, int64_t y) { \
    return _mm_insert_epi64(x, y, LANE); \
  }
LANES(SET_LANE_64x2i)
#undef SET_LANE_64x2i

static inline __m128i swapPairs_epi64(__m128i x) {
  return _mm_shuffle_epi32(x, 0b01001110);
}
static inline __m128i blendLowHigh_epi64(__m128i x, __m128i y) {
  return _mm_blend_epi32(x, y, 0b1100);
}

static inline __m128i compat_abs_epi64(__m128i x) {
  // compare with 0, use the result to conditionally negate the value
  __m128i zero = _mm_setzero_si128();
  __m128i sign_mask = _mm_cmpgt_epi64(zero, x);
  __m128i t0 = _mm_xor_si128(x, sign_mask);
  __m128i t1 = _mm_sub_epi64(t0, sign_mask);
  return t1;
}

#define SHUFFLES(IMM) \
  static inline __m128i shiftLeft128_i_##IMM##_epi64(__m128i x) { \
    return _mm_slli_epi64(x, IMM); \
  } \
  static inline __m128i shiftRight128_i_##IMM##_epi64(__m128i x) { \
    return _mm_srli_epi64(x, IMM); \
  }
#define BITS(V) V(1) V(2) V(3) V(4) V(5) V(6) V(7) V(8) \
                V(9) V(10) V(11) V(12) V(13) V(14) V(15) V(16) \
                V(17) V(18) V(19) V(20) V(21) V(22) V(23) V(24) \
                V(25) V(26) V(27) V(28) V(29) V(30) V(31) V(32) \
                V(33) V(34) V(35) V(36) V(37) V(38) V(39) V(40) \
                V(41) V(42) V(43) V(44) V(45) V(46) V(47) V(48) \
                V(49) V(50) V(51) V(52) V(53) V(54) V(55) V(56) \
                V(57) V(58) V(59) V(60) V(61) V(62) V(63)
BITS(SHUFFLES)
#undef BITS
#undef SHUFFLES

#undef LANES

#endif
