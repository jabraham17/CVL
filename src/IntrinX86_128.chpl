module IntrinX86_128 {
  use CTypes only c_ptr, c_ptrConst, c_int;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "wrapper-x86-128.h";
    require "wrapper-x86-128.c";
  }

  extern "__m128" type vec128;
  extern "__m128d" type vec128d;

  //
  // 32-bit float
  //
  inline proc extract32x4f(x: vec128, param idx: int): real(32) {
    pragma "fn synchronization free"
    extern proc extract32x4f0(x: vec128): real(32);
    pragma "fn synchronization free"
    extern proc extract32x4f1(x: vec128): real(32);
    pragma "fn synchronization free"
    extern proc extract32x4f2(x: vec128): real(32);
    pragma "fn synchronization free"
    extern proc extract32x4f3(x: vec128): real(32);

    if idx == 0      then return extract32x4f0(x);
    else if idx == 1 then return extract32x4f1(x);
    else if idx == 2 then return extract32x4f2(x);
    else if idx == 3 then return extract32x4f3(x);
    else compilerError("invalid index");
  }
  inline proc insert32x4f(x: vec128, y: real(32), param idx: int): vec128 {
    pragma "fn synchronization free"
    extern proc insert32x4f0(x: vec128, y: real(32)): vec128;
    pragma "fn synchronization free"
    extern proc insert32x4f1(x: vec128, y: real(32)): vec128;
    pragma "fn synchronization free"
    extern proc insert32x4f2(x: vec128, y: real(32)): vec128;
    pragma "fn synchronization free"
    extern proc insert32x4f3(x: vec128, y: real(32)): vec128;

    if idx == 0      then return insert32x4f0(x, y);
    else if idx == 1 then return insert32x4f1(x, y);
    else if idx == 2 then return insert32x4f2(x, y);
    else if idx == 3 then return insert32x4f3(x, y);
    else compilerError("invalid index");
  }

  pragma "fn synchronization free"
  extern "_mm_set1_ps" proc splat32x4f(x: real(32)): vec128;
  pragma "fn synchronization free"
  extern "_mm_setr_ps" proc set32x4f(x: real(32), y: real(32), z: real(32), w: real(32)): vec128;
  pragma "fn synchronization free"
  extern "_mm_load_ps" proc loada32x4f(x: c_ptrConst(real(32))): vec128;
  pragma "fn synchronization free"
  extern "_mm_store_ps" proc storea32x4f(x: c_ptr(real(32)), y: vec128): void;
  pragma "fn synchronization free"
  extern "_mm_loadu_ps" proc loadu32x4f(x: c_ptrConst(real(32))): vec128;
  pragma "fn synchronization free"
  extern "_mm_storeu_ps" proc storeu32x4f(x: c_ptr(real(32)), y: vec128): void;

  pragma "fn synchronization free"
  extern proc swapPairs32x4f(x: vec128): vec128;
  pragma "fn synchronization free"
  extern proc swapLowHigh32x4f(x: vec128): vec128;
  pragma "fn synchronization free"
  extern proc reverse32x4f(x: vec128): vec128;
  pragma "fn synchronization free"
  extern proc rotateLeft32x4f(x: vec128): vec128;
  pragma "fn synchronization free"
  extern proc rotateRight32x4f(x: vec128): vec128;
  pragma "fn synchronization free"
  extern "_mm_unpacklo_ps" proc interleaveLower32x4f(x: vec128, y: vec128): vec128;
  pragma "fn synchronization free"
  extern "_mm_unpackhi_ps" proc interleaveUpper32x4f(x: vec128, y: vec128): vec128;
  inline proc deinterleaveLower32x4f(x: vec128, y: vec128): vec128 do
    return interleaveLower32x4f(interleaveLower32x4f(x, y), interleaveUpper32x4f(x, y));
  inline proc deinterleaveUpper32x4f(x: vec128, y: vec128): vec128 do
    return interleaveUpper32x4f(interleaveLower32x4f(x, y), interleaveUpper32x4f(x, y));
  pragma "fn synchronization free"
  extern proc blendLowHigh32x4f(x: vec128, y: vec128): vec128;

  pragma "fn synchronization free"
  extern "_mm_add_ps" proc add32x4f(x: vec128, y: vec128): vec128;
  pragma "fn synchronization free"
  extern "_mm_sub_ps" proc sub32x4f(x: vec128, y: vec128): vec128;
  pragma "fn synchronization free"
  extern "_mm_mul_ps" proc mul32x4f(x: vec128, y: vec128): vec128;
  pragma "fn synchronization free"
  extern "_mm_div_ps" proc div32x4f(x: vec128, y: vec128): vec128;
  pragma "fn synchronization free"
  extern proc hadd32x4f(x: vec128, y: vec128): vec128;

  pragma "fn synchronization free"
  extern "_mm_sqrt_ps" proc sqrt32x4f(x: vec128): vec128;
  pragma "fn synchronization free"
  extern "_mm_rsqrt_ps" proc rsqrt32x4f(x: vec128): vec128;

  //
  // 64-bit float
  // 
  inline proc extract64x2d(x: vec128d, param idx: int): real(64) {
    pragma "fn synchronization free"
    extern proc extract64x2d0(x: vec128d): real(64);
    pragma "fn synchronization free"
    extern proc extract64x2d1(x: vec128d): real(64);

    if idx == 0      then return extract64x2d0(x);
    else if idx == 1 then return extract64x2d1(x);
    else compilerError("invalid index");
  }
  inline proc insert64x2d(x: vec128d, y: real(64), param idx: int): vec128d {
    pragma "fn synchronization free"
    extern proc insert64x2d0(x: vec128d, y: real(64)): vec128d;
    pragma "fn synchronization free"
    extern proc insert64x2d1(x: vec128d, y: real(64)): vec128d;

    if idx == 0      then return insert64x2d0(x, y);
    else if idx == 1 then return insert64x2d1(x, y);
    else compilerError("invalid index");
  }

  pragma "fn synchronization free"
  extern "_mm_set1_pd" proc splat64x2d(x: real(64)): vec128d;
  pragma "fn synchronization free"
  extern "_mm_setr_pd" proc set64x2d(x: real(64), y: real(64)): vec128d;
  pragma "fn synchronization free"
  extern "_mm_load_pd" proc loada64x2d(x: c_ptrConst(real(64))): vec128d;
  pragma "fn synchronization free"
  extern "_mm_store_pd" proc storea64x2d(x: c_ptr(real(64)), y: vec128d): void;
  pragma "fn synchronization free"
  extern "_mm_loadu_pd" proc loadu64x2d(x: c_ptrConst(real(64))): vec128d;
  pragma "fn synchronization free"
  extern "_mm_storeu_pd" proc storeu64x2d(x: c_ptr(real(64)), y: vec128d): void;

  pragma "fn synchronization free"
  extern proc swapPairs64x2d(x: vec128d): vec128d;
  inline proc swapLowHigh64x2d(x: vec128d): vec128d do return swapPairs64x2d(x);
  inline proc reverse64x2d(x: vec128d): vec128d do return swapPairs64x2d(x);
  inline proc rotateLeft64x2d(x: vec128d): vec128d do return swapPairs64x2d(x);
  inline proc rotateRight64x2d(x: vec128d): vec128d do return swapPairs64x2d(x);
  pragma "fn synchronization free"
  extern "_mm_unpacklo_pd" proc interleaveLower64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_unpackhi_pd" proc interleaveUpper64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_unpacklo_pd" proc deinterleaveLower64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_unpackhi_pd" proc deinterleaveUpper64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern proc blendLowHigh64x2d(x: vec128d, y: vec128d): vec128d;

  pragma "fn synchronization free"
  extern "_mm_add_pd" proc add64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_sub_pd" proc sub64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_mul_pd" proc mul64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_div_pd" proc div64x2d(x: vec128d, y: vec128d): vec128d;
  pragma "fn synchronization free"
  extern "_mm_hadd_pd" proc hadd64x2d(x: vec128d, y: vec128d): vec128d;

  pragma "fn synchronization free"
  extern "_mm_sqrt_pd" proc sqrt64x2d(x: vec128d): vec128d;
  inline proc rsqrt64x2d(x: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_cvtpd_ps(x: vec128d): vec128;
    pragma "fn synchronization free"
    extern proc _mm_cvtps_pd(x: vec128): vec128d;

    var three = splat64x2d(3.0);
    var half = splat64x2d(0.5);

    var x_ps = _mm_cvtpd_ps(x);
    // do rsqrt at 32-bit precision
    var res = _mm_cvtps_pd(rsqrt32x4f(x_ps));

    // TODO: would an FMA version be faster?
    // Newton-Raphson iteration
    // q = 0.5 * x * (3 - x * res * res)
    var muls = mul64x2d(mul64x2d(x, res), res);
    res = mul64x2d(mul64x2d(half, res), sub64x2d(three, muls));

    return res;
  }

  inline operator:(x: vec128d, type t: vec128) {
    pragma "fn synchronization free"
    extern proc _mm_castpd_ps(x: vec128d): vec128;
    return _mm_castpd_ps(x);
  }
  inline operator:(x: vec128, type t: vec128d) {
    pragma "fn synchronization free"
    extern proc _mm_castps_pd(x: vec128): vec128d;
    return _mm_castps_pd(x);
  }
}
