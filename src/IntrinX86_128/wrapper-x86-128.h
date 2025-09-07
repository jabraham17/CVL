#include <x86intrin.h>

#include "wrapper-x86-128-int8.h"
#include "wrapper-x86-128-int16.h"
#include "wrapper-x86-128-int32.h"
#include "wrapper-x86-128-int64.h"
#include "wrapper-x86-128-real32.h"
#include "wrapper-x86-128-real64.h"


// workarounds for Chapel C codegen bugs, see IntrinX86_128.chpl
typedef __m128  vec32x4r;
typedef __m128d vec64x2r;
typedef __m128i vec8x16i;
typedef __m128i vec16x8i;
typedef __m128i vec32x4i;
typedef __m128i vec64x2i;
typedef __m128i vec8x16u;
typedef __m128i vec16x8u;
typedef __m128i vec32x4u;
typedef __m128i vec64x2u;
