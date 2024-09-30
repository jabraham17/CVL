module IntrinX86_128 {
  use CTypes only c_ptr, c_ptrConst, c_int;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "wrapper-x86-128.h";
    require "wrapper-x86-128.c";
  }

  record x8664_32x4f {}
  record x8664_64x2d {}

  extern "__m128" type vec128;
  extern "__m128d" type vec128d;

  //
  // 32-bit float
  //
  inline proc type x8664_32x4f.extract(x: vec128, param idx: int): real(32) {
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.extract0(x: vec128): real(32);
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.extract1(x: vec128): real(32);
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.extract2(x: vec128): real(32);
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.extract3(x: vec128): real(32);

    if idx == 0      then return extract32x4f0(x);
    else if idx == 1 then return extract32x4f1(x);
    else if idx == 2 then return extract32x4f2(x);
    else if idx == 3 then return extract32x4f3(x);
    else compilerError("invalid index");
  }
  inline proc type x8664_32x4f.insert(x: vec128, y: real(32), param idx: int): vec128 {
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.insert0(x: vec128, y: real(32)): vec128;
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.insert1(x: vec128, y: real(32)): vec128;
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.insert2(x: vec128, y: real(32)): vec128;
    pragma "fn synchronization free"
    extern proc type x8664_32x4f.insert3(x: vec128, y: real(32)): vec128;

    if idx == 0      then return insert32x4f0(x, y);
    else if idx == 1 then return insert32x4f1(x, y);
    else if idx == 2 then return insert32x4f2(x, y);
    else if idx == 3 then return insert32x4f3(x, y);
    else compilerError("invalid index");
  }

  inline proc type x8664_32x4f.splat(x: real(32)): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_set1_ps(x: real(32)): vec128;
    return _mm_set1_ps(x);
  }
  inline proc type x8664_32x4f.set(x: real(32), y: real(32), z: real(32), w: real(32)): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_setr_ps(x: real(32), y: real(32), z: real(32), w: real(32)): vec128;
    return _mm_setr_ps(x, y, z, w);
  }
  inline proc type x8664_32x4f.loada(x: c_ptrConst(real(32))): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_load_ps(x: c_ptrConst(real(32))): vec128;
    return _mm_load_ps(x);
  }
  inline proc type x8664_32x4f.storea(x: c_ptr(real(32)), y: vec128): void {
    pragma "fn synchronization free"
    extern proc _mm_store_ps(x: c_ptr(real(32)), y: vec128): void;
    _mm_store_ps(x, y);
  }
  inline proc type x8664_32x4f.loadu(x: c_ptrConst(real(32))): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_loadu_ps(x: c_ptrConst(real(32))): vec128;
    return _mm_loadu_ps(x);
  }
  inline proc type x8664_32x4f.storeu(x: c_ptr(real(32)), y: vec128): void {
    pragma "fn synchronization free"
    extern proc _mm_storeu_ps(x: c_ptr(real(32)), y: vec128): void;
    _mm_storeu_ps(x, y);
  }

  inline proc type x8664_32x4f.swapPairs(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc swapPairs32x4f(x: vec128): vec128;
    return swapPairs32x4f(x);
  }
  inline proc type x8664_32x4f.swapLowHigh(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc swapLowHigh32x4f(x: vec128): vec128;
    return swapLowHigh32x4f(x);
  }
  inline proc type x8664_32x4f.reverse(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc reverse32x4f(x: vec128): vec128;
    return reverse32x4f(x);
  }
  inline proc type x8664_32x4f.rotateLeft(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc rotateLeft32x4f(x: vec128): vec128;
    return rotateLeft32x4f(x);
  }
  inline proc type x8664_32x4f.rotateRight(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc rotateRight32x4f(x: vec128): vec128;
    return rotateRight32x4f(x);
  }
  inline proc type x8664_32x4f.interleaveLower(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_unpacklo_ps(x: vec128, y: vec128): vec128;
    return _mm_unpacklo_ps(x, y);
  }
  inline proc type x8664_32x4f.interleaveUpper(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_unpackhi_ps(x: vec128, y: vec128): vec128;
    return _mm_unpackhi_ps(x, y);
  }
  inline proc type x8664_32x4f.deinterleaveLower(x: vec128, y: vec128): vec128 do
    return this.interleaveLower(this.interleaveLower(x, y), this.interleaveUpper(x, y));
  inline proc type x8664_32x4f.deinterleaveUpper(x: vec128, y: vec128): vec128 do
    return this.interleaveUpper(this.interleaveLower(x, y), this.interleaveUpper(x, y));
  inline proc type x8664_32x4f.blendLowHigh(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc blendLowHigh32x4f(x: vec128, y: vec128): vec128;
    return blendLowHigh32x4f(x, y);
  }

  inline proc type x8664_32x4f.add(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_add_ps(x: vec128, y: vec128): vec128;
    return _mm_add_ps(x, y);
  }
  inline proc type x8664_32x4f.sub(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_sub_ps(x: vec128, y: vec128): vec128;
    return _mm_sub_ps(x, y);
  }
  inline proc type x8664_32x4f.mul(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_mul_ps(x: vec128, y: vec128): vec128;
    return _mm_mul_ps(x, y);
  }
  inline proc type x8664_32x4f.div(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_div_ps(x: vec128, y: vec128): vec128;
    return _mm_div_ps(x, y);
  }
  inline proc type x8664_32x4f.hadd(x: vec128, y: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc hadd32x4f(x: vec128, y: vec128): vec128;
    return hadd32x4f(x, y);
  }

  inline proc type x8664_32x4f.sqrt(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_sqrt_ps(x: vec128): vec128;
    return _mm_sqrt_ps(x);
  }
  inline proc type x8664_32x4f.rsqrt(x: vec128): vec128 {
    pragma "fn synchronization free"
    extern proc _mm_rsqrt_ps(x: vec128): vec128;
    return _mm_rsqrt_ps(x);
  }

  //
  // 64-bit float
  // 
  inline proc type x8664_64x2d.extract(x: vec128d, param idx: int): real(64) {
    pragma "fn synchronization free"
    extern proc type x8664_64x2d.extract0(x: vec128d): real(64);
    pragma "fn synchronization free"
    extern proc type x8664_64x2d.extract1(x: vec128d): real(64);

    if idx == 0      then return extract64x2d0(x);
    else if idx == 1 then return extract64x2d1(x);
    else compilerError("invalid index");
  }
  inline proc type x8664_64x2d.insert(x: vec128d, y: real(64), param idx: int): vec128d {
    pragma "fn synchronization free"
    extern proc type x8664_64x2d.insert0(x: vec128d, y: real(64)): vec128d;
    pragma "fn synchronization free"
    extern proc type x8664_64x2d.insert1(x: vec128d, y: real(64)): vec128d;

    if idx == 0      then return insert64x2d0(x, y);
    else if idx == 1 then return insert64x2d1(x, y);
    else compilerError("invalid index");
  }

  inline proc type x8664_64x2d.splat(x: real(64)): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_set1_pd(x: real(64)): vec128d;
    return _mm_set1_pd(x);
  }
  inline proc type x8664_64x2d.set(x: real(64), y: real(64)): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_setr_pd(x: real(64), y: real(64)): vec128d;
    return _mm_setr_pd(x, y);
  }
  inline proc type x8664_64x2d.loada(x: c_ptrConst(real(64))): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_load_pd(x: c_ptrConst(real(64))): vec128d;
    return _mm_load_pd(x);
  }
  inline proc type x8664_64x2d.storea(x: c_ptr(real(64)), y: vec128d): void {
    pragma "fn synchronization free"
    extern proc _mm_store_pd(x: c_ptr(real(64)), y: vec128d): void;
    _mm_store_pd(x, y);
  }
  inline proc type x8664_64x2d.loadu(x: c_ptrConst(real(64))): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_loadu_pd(x: c_ptrConst(real(64))): vec128d;
    return _mm_loadu_pd(x);
  }
  inline proc type x8664_64x2d.storeu(x: c_ptr(real(64)), y: vec128d): void {
    pragma "fn synchronization free"
    extern proc _mm_storeu_pd(x: c_ptr(real(64)), y: vec128d): void;
    _mm_storeu_pd(x, y);
  }

  inline proc type x8664_64x2d.swapPairs(x: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc swapPairs64x2d(x: vec128d): vec128d;
    return swapPairs64x2d(x);
  }
  inline proc type x8664_64x2d.swapLowHigh(x: vec128d): vec128d do return this.swapPairs(x);
  inline proc type x8664_64x2d.reverse(x: vec128d): vec128d do return this.swapPairs(x);
  inline proc type x8664_64x2d.rotateLeft(x: vec128d): vec128d do return this.swapPairs(x);
  inline proc type x8664_64x2d.rotateRight(x: vec128d): vec128d do return this.swapPairs(x);
  inline proc type x8664_64x2d.interleaveLower(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_unpacklo_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_unpacklo_pd(x, y);
  }
  inline proc type x8664_64x2d.interleaveUpper(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_unpackhi_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_unpackhi_pd(x, y);
  }
  inline proc type x8664_64x2d.deinterleaveLower(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_unpacklo_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_unpacklo_pd(x, y);
  }
  inline proc type x8664_64x2d.deinterleaveUpper(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_unpackhi_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_unpackhi_pd(x, y);
  }
  inline proc type x8664_64x2d.blendLowHigh(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc blendLowHigh64x2d(x: vec128d, y: vec128d): vec128d;
    return blendLowHigh64x2d(x, y);
  }

  inline proc type x8664_64x2d.add(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_add_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_add_pd(x, y);
  }
  inline proc type x8664_64x2d.sub(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_sub_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_sub_pd(x, y);
  }
  inline proc type x8664_64x2d.mul(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_mul_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_mul_pd(x, y);
  }
  inline proc type x8664_64x2d.div(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_div_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_div_pd(x, y);
  }
  inline proc type x8664_64x2d.hadd(x: vec128d, y: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_hadd_pd(x: vec128d, y: vec128d): vec128d;
    return _mm_hadd_pd(x, y);
  }

  inline proc type x8664_64x2d.sqrt(x: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_sqrt_pd(x: vec128d): vec128d;
    return _mm_sqrt_pd(x);
  }
  inline proc type x8664_64x2d.rsqrt(x: vec128d): vec128d {
    pragma "fn synchronization free"
    extern proc _mm_cvtpd_ps(x: vec128d): vec128;
    pragma "fn synchronization free"
    extern proc _mm_cvtps_pd(x: vec128): vec128d;

    var three = this.splat(3.0);
    var half = this.splat(0.5);

    var x_ps = _mm_cvtpd_ps(x);
    // do rsqrt at 32-bit precision
    var res = _mm_cvtps_pd(x8664_32x4f.rsqrt(x_ps));

    // TODO: would an FMA version be faster?
    // Newton-Raphson iteration
    // q = 0.5 * x * (3 - x * res * res)
    var muls = this.mul(this.mul(x, res), res);
    res = this.mul(this.mul(half, res), this.sub(three, muls));

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
