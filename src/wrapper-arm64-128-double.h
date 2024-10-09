#include <arm_neon.h>


float get_lane_64x2d0(float64x2_t v);
float get_lane_64x2d1(float64x2_t v);

float64x2_t set_lane_64x2d0(float64x2_t v, float x);
float64x2_t set_lane_64x2d1(float64x2_t v, float x);

float64x2_t load64x2d(const double* x);
void store64x2d(double* x, float64x2_t y);

float64x2_t extractVector64x2f0(float64x2_t x, float64x2_t y);
float64x2_t extractVector64x2f1(float64x2_t x, float64x2_t y);
