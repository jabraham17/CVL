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

#endif
