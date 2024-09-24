#include "wrapper-x86-128.h"

float extract32x4f0(__m128 x) {
  union { int i; float f; } temp;
  temp.i = _mm_extract_ps(x, 0);
  return temp.f;
}
float extract32x4f1(__m128 x) {
  union { int i; float f; } temp;
  temp.i = _mm_extract_ps(x, 1);
  return temp.f;
}
float extract32x4f2(__m128 x) {
  union { int i; float f; } temp;
  temp.i = _mm_extract_ps(x, 2);
  return temp.f;
}
float extract32x4f3(__m128 x) {
  union { int i; float f; } temp;
  temp.i = _mm_extract_ps(x, 3);
  return temp.f;
}

__m128 insert32x4f0(__m128 x, float y) {
  __m128 temp = _mm_set_ss(y);
  return _mm_insert_ps(x, temp, 0b00000000);
}
__m128 insert32x4f1(__m128 x, float y) {
  __m128 temp = _mm_set_ss(y);
  return _mm_insert_ps(x, temp, 0b00010000);
}
__m128 insert32x4f2(__m128 x, float y) {
  __m128 temp = _mm_set_ss(y);
  return _mm_insert_ps(x, temp, 0b00100000);
}
__m128 insert32x4f3(__m128 x, float y) {
  __m128 temp = _mm_set_ss(y);
  return _mm_insert_ps(x, temp, 0b00110000);
}

__m128 swapPairs32x4f(__m128 x) { return _mm_shuffle_ps(x, x, 0b10110001); }
__m128 swapLowHigh32x4f(__m128 x) { return _mm_shuffle_ps(x, x, 0b01001110); }
__m128 reverse32x4f(__m128 x) { return _mm_shuffle_ps(x, x, 0b00011011); }
__m128 rotateLeft32x4f(__m128 x) { return _mm_shuffle_ps(x, x, 0b00111001); }
__m128 rotateRight32x4f(__m128 x) { return _mm_shuffle_ps(x, x, 0b10010011); }
__m128 blendLowHigh32x4f(__m128 x, __m128 y) { return _mm_blend_ps(x, y, 0b1100); }

__m128 hadd32x4f(__m128 x, __m128 y) {
  __m128 t0 = _mm_hadd_ps(x, y);
  return _mm_shuffle_ps(t0, t0, 0b11011000);
}


double extract64x2d0(__m128d x) { return _mm_cvtsd_f64(x); }
double extract64x2d1(__m128d x) {
  __m128d temp = _mm_unpackhi_pd(x, x);
  return _mm_cvtsd_f64(temp);
}

__m128d insert64x2d0(__m128d x, double y) {
  __m128d temp = _mm_set_sd(y);
  return _mm_unpacklo_pd(temp, x);
}
__m128d insert64x2d1(__m128d x, double y) {
  __m128d temp = _mm_set_sd(y);
  return _mm_shuffle_pd(x, temp, 0);
}

__m128d swapPairs64x2d(__m128d x) { return _mm_shuffle_pd(x, x, 1); }
__m128d blendLowHigh64x2d(__m128d x, __m128d y) { return _mm_blend_pd(x, y, 0b10); }
