#include <x86intrin.h>

__m128 extract128x2f0(__m256 x);
__m128 extract128x2f1(__m256 x);

__m256 insert128x2f0(__m256 x, __m128 y);
__m256 insert128x2f1(__m256 x, __m128 y);

__m256 swapPairs32x8r(__m256 x);
__m256 swapLowHigh32x8r(__m256 x);
__m256 reverse32x8r(__m256 x);
__m256 rotateLeft32x8r(__m256 x);
__m256 rotateRight32x8r(__m256 x);
__m256 interleaveLower32x8r(__m256 x, __m256 y);
__m256 interleaveUpper32x8r(__m256 x, __m256 y);
__m256 deinterleaveLower32x8r(__m256 x, __m256 y);
__m256 deinterleaveUpper32x8r(__m256 x, __m256 y);
__m256 blendLowHigh32x8r(__m256 x, __m256 y);

__m256 hadd32x8r(__m256 x, __m256 y);


__m128d extract128x2d0(__m256d x);
__m128d extract128x2d1(__m256d x);

__m256d insert128x2d0(__m256d x, __m128d y);
__m256d insert128x2d1(__m256d x, __m128d y);


__m256d swapPairs64x4r(__m256d x);
__m256d swapLowHigh64x4r(__m256d x);
__m256d reverse64x4r(__m256d x);
__m256d rotateLeft64x4r(__m256d x);
__m256d rotateRight64x4r(__m256d x);
__m256d interleaveLower64x4r(__m256d x, __m256d y);
__m256d interleaveUpper64x4r(__m256d x, __m256d y);
__m256d deinterleaveLower64x4r(__m256d x, __m256d y);
__m256d deinterleaveUpper64x4r(__m256d x, __m256d y);
__m256d blendLowHigh64x4r(__m256d x, __m256d y);
