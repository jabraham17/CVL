

#include <arm_neon.h>
inline int64x2_t arm_vmulq_s64( int64x2_t a,  int64x2_t b)
{
   const auto ac = vmovn_s64(a);
   const auto pr = vmovn_s64(b);

   const auto hi = vmulq_s32(b, vrev64q_s32(a));

   return vmlal_u32(vshlq_n_s64(vpaddlq_u32(hi), 32), ac, pr);
}

inline int64x2_t arm_vmulq_s64( int64x2_t a,  int64x2_t b) {
    // Narrow the 64-bit elements in 'a' and 'b' to 32-bit elements
    int32x2_t a_narrow = vmovn_s64(a);
    int32x2_t b_narrow = vmovn_s64(b);

    // Reverse the 64-bit elements in 'a' treating them as 32-bit elements
    int32x4_t a_reversed = vrev64q_s32(vcombine_s32(a_narrow, a_narrow));

    // Multiply the 32-bit elements of 'b' with the reversed 32-bit elements of 'a'
    int32x4_t hi = vmulq_s32(vcombine_s32(b_narrow, b_narrow), a_reversed);

    // Perform pairwise addition of the 32-bit elements in 'hi' to get 64-bit elements
    int64x2_t hi_padded = vpaddlq_u32(hi);

    // Shift the 64-bit elements left by 32 bits
    int64x2_t hi_shifted = vshlq_n_s64(hi_padded, 32);

    // Perform a multiply-accumulate operation
    int64x2_t result = vmlal_u32(hi_shifted, vreinterpret_u32_s32(a_narrow), vreinterpret_u32_s32(b_narrow));

    return result;
}


