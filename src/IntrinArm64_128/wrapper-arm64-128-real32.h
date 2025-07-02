#ifndef WRAPPER_ARM64_128_REAL32_H_
#define WRAPPER_ARM64_128_REAL32_H_

#include <arm_neon.h>

#define LANES(V) V(0) V(1) V(2) V(3)

#define GET_LANE_32x4r(LANE) \
  static inline float32_t get_lane_32x4r##LANE(float32x4_t v) { \
    return vgetq_lane_f32(v, LANE); \
  }
LANES(GET_LANE_32x4r)
#undef GET_LANE_32x4r

#define SET_LANE_32x4r(LANE) \
  static inline float32x4_t set_lane_32x4r##LANE(float32x4_t v, float32_t x) { \
    return vsetq_lane_f32(x, v, LANE); \
  }
LANES(SET_LANE_32x4r)
#undef SET_LANE_32x4r

static inline float32x4_t load32x4r(const float32_t* x) { return vld1q_f32(x); }
static inline void store32x4r(float32_t* x, float32x4_t y) { vst1q_f32(x, y); }

#define EXTRACT_VECTOR_32x4r(LANE) \
  static inline float32x4_t extractVector32x4r##LANE(float32x4_t x, float32x4_t y) { \
    return vextq_f32(x, y, LANE); \
  }
LANES(EXTRACT_VECTOR_32x4r)
#undef EXTRACT_VECTOR_32x4r

#undef LANES

static inline int is_all_zeros_32x4r(float32x4_t x) {
  uint32x4_t uint_x = vreinterpretq_u32_f32(x);
  uint32x2_t and_reduced = vorr_u32(vget_low_u32(uint_x), vget_high_u32(uint_x));
  return (vget_lane_u32(and_reduced, 0) | vget_lane_u32(and_reduced, 1)) == 0;
}

static inline int movemask_32x4r(float32x4_t x) {
  uint32x4_t input = vreinterpretq_u32_f32(x);
  uint64x2_t paired32 = vreinterpretq_u64_u32(vshrq_n_u32(input, 31));
  uint8x16_t paired64 = vreinterpretq_u8_u64(vsraq_n_u64(paired32, paired32, 28));
  return vgetq_lane_u8(paired64, 0) | ((int) vgetq_lane_u8(paired64, 8) << 2);
}

#endif
