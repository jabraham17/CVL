#include <arm_neon.h>

#include "wrapper-arm64-128-int8.h"
#include "wrapper-arm64-128-int16.h"
#include "wrapper-arm64-128-int32.h"
#include "wrapper-arm64-128-int64.h"
#include "wrapper-arm64-128-real32.h"
#include "wrapper-arm64-128-real64.h"


// for whatever reason, these are missing from the arm_neon.h header
static inline uint64x2_t vmvnq_u64(uint64x2_t v) { return ~v; }
static inline int64x2_t vmvnq_s64(int64x2_t v) { return ~v; }
