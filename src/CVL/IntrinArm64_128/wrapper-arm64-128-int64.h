#ifndef WRAPPER_ARM64_128_INT64_H_
#define WRAPPER_ARM64_128_INT64_H_

#include <arm_neon.h>

#define LANES(V) V(0) V(1)

#define GET_LANE_64x2i(LANE) \
  static inline int64_t get_lane_64x2i##LANE(int64x2_t v) { \
    return vgetq_lane_s64(v, LANE); \
  }
LANES(GET_LANE_64x2i)
#undef GET_LANE_64x2i

#define SET_LANE_64x2i(LANE) \
  static inline int64x2_t set_lane_64x2i##LANE(int64x2_t v, int64_t x) { \
    return vsetq_lane_s64(x, v, LANE); \
  }
LANES(SET_LANE_64x2i)
#undef SET_LANE_64x2i

static inline int64x2_t load64x2i(const int64_t* x) { return vld1q_s64(x); }
static inline void store64x2i(int64_t* x, int64x2_t y) { vst1q_s64(x, y); }

#define EXTRACT_VECTOR_64x2i(LANE) \
  static inline int64x2_t extractVector64x2i##LANE(int64x2_t x, int64x2_t y) { \
    return vextq_s64(x, y, LANE); \
  }
LANES(EXTRACT_VECTOR_64x2i)
#undef EXTRACT_VECTOR_64x2i

#undef LANES

static inline int is_all_zeros_64x2i(int64x2_t x) {
  int64x1_t and_reduced = vorr_s64(vget_low_s64(x), vget_high_s64(x));
  return vget_lane_s64(and_reduced, 0) == 0;
}

static inline int movemask_64x2i(int64x2_t x) {
  uint64x2_t input = vreinterpretq_u64_s64(x);
  uint8x16_t paired64 = vreinterpretq_u8_u64(vshrq_n_u64(input, 63));
  return vgetq_lane_u8(paired64, 0) | ((int) vgetq_lane_u8(paired64, 8) << 8);
}

#define SHUFFLES(IMM) \
  static inline int64x2_t shiftLeft_n_##IMM##_s64(int64x2_t x) { \
    return vshlq_n_s64(x, IMM); \
  } \
  static inline int64x2_t shiftRight_n_##IMM##_s64(int64x2_t x) { \
    return vshrq_n_s64(x, IMM); \
  } \
  static inline uint64x2_t shiftRight_n_##IMM##_u64(uint64x2_t x) { \
    return vshrq_n_u64(x, IMM); \
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
