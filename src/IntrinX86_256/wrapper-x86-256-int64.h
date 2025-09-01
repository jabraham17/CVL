#ifndef WRAPPER_X86_256_INT64_H_
#define WRAPPER_X86_256_INT64_H_

#include <x86intrin.h>

static inline __m256i swapPairs_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0xB1);
}
static inline __m256i swapLowHigh_256epi64(__m256i x) {
  return _mm256_permute2f128_si256(x, x, 1);
}

static inline __m256i reverse_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0x1B);
}
static inline __m256i rotateLeft_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0x39);
}
static inline __m256i rotateRight_256epi64(__m256i x) {
  return _mm256_permute4x64_epi64(x, 0x93);
}

static inline __m256i blendLowHigh_256epi64(__m256i x, __m256i y) {
  return _mm256_blend_epi32(x, y, 0xf0);
}

static inline __m256i interleaveLower_256epi64(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi64(x, y);
  __m256i t1 = _mm256_unpackhi_epi64(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x20);
}
static inline __m256i interleaveUpper_256epi64(__m256i x, __m256i y) {
  __m256i t0 = _mm256_unpacklo_epi64(x, y);
  __m256i t1 = _mm256_unpackhi_epi64(x, y);
  return _mm256_permute2f128_si256(t0, t1, 0x31);
}

static inline __m256i compat_abs_256epi64(__m256i x) {
  // compare with 0, use the result to conditionally negate the value
  __m256i zero = _mm256_setzero_si256();
  __m256i sign_mask = _mm256_cmpgt_epi64(zero, x);
  __m256i t0 = _mm256_xor_si256(x, sign_mask);
  __m256i t1 = _mm256_sub_epi64(t0, sign_mask);
  return t1;
}

#define SHUFFLES(IMM) \
  static inline __m256i shiftLeft256_i_##IMM##_epi64(__m256i x) { \
    return _mm256_slli_epi64(x, IMM); \
  } \
  static inline __m256i shiftRight256_i_##IMM##_epi64(__m256i x) { \
    return _mm256_srli_epi64(x, IMM); \
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

#endif
