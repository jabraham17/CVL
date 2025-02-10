#include <x86intrin.h>

float extract32x4r0(__m128 x);
float extract32x4r1(__m128 x);
float extract32x4r2(__m128 x);
float extract32x4r3(__m128 x);

__m128 insert32x4r0(__m128 x, float y);
__m128 insert32x4r1(__m128 x, float y);
__m128 insert32x4r2(__m128 x, float y);
__m128 insert32x4r3(__m128 x, float y);


__m128 swapPairs32x4r(__m128 x);
__m128 swapLowHigh32x4r(__m128 x);
__m128 reverse32x4r(__m128 x);
__m128 rotateLeft32x4r(__m128 x);
__m128 rotateRight32x4r(__m128 x);
__m128 blendLowHigh32x4r(__m128 x, __m128 y);

__m128 hadd32x4r(__m128 x, __m128 y);


double extract64x2r0(__m128d x);
double extract64x2r1(__m128d x);

__m128d insert64x2r0(__m128d x, double y);
__m128d insert64x2r1(__m128d x, double y);

__m128d swapPairs64x2r(__m128d x);
__m128d blendLowHigh64x2r(__m128d x, __m128d y);
