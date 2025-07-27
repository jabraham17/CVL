#include <x86intrin.h>

__m128 min_epi64(__m128i a, __m128i b) {
    __m128i cmp = _mm_cmpgt_epi64(a, b);
    return _mm_blendv_ps(_mm_castsi128_ps(b), _mm_castsi128_ps(a), _mm_castsi128_ps(cmp));
}


// select the valye from a or b based on the mask, bit by bit
__m128i select(__m128i a, __m128i b, __m128i mask) {
    return _mm_or_si128(_mm_and_si128(mask, a), _mm_andnot_si128(mask, b));
}
