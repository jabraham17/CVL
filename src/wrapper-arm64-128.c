#include "wrapper-arm64-128.h"

float get_lane_32x4f0(float32x4_t v) { return vgetq_lane_f32(v, 0); }
float get_lane_32x4f1(float32x4_t v) { return vgetq_lane_f32(v, 1); }
float get_lane_32x4f2(float32x4_t v) { return vgetq_lane_f32(v, 2); }
float get_lane_32x4f3(float32x4_t v) { return vgetq_lane_f32(v, 3); }

float32x4_t set_lane_32x4f0(float32x4_t v, float x) { return vsetq_lane_f32(x, v, 0); }
float32x4_t set_lane_32x4f1(float32x4_t v, float x) { return vsetq_lane_f32(x, v, 1); }
float32x4_t set_lane_32x4f2(float32x4_t v, float x) { return vsetq_lane_f32(x, v, 2); }
float32x4_t set_lane_32x4f3(float32x4_t v, float x) { return vsetq_lane_f32(x, v, 3); }

float32x4_t load32x4f(const float* x) { return vld1q_f32(x); }
void store32x4f(float* x, float32x4_t y) { vst1q_f32(x, y); }

float32x4_t extractVector32x4f0(float32x4_t x, float32x4_t y) { return vextq_f32(x, y, 0); }
float32x4_t extractVector32x4f1(float32x4_t x, float32x4_t y) { return vextq_f32(x, y, 1); }
float32x4_t extractVector32x4f2(float32x4_t x, float32x4_t y) { return vextq_f32(x, y, 2); }
float32x4_t extractVector32x4f3(float32x4_t x, float32x4_t y) { return vextq_f32(x, y, 3); }

float get_lane_64x2d0(float64x2_t v) { return vgetq_lane_f64(v, 0); }
float get_lane_64x2d1(float64x2_t v) { return vgetq_lane_f64(v, 1); }

float64x2_t set_lane_64x2d0(float64x2_t v, float x) { return vsetq_lane_f64(x, v, 0); }
float64x2_t set_lane_64x2d1(float64x2_t v, float x) { return vsetq_lane_f64(x, v, 1); }

float64x2_t load64x2d(const double* x) { return vld1q_f64(x); }
void store64x2d(double* x, float64x2_t y) { vst1q_f64(x, y); }

float64x2_t extractVector64x2f0(float64x2_t x, float64x2_t y) { return vextq_f64(x, y, 0); }
float64x2_t extractVector64x2f1(float64x2_t x, float64x2_t y) { return vextq_f64(x, y, 1); }
