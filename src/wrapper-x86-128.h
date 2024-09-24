#include <x86intrin.h>

float extract32x4f0(__m128 x);
float extract32x4f1(__m128 x);
float extract32x4f2(__m128 x);
float extract32x4f3(__m128 x);

__m128 insert32x4f0(__m128 x, float y);
__m128 insert32x4f1(__m128 x, float y);
__m128 insert32x4f2(__m128 x, float y);
__m128 insert32x4f3(__m128 x, float y);


__m128 swapPairs32x4f(__m128 x);
__m128 swapLowHigh32x4f(__m128 x);
__m128 reverse32x4f(__m128 x);
__m128 rotateLeft32x4f(__m128 x);
__m128 rotateRight32x4f(__m128 x);
__m128 blendLowHigh32x4f(__m128 x, __m128 y);

__m128 hadd32x4f(__m128 x, __m128 y);


double extract64x2d0(__m128d x);
double extract64x2d1(__m128d x);

__m128d insert64x2d0(__m128d x, double y);
__m128d insert64x2d1(__m128d x, double y);

__m128d swapPairs64x2d(__m128d x);
__m128d blendLowHigh64x2d(__m128d x, __m128d y);
