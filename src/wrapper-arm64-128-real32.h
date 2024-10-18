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

#endif
