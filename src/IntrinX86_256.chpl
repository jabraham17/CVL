module IntrinX86_256 {
  use IntrinX86_128;
  use CTypes only c_ptr, c_ptrConst;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "wrapper-x86-256.h";
    require "wrapper-x86-256.c";
  }

  extern "__m256" type vec256;
  extern "__m256d" type vec256d;

  proc vec256.serialize(writer, ref serializer) throws {
      var s: string;
      var sep = "";
      for param i in 0..#8 {
        writer.write(sep, extract32x8f(this, i));
        sep = ", ";
      }
      return s;
    }

  //
  // 32-bit float
  // 

  inline proc extract32x8f(x: vec256, param idx: int): real(32) {
    pragma "fn synchronization free"
    extern proc extract128x2f0(x: vec256): vec128;
    pragma "fn synchronization free"
    extern proc extract128x2f1(x: vec256): vec128;

    if idx == 0      then return extract32x4f(extract128x2f0(x), 0);
    else if idx == 1 then return extract32x4f(extract128x2f0(x), 1);
    else if idx == 2 then return extract32x4f(extract128x2f0(x), 2);
    else if idx == 3 then return extract32x4f(extract128x2f0(x), 3);
    else if idx == 4 then return extract32x4f(extract128x2f1(x), 0);
    else if idx == 5 then return extract32x4f(extract128x2f1(x), 1);
    else if idx == 6 then return extract32x4f(extract128x2f1(x), 2);
    else if idx == 7 then return extract32x4f(extract128x2f1(x), 3);
    else compilerError("invalid index");
  }
  inline proc insert32x8f(x: vec256, y: real(32), param idx: int): vec256 {
    pragma "fn synchronization free"
    extern proc insert128x2f0(x: vec256, y: vec128): vec256;
    pragma "fn synchronization free"
    extern proc insert128x2f1(x: vec256, y: vec128): vec256;
    pragma "fn synchronization free"
    extern proc extract128x2f0(x: vec256): vec128;
    pragma "fn synchronization free"
    extern proc extract128x2f1(x: vec256): vec128;

    if idx == 0      then return insert128x2f0(x, insert32x4f(extract128x2f0(x), y, 0));
    else if idx == 1 then return insert128x2f0(x, insert32x4f(extract128x2f0(x), y, 1));
    else if idx == 2 then return insert128x2f0(x, insert32x4f(extract128x2f0(x), y, 2));
    else if idx == 3 then return insert128x2f0(x, insert32x4f(extract128x2f0(x), y, 3));
    else if idx == 4 then return insert128x2f1(x, insert32x4f(extract128x2f1(x), y, 0));
    else if idx == 5 then return insert128x2f1(x, insert32x4f(extract128x2f1(x), y, 1));
    else if idx == 6 then return insert128x2f1(x, insert32x4f(extract128x2f1(x), y, 2));
    else if idx == 7 then return insert128x2f1(x, insert32x4f(extract128x2f1(x), y, 3));
    else compilerError("invalid index");
  }
  
  pragma "fn synchronization free"
  extern "_mm256_set1_ps" proc splat32x8f(x: real(32)): vec256;
  pragma "fn synchronization free"
  extern "_mm256_setr_ps" proc set32x8f(x: real(32), y: real(32), z: real(32), w: real(32), a: real(32), b: real(32), c: real(32), d: real(32)): vec256;
  pragma "fn synchronization free"
  extern "_mm256_load_ps" proc loada32x8f(x: c_ptrConst(real(32))): vec256;
  pragma "fn synchronization free"
  extern "_mm256_store_ps" proc storea32x8f(x: c_ptr(real(32)), y: vec256): void;
  pragma "fn synchronization free"
  extern "_mm256_loadu_ps" proc loadu32x8f(x: c_ptrConst(real(32))): vec256;
  pragma "fn synchronization free"
  extern "_mm256_storeu_ps" proc storeu32x8f(x: c_ptr(real(32)), y: vec256): void;

  pragma "fn synchronization free"
  extern proc swapPairs32x8f(x: vec256): vec256;
  pragma "fn synchronization free"
  extern proc swapLowHigh32x8f(x: vec256): vec256;
  pragma "fn synchronization free"
  extern proc reverse32x8f(x: vec256): vec256;
  pragma "fn synchronization free"
  extern proc rotateLeft32x8f(x: vec256): vec256;
  pragma "fn synchronization free"
  extern proc rotateRight32x8f(x: vec256): vec256;
  pragma "fn synchronization free"
  extern proc interleaveLower32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern proc interleaveUpper32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern proc deinterleaveLower32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern proc deinterleaveUpper32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern proc blendLowHigh32x8f(x: vec256, y: vec256): vec256;

  pragma "fn synchronization free"
  extern "_mm256_add_ps" proc add32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern "_mm256_sub_ps" proc sub32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern "_mm256_mul_ps" proc mul32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern "_mm256_div_ps" proc div32x8f(x: vec256, y: vec256): vec256;
  pragma "fn synchronization free"
  extern proc hadd32x8f(x: vec256, y: vec256): vec256;

  pragma "fn synchronization free"
  extern "_mm256_sqrt_ps" proc sqrt32x8f(x: vec256): vec256;
  pragma "fn synchronization free"
  extern "_mm256_rsqrt_ps" proc rsqrt32x8f(x: vec256): vec256;

   //
  // 64-bit float
  //
  inline proc extract64x4d(x: vec256d, param idx: int): real(64) {
    pragma "fn synchronization free"
    extern proc extract128x2d0(x: vec256d): vec128d;
    pragma "fn synchronization free"
    extern proc extract128x2d1(x: vec256d): vec128d;

    if idx == 0      then return extract64x2d(extract128x2d0(x), 0);
    else if idx == 1 then return extract64x2d(extract128x2d0(x), 1);
    else if idx == 2 then return extract64x2d(extract128x2d1(x), 0);
    else if idx == 3 then return extract64x2d(extract128x2d1(x), 1);
    else compilerError("invalid index");
  }
  inline proc insert64x4d(x: vec256d, y: real(64), param idx: int): vec256d {
    pragma "fn synchronization free"
    extern proc insert128x2d0(x: vec256d, y: vec128d): vec256d;
    pragma "fn synchronization free"
    extern proc insert128x2d1(x: vec256d, y: vec128d): vec256d;
    pragma "fn synchronization free"
    extern proc extract128x2d0(x: vec256d): vec128d;
    pragma "fn synchronization free"
    extern proc extract128x2d1(x: vec256d): vec128d;

    if idx == 0      then return insert128x2d0(x, insert64x2d(extract128x2d0(x), y, 0));
    else if idx == 1 then return insert128x2d0(x, insert64x2d(extract128x2d0(x), y, 1));
    else if idx == 2 then return insert128x2d1(x, insert64x2d(extract128x2d1(x), y, 0));
    else if idx == 3 then return insert128x2d1(x, insert64x2d(extract128x2d1(x), y, 1));
    else compilerError("invalid index");
  }

  pragma "fn synchronization free"
  extern "_mm256_set1_pd" proc splat64x4d(x: real(64)): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_setr_pd" proc set64x4d(x: real(64), y: real(64), z: real(64), w: real(64)): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_load_pd" proc loada64x4d(x: c_ptrConst(real(64))): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_store_pd" proc storea64x4d(x: c_ptr(real(64)), y: vec256d): void;
  pragma "fn synchronization free"
  extern "_mm256_loadu_pd" proc loadu64x4d(x: c_ptrConst(real(64))): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_storeu_pd" proc storeu64x4d(x: c_ptr(real(64)), y: vec256d): void;

  pragma "fn synchronization free"
  extern proc swapPairs64x4d(x: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc swapLowHigh64x4d(x: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc reverse64x4d(x: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc rotateLeft64x4d(x: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc rotateRight64x4d(x: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc interleaveLower64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc interleaveUpper64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc deinterleaveLower64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc deinterleaveUpper64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern proc blendLowHigh64x4d(x: vec256d, y: vec256d): vec256d;

  pragma "fn synchronization free"
  extern "_mm256_add_pd" proc add64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_sub_pd" proc sub64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_mul_pd" proc mul64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_div_pd" proc div64x4d(x: vec256d, y: vec256d): vec256d;
  pragma "fn synchronization free"
  extern "_mm256_hadd_pd" proc hadd64x4d(x: vec256d, y: vec256d): vec256d;

  pragma "fn synchronization free"
  extern "_mm256_sqrt_pd" proc sqrt64x4d(x: vec256d): vec256d;
  inline proc rsqrt64x4d(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_cvtpd_ps(x: vec256d): vec128;
    pragma "fn synchronization free"
    extern proc _mm256_cvtps_pd(x: vec128): vec256d;

    var three = splat64x4d(3.0);
    var half = splat64x4d(0.5);

    var x_ps = _mm256_cvtpd_ps(x);
    // do rsqrt at 32-bit precision
    var res = _mm256_cvtps_pd(rsqrt32x4f(x_ps));

    // TODO: would an FMA version be faster?
    // Newton-Raphson iteration
    // q = 0.5 * x * (3 - x * res * res)
    var muls = mul64x4d(mul64x4d(x, res), res);
    res = mul64x4d(mul64x4d(half, res), sub64x4d(three, muls));

    return res;
  }

  inline operator:(x: vec256d, type t: vec256) {
    pragma "fn synchronization free"
    extern proc _mm256_castpd_ps(x: vec256d): vec256;
    return _mm256_castpd_ps(x);
  }
  inline operator:(x: vec256, type t: vec256d) {
    pragma "fn synchronization free"
    extern proc _mm256_castps_pd(x: vec256): vec256d;
    return _mm256_castps_pd(x);
  }

}
