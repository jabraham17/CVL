#include "wrapper-arm64-128-double.h"

float get_lane_64x2d0(float64x2_t v) { return vgetq_lane_f64(v, 0); }
float get_lane_64x2d1(float64x2_t v) { return vgetq_lane_f64(v, 1); }

float64x2_t set_lane_64x2d0(float64x2_t v, float x) { return vsetq_lane_f64(x, v, 0); }
float64x2_t set_lane_64x2d1(float64x2_t v, float x) { return vsetq_lane_f64(x, v, 1); }

float64x2_t load64x2d(const double* x) { return vld1q_f64(x); }
void store64x2d(double* x, float64x2_t y) { vst1q_f64(x, y); }

float64x2_t extractVector64x2f0(float64x2_t x, float64x2_t y) { return vextq_f64(x, y, 0); }
float64x2_t extractVector64x2f1(float64x2_t x, float64x2_t y) { return vextq_f64(x, y, 1); }
