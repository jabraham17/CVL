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

#endif
