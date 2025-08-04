#ifndef WRAPPER_ARM64_128_INT8_H_
#define WRAPPER_ARM64_128_INT8_H_

#include <arm_neon.h>

#define LANES(V) \
  V(0) V(1) V(2) V(3) V(4) V(5) V(6) V(7) V(8) \
  V(9) V(10) V(11) V(12) V(13) V(14) V(15)

#define GET_LANE_8x16i(LANE) \
  static inline int8_t get_lane_8x16i##LANE(int8x16_t v) { \
    return vgetq_lane_s8(v, LANE); \
  }
LANES(GET_LANE_8x16i)
#undef GET_LANE_8x16i

#define SET_LANE_8x16i(LANE) \
  static inline int8x16_t set_lane_8x16i##LANE(int8x16_t v, int8_t x) { \
    return vsetq_lane_s8(x, v, LANE); \
  }
LANES(SET_LANE_8x16i)
#undef SET_LANE_8x16i

static inline int8x16_t load8x16i(const int8_t* x) { return vld1q_s8(x); }
static inline void store8x16i(int8_t* x, int8x16_t y) { vst1q_s8(x, y); }

#define EXTRACT_VECTOR_8x16i(LANE) \
  static inline int8x16_t extractVector8x16i##LANE(int8x16_t x, int8x16_t y) { \
    return vextq_s8(x, y, LANE); \
  }
LANES(EXTRACT_VECTOR_8x16i)
#undef EXTRACT_VECTOR_8x16i

#undef LANES


#define HALF_LANES(V) \
V(0) V(1) V(2) V(3) V(4) V(5) V(6) V(7)

#define GET_LANE_8x8i(LANE) \
  static inline int8_t get_lane_8x8i##LANE(int8x8_t v) { \
    return vget_lane_s8(v, LANE); \
  }
HALF_LANES(GET_LANE_8x8i)
#undef GET_LANE_8x8i

#undef HALF_LANES

static inline int is_all_zeros_8x16i(int8x16_t x) {
  return vminvq_s8(x) == 0;
}
static inline int movemask_8x16i(int8x16_t x) {
  uint8x16_t input = vreinterpretq_u8_s8(x);
  uint16x8_t high_bits = vreinterpretq_u16_u8(vshrq_n_u8(input, 7));
  uint32x4_t paired16 = vreinterpretq_u32_u16(vsraq_n_u16(high_bits, high_bits, 7));
  uint64x2_t paired32 = vreinterpretq_u64_u32(vsraq_n_u32(paired16, paired16, 14));
  uint8x16_t paired64 = vreinterpretq_u8_u64(vsraq_n_u64(paired32, paired32, 28));
  return vgetq_lane_u8(paired64, 0) | ((int) vgetq_lane_u8(paired64, 8) << 8);
}

static inline int8x16_t reverse_8x16i(int8x16_t x) {
  static const int8x16_t mask = {
    15, 14, 13, 12, 11, 10, 9, 8,
    7, 6, 5, 4, 3, 2, 1, 0
  };
  return vqtbl1q_s8(x, mask);
}

#endif
