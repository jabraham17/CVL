#include <arm_neon.h>

float get_lane_32x4f0(float32x4_t v);
float get_lane_32x4f1(float32x4_t v);
float get_lane_32x4f2(float32x4_t v);
float get_lane_32x4f3(float32x4_t v);

float32x4_t set_lane_32x4f0(float32x4_t v, float x);
float32x4_t set_lane_32x4f1(float32x4_t v, float x);
float32x4_t set_lane_32x4f2(float32x4_t v, float x);
float32x4_t set_lane_32x4f3(float32x4_t v, float x);

float32x4_t load32x4f(const float* x);
void store32x4f(float* x, float32x4_t y);

float32x4_t extractVector32x4f0(float32x4_t x, float32x4_t y);
float32x4_t extractVector32x4f1(float32x4_t x, float32x4_t y);
float32x4_t extractVector32x4f2(float32x4_t x, float32x4_t y);
float32x4_t extractVector32x4f3(float32x4_t x, float32x4_t y);
