#include "wrapper-x86-256.h"

__m128 extract128x2f0(__m256 x) { return _mm256_extractf128_ps(x, 0); }
__m128 extract128x2f1(__m256 x) { return _mm256_extractf128_ps(x, 1); }

__m256 insert128x2f0(__m256 x, __m128 y) { return _mm256_insertf128_ps(x, y, 0); }
__m256 insert128x2f1(__m256 x, __m128 y) { return _mm256_insertf128_ps(x, y, 1); }

__m128d extract128x2d0(__m256d x) { return _mm256_extractf128_pd(x, 0); }
__m128d extract128x2d1(__m256d x) { return _mm256_extractf128_pd(x, 1); }

__m256d insert128x2d0(__m256d x, __m128d y) { return _mm256_insertf128_pd(x, y, 0); }
__m256d insert128x2d1(__m256d x, __m128d y) { return _mm256_insertf128_pd(x, y, 1); }
