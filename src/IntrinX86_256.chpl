module IntrinX86_256 {
  use IntrinX86_128;
  use CTypes only c_ptr, c_ptrConst;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "wrapper-x86-256.h";
    require "wrapper-x86-256.c";
  }

  record x8664_32x8f {}
  record x8664_64x4d {}

  extern "__m256" type vec256;
  extern "__m256d" type vec256d;

  //
  // 32-bit float
  // 

  inline proc type x8664_32x8f.extract(x: vec256, param idx: int): real(32) {
    pragma "fn synchronization free"
    extern proc extract128x2f0(x: vec256): vec128;
    pragma "fn synchronization free"
    extern proc extract128x2f1(x: vec256): vec128;

    if idx == 0      then return x8664_32x4f.extract(extract128x2f0(x), 0);
    else if idx == 1 then return x8664_32x4f.extract(extract128x2f0(x), 1);
    else if idx == 2 then return x8664_32x4f.extract(extract128x2f0(x), 2);
    else if idx == 3 then return x8664_32x4f.extract(extract128x2f0(x), 3);
    else if idx == 4 then return x8664_32x4f.extract(extract128x2f1(x), 0);
    else if idx == 5 then return x8664_32x4f.extract(extract128x2f1(x), 1);
    else if idx == 6 then return x8664_32x4f.extract(extract128x2f1(x), 2);
    else if idx == 7 then return x8664_32x4f.extract(extract128x2f1(x), 3);
    else compilerError("invalid index");
  }
  inline proc type x8664_32x8f.insert(x: vec256, y: real(32), param idx: int): vec256 {
    pragma "fn synchronization free"
    extern proc insert128x2f0(x: vec256, y: vec128): vec256;
    pragma "fn synchronization free"
    extern proc insert128x2f1(x: vec256, y: vec128): vec256;
    pragma "fn synchronization free"
    extern proc extract128x2f0(x: vec256): vec128;
    pragma "fn synchronization free"
    extern proc extract128x2f1(x: vec256): vec128;

    if idx == 0      then return insert128x2f0(x, x8664_32x4f.insert(extract128x2f0(x), y, 0));
    else if idx == 1 then return insert128x2f0(x, x8664_32x4f.insert(extract128x2f0(x), y, 1));
    else if idx == 2 then return insert128x2f0(x, x8664_32x4f.insert(extract128x2f0(x), y, 2));
    else if idx == 3 then return insert128x2f0(x, x8664_32x4f.insert(extract128x2f0(x), y, 3));
    else if idx == 4 then return insert128x2f1(x, x8664_32x4f.insert(extract128x2f1(x), y, 0));
    else if idx == 5 then return insert128x2f1(x, x8664_32x4f.insert(extract128x2f1(x), y, 1));
    else if idx == 6 then return insert128x2f1(x, x8664_32x4f.insert(extract128x2f1(x), y, 2));
    else if idx == 7 then return insert128x2f1(x, x8664_32x4f.insert(extract128x2f1(x), y, 3));
    else compilerError("invalid index");
  }
  
  inline proc type x8664_32x8f.splat(x: real(32)): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_set1_ps(x: real(32)): vec256;
    return _mm256_set1_ps(x);
  }
  inline proc type x8664_32x8f.set(x: real(32), y: real(32), z: real(32), w: real(32), a: real(32), b: real(32), c: real(32), d: real(32)): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_setr_ps(x: real(32), y: real(32), z: real(32), w: real(32), a: real(32), b: real(32), c: real(32), d: real(32)): vec256;
    return _mm256_setr_ps(x, y, z, w, a, b, c, d);
  }
  inline proc type x8664_32x8f.loada(x: c_ptrConst(real(32))): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_load_ps(x: c_ptrConst(real(32))): vec256;
    return _mm256_load_ps(x);
  }
  inline proc type x8664_32x8f.storea(x: c_ptr(real(32)), y: vec256): void {
    pragma "fn synchronization free"
    extern proc _mm256_store_ps(x: c_ptr(real(32)), y: vec256): void;
    _mm256_store_ps(x, y);
  }
  inline proc type x8664_32x8f.loadu(x: c_ptrConst(real(32))): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_loadu_ps(x: c_ptrConst(real(32))): vec256;
    return _mm256_loadu_ps(x);
  }
  inline proc type x8664_32x8f.storeu(x: c_ptr(real(32)), y: vec256): void {
    pragma "fn synchronization free"
    extern proc _mm256_storeu_ps(x: c_ptr(real(32)), y: vec256): void;
    _mm256_storeu_ps(x, y);
  }

  inline proc type x8664_32x8f.swapPairs(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc swapPairs32x8f(x: vec256): vec256;
    return swapPairs32x8f(x);
  }
  inline proc type x8664_32x8f.swapLowHigh(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc swapLowHigh32x8f(x: vec256): vec256;
    return swapLowHigh32x8f(x);
  }
  inline proc type x8664_32x8f.reverse(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc reverse32x8f(x: vec256): vec256;
    return reverse32x8f(x);
  }
  inline proc type x8664_32x8f.rotateLeft(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc rotateLeft32x8f(x: vec256): vec256;
    return rotateLeft32x8f(x);
  }
  inline proc type x8664_32x8f.rotateRight(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc rotateRight32x8f(x: vec256): vec256;
    return rotateRight32x8f(x);
  }
  inline proc type x8664_32x8f.interleaveLower(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc interleaveLower32x8f(x: vec256, y: vec256): vec256;
    return interleaveLower32x8f(x, y);
  }
  inline proc type x8664_32x8f.interleaveUpper(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc interleaveUpper32x8f(x: vec256, y: vec256): vec256;
    return interleaveUpper32x8f(x, y);
  }
  inline proc type x8664_32x8f.deinterleaveLower(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc deinterleaveLower32x8f(x: vec256, y: vec256): vec256;
    return deinterleaveLower32x8f(x, y);
  }
  inline proc type x8664_32x8f.deinterleaveUpper(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc deinterleaveUpper32x8f(x: vec256, y: vec256): vec256;
    return deinterleaveUpper32x8f(x, y);
  }
  inline proc type x8664_32x8f.blendLowHigh(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc blendLowHigh32x8f(x: vec256, y: vec256): vec256;
    return blendLowHigh32x8f(x, y);
  }

  inline proc type x8664_32x8f.add(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_add_ps(x: vec256, y: vec256): vec256;
    return _mm256_add_ps(x, y);
  }
  inline proc type x8664_32x8f.sub(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_sub_ps(x: vec256, y: vec256): vec256;
    return _mm256_sub_ps(x, y);
  }
  inline proc type x8664_32x8f.mul(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_mul_ps(x: vec256, y: vec256): vec256;
    return _mm256_mul_ps(x, y);
  }
  inline proc type x8664_32x8f.div(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_div_ps(x: vec256, y: vec256): vec256;
    return _mm256_div_ps(x, y);
  }
  inline proc type x8664_32x8f.hadd(x: vec256, y: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc hadd32x8f(x: vec256, y: vec256): vec256;
    return hadd32x8f(x, y);
  }

  inline proc type x8664_32x8f.sqrt(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_sqrt_ps(x: vec256): vec256;
    return _mm256_sqrt_ps(x);
  }
  inline proc type x8664_32x8f.rsqrt(x: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_rsqrt_ps(x: vec256): vec256;
    return _mm256_rsqrt_ps(x);
  }
  inline proc type x8664_32x8f.fmadd(x: vec256, y: vec256, z: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_fmadd_ps(x: vec256, y: vec256, z: vec256): vec256;
    return _mm256_fmadd_ps(x, y, z);
  }
  inline proc type x8664_32x8f.fmsub(x: vec256, y: vec256, z: vec256): vec256 {
    pragma "fn synchronization free"
    extern proc _mm256_fmsub_ps(x: vec256, y: vec256, z: vec256): vec256;
    return _mm256_fmsub_ps(x, y, z);
  }

   //
  // 64-bit float
  //
  inline proc type x8664_64x4d.extract(x: vec256d, param idx: int): real(64) {
    pragma "fn synchronization free"
    extern proc extract128x2d0(x: vec256d): vec128d;
    pragma "fn synchronization free"
    extern proc extract128x2d1(x: vec256d): vec128d;

    if idx == 0      then return x8664_64x2d.extract(extract128x2d0(x), 0);
    else if idx == 1 then return x8664_64x2d.extract(extract128x2d0(x), 1);
    else if idx == 2 then return x8664_64x2d.extract(extract128x2d1(x), 0);
    else if idx == 3 then return x8664_64x2d.extract(extract128x2d1(x), 1);
    else compilerError("invalid index");
  }
  inline proc type x8664_64x4d.insert(x: vec256d, y: real(64), param idx: int): vec256d {
    pragma "fn synchronization free"
    extern proc insert128x2d0(x: vec256d, y: vec128d): vec256d;
    pragma "fn synchronization free"
    extern proc insert128x2d1(x: vec256d, y: vec128d): vec256d;
    pragma "fn synchronization free"
    extern proc extract128x2d0(x: vec256d): vec128d;
    pragma "fn synchronization free"
    extern proc extract128x2d1(x: vec256d): vec128d;

    if idx == 0      then return insert128x2d0(x, x8664_64x2d.insert(extract128x2d0(x), y, 0));
    else if idx == 1 then return insert128x2d0(x, x8664_64x2d.insert(extract128x2d0(x), y, 1));
    else if idx == 2 then return insert128x2d1(x, x8664_64x2d.insert(extract128x2d1(x), y, 0));
    else if idx == 3 then return insert128x2d1(x, x8664_64x2d.insert(extract128x2d1(x), y, 1));
    else compilerError("invalid index");
  }

  inline proc type x8664_64x4d.splat(x: real(64)): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_set1_pd(x: real(64)): vec256d;
    return _mm256_set1_pd(x);
  }
  inline proc type x8664_64x4d.set(x: real(64), y: real(64), z: real(64), w: real(64)): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_setr_pd(x: real(64), y: real(64), z: real(64), w: real(64)): vec256d;
    return _mm256_setr_pd(x, y, z, w);
  }
  inline proc type x8664_64x4d.loada(x: c_ptrConst(real(64))): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_load_pd(x: c_ptrConst(real(64))): vec256d;
    return _mm256_load_pd(x);
  }
  inline proc type x8664_64x4d.storea(x: c_ptr(real(64)), y: vec256d): void {
    pragma "fn synchronization free"
    extern proc _mm256_store_pd(x: c_ptr(real(64)), y: vec256d): void;
    _mm256_store_pd(x, y);
  }
  inline proc type x8664_64x4d.loadu(x: c_ptrConst(real(64))): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_loadu_pd(x: c_ptrConst(real(64))): vec256d;
    return _mm256_loadu_pd(x);
  }
  inline proc type x8664_64x4d.storeu(x: c_ptr(real(64)), y: vec256d): void {
    pragma "fn synchronization free"
    extern proc _mm256_storeu_pd(x: c_ptr(real(64)), y: vec256d): void;
    _mm256_storeu_pd(x, y);
  }

  inline proc type x8664_64x4d.swapPairs(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc swapPairs64x4d(x: vec256d): vec256d;
    return swapPairs64x4d(x);
  }
  inline proc type x8664_64x4d.swapLowHigh(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc swapLowHigh64x4d(x: vec256d): vec256d;
    return swapLowHigh64x4d(x);
  }
  inline proc type x8664_64x4d.reverse(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc reverse64x4d(x: vec256d): vec256d;
    return reverse64x4d(x);
  }
  inline proc type x8664_64x4d.rotateLeft(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc rotateLeft64x4d(x: vec256d): vec256d;
    return rotateLeft64x4d(x);
  }
  inline proc type x8664_64x4d.rotateRight(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc rotateRight64x4d(x: vec256d): vec256d;
    return rotateRight64x4d(x);
  }
  inline proc type x8664_64x4d.interleaveLower(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc interleaveLower64x4d(x: vec256d, y: vec256d): vec256d;
    return interleaveLower64x4d(x, y);
  }
  inline proc type x8664_64x4d.interleaveUpper(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc interleaveUpper64x4d(x: vec256d, y: vec256d): vec256d;
    return interleaveUpper64x4d(x, y);
  }
  inline proc type x8664_64x4d.deinterleaveLower(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc deinterleaveLower64x4d(x: vec256d, y: vec256d): vec256d;
    return deinterleaveLower64x4d(x, y);
  }
  inline proc type x8664_64x4d.deinterleaveUpper(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc deinterleaveUpper64x4d(x: vec256d, y: vec256d): vec256d;
    return deinterleaveUpper64x4d(x, y);
  }
  inline proc type x8664_64x4d.blendLowHigh(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc blendLowHigh64x4d(x: vec256d, y: vec256d): vec256d;
    return blendLowHigh64x4d(x, y);
  }

  inline proc type x8664_64x4d.add(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_add_pd(x: vec256d, y: vec256d): vec256d;
    return _mm256_add_pd(x, y);
  }
  inline proc type x8664_64x4d.sub(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_sub_pd(x: vec256d, y: vec256d): vec256d;
    return _mm256_sub_pd(x, y);
  }
  inline proc type x8664_64x4d.mul(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_mul_pd(x: vec256d, y: vec256d): vec256d;
    return _mm256_mul_pd(x, y);
  }
  inline proc type x8664_64x4d.div(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_div_pd(x: vec256d, y: vec256d): vec256d;
    return _mm256_div_pd(x, y);
  }
  inline proc type x8664_64x4d.hadd(x: vec256d, y: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_hadd_pd(x: vec256d, y: vec256d): vec256d;
    return _mm256_hadd_pd(x, y);
  }

  inline proc type x8664_64x4d.sqrt(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_sqrt_pd(x: vec256d): vec256d;
    return _mm256_sqrt_pd(x);
  }
  inline proc type x8664_64x4d.rsqrt(x: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_cvtpd_ps(x: vec256d): vec128;
    pragma "fn synchronization free"
    extern proc _mm256_cvtps_pd(x: vec128): vec256d;

    var three = this.splat(3.0);
    var half = this.splat(0.5);

    var x_ps = _mm256_cvtpd_ps(x);
    // do rsqrt at 32-bit precision
    var res = _mm256_cvtps_pd(x8664_32x4f.rsqrt(x_ps));

    // TODO: would an FMA version be faster?
    // Newton-Raphson iteration
    // q = 0.5 * x * (3 - x * res * res)
    var muls = this.mul(this.mul(x, res), res);
    res = this.mul(this.mul(half, res), this.sub(three, muls));

    return res;
  }
  inline proc type x8664_64x4d.fmadd(x: vec256d, y: vec256d, z: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_fmadd_pd(x: vec256d, y: vec256d, z: vec256d): vec256d;
    return _mm256_fmadd_pd(x, y, z);
  }
  inline proc type x8664_64x4d.fmsub(x: vec256d, y: vec256d, z: vec256d): vec256d {
    pragma "fn synchronization free"
    extern proc _mm256_fmsub_pd(x: vec256d, y: vec256d, z: vec256d): vec256d;
    return _mm256_fmsub_pd(x, y, z);
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
