#include <x86intrin.h>

__m128 extract128x2f0(__m256 x);
__m128 extract128x2f1(__m256 x);

__m256 insert128x2f0(__m256 x, __m128 y);
__m256 insert128x2f1(__m256 x, __m128 y);

__m128d extract128x2d0(__m256d x);
__m128d extract128x2d1(__m256d x);

__m256d insert128x2d0(__m256d x, __m128d y);
__m256d insert128x2d1(__m256d x, __m128d y);
