#ifndef WRAPPER_ARM64_128_INT16_H_
#define WRAPPER_ARM64_128_INT16_H_

#include <arm_neon.h>

#define LANES(V) V(0) V(1) V(2) V(3) V(4) V(5) V(6) V(7)

#define GET_LANE_16x8i(LANE) \
  static inline int16_t get_lane_16x8i##LANE(int16x8_t v) { \
    return vgetq_lane_s16(v, LANE); \
  }
LANES(GET_LANE_16x8i)
#undef GET_LANE_16x8i

#define SET_LANE_16x8i(LANE) \
  static inline int16x8_t set_lane_16x8i##LANE(int16x8_t v, int16_t x) { \
    return vsetq_lane_s16(x, v, LANE); \
  }
LANES(SET_LANE_16x8i)
#undef SET_LANE_16x8i

static inline int16x8_t load16x8i(const int16_t* x) { return vld1q_s16(x); }
static inline void store16x8i(int16_t* x, int16x8_t y) { vst1q_s16(x, y); }

#define EXTRACT_VECTOR_16x8i(LANE) \
  static inline int16x8_t extractVector16x8i##LANE(int16x8_t x, int16x8_t y) { \
    return vextq_s16(x, y, LANE); \
  }
LANES(EXTRACT_VECTOR_16x8i)
#undef EXTRACT_VECTOR_16x8i

#undef LANES

static inline int is_all_zeros_16x8i(int16x8_t x) {
  return vminvq_s16(x) == 0;
}

static inline int movemask_16x8i(int16x8_t x) {
  uint16x8_t input = vreinterpretq_u16_s16(x);
  uint32x4_t paired16 = vreinterpretq_u32_u16(vshrq_n_u16(input, 15));
  uint64x2_t paired32 = vreinterpretq_u64_u32(vsraq_n_u32(paired16, paired16, 14));
  uint8x16_t paired64 = vreinterpretq_u8_u64(vsraq_n_u64(paired32, paired32, 28));
  return vgetq_lane_u8(paired64, 0) | ((int) vgetq_lane_u8(paired64, 8) << 8);
}

static inline int16x8_t reverse_16x8i(int16x8_t x) {
  static const int8x16_t mask = {
    14, 15, 12, 13, 10, 11, 8, 9,
    6, 7, 4, 5, 2, 3, 0, 1
  };
  return vqtbl1q_s8(x, mask);
}

#endif
