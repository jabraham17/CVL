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

  record x8664_32x4f {
    proc type vecType type do return vec128;
    proc type laneType type do return real(32);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc extract32x4f0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc extract32x4f1(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc extract32x4f2(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc extract32x4f3(x: vecType): laneType;

      if idx == 0      then return extract32x4f0(x);
      else if idx == 1 then return extract32x4f1(x);
      else if idx == 2 then return extract32x4f2(x);
      else if idx == 3 then return extract32x4f3(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc insert32x4f0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc insert32x4f1(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc insert32x4f2(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc insert32x4f3(x: vecType, y: laneType): vecType;

      if idx == 0      then return insert32x4f0(x, y);
      else if idx == 1 then return insert32x4f1(x, y);
      else if idx == 2 then return insert32x4f2(x, y);
      else if idx == 3 then return insert32x4f3(x, y);
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_set1_ps(x: laneType): vecType;
      return _mm_set1_ps(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_setr_ps(x: laneType, y: laneType, z: laneType, w: laneType): vecType;
      return _mm_setr_ps(x, y, z, w);
    }
    inline proc type loada(x: c_ptrConst(real(32))): vecType {
      pragma "fn synchronization free"
      extern proc _mm_load_ps(x: c_ptrConst(real(32))): vecType;
      return _mm_load_ps(x);
    }
    inline proc type storea(x: c_ptr(real(32)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm_store_ps(x: c_ptr(real(32)), y: vecType): void;
      _mm_store_ps(x, y);
    }
    inline proc type loadu(x: c_ptrConst(real(32))): vecType {
      pragma "fn synchronization free"
      extern proc _mm_loadu_ps(x: c_ptrConst(real(32))): vecType;
      return _mm_loadu_ps(x);
    }
    inline proc type storeu(x: c_ptr(real(32)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm_storeu_ps(x: c_ptr(real(32)), y: vecType): void;
      _mm_storeu_ps(x, y);
    }

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapPairs32x4f(x: vecType): vecType;
      return swapPairs32x4f(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapLowHigh32x4f(x: vecType): vecType;
      return swapLowHigh32x4f(x);
    }
    inline proc type reverse(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc reverse32x4f(x: vecType): vecType;
      return reverse32x4f(x);
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc rotateLeft32x4f(x: vecType): vecType;
      return rotateLeft32x4f(x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc rotateRight32x4f(x: vecType): vecType;
      return rotateRight32x4f(x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_unpacklo_ps(x: vecType, y: vecType): vecType;
      return _mm_unpacklo_ps(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_unpackhi_ps(x: vecType, y: vecType): vecType;
      return _mm_unpackhi_ps(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return this.interleaveLower(this.interleaveLower(x, y), this.interleaveUpper(x, y));
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return this.interleaveUpper(this.interleaveLower(x, y), this.interleaveUpper(x, y));
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc blendLowHigh32x4f(x: vecType, y: vecType): vecType;
      return blendLowHigh32x4f(x, y);
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_add_ps(x: vecType, y: vecType): vecType;
      return _mm_add_ps(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_sub_ps(x: vecType, y: vecType): vecType;
      return _mm_sub_ps(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_mul_ps(x: vecType, y: vecType): vecType;
      return _mm_mul_ps(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_div_ps(x: vecType, y: vecType): vecType;
      return _mm_div_ps(x, y);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc hadd32x4f(x: vecType, y: vecType): vecType;
      return hadd32x4f(x, y);
    }

    inline proc type sqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_sqrt_ps(x: vecType): vecType;
      return _mm_sqrt_ps(x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_rsqrt_ps(x: vecType): vecType;
      return _mm_rsqrt_ps(x);
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_fmadd_ps(x: vecType, y: vecType, z: vecType): vecType;
      return _mm_fmadd_ps(x, y, z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_fmsub_ps(x: vecType, y: vecType, z: vecType): vecType;
      return _mm_fmsub_ps(x, y, z);
    }
  }

  record x8664_64x2d {
    proc type vecType type do return vec128d;
    proc type laneType type do return real(64);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc extract64x2d0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc extract64x2d1(x: vecType): laneType;

      if idx == 0      then return extract64x2d0(x);
      else if idx == 1 then return extract64x2d1(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc insert64x2d0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc insert64x2d1(x: vecType, y: laneType): vecType;

      if idx == 0      then return insert64x2d0(x, y);
      else if idx == 1 then return insert64x2d1(x, y);
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_set1_pd(x: laneType): vecType;
      return _mm_set1_pd(x);
    }
    inline proc type set(x: laneType, y: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_setr_pd(x: laneType, y: laneType): vecType;
      return _mm_setr_pd(x, y);
    }
    inline proc type loada(x: c_ptrConst(real(64))): vecType {
      pragma "fn synchronization free"
      extern proc _mm_load_pd(x: c_ptrConst(real(64))): vecType;
      return _mm_load_pd(x);
    }
    inline proc type storea(x: c_ptr(real(64)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm_store_pd(x: c_ptr(real(64)), y: vecType): void;
      _mm_store_pd(x, y);
    }
    inline proc type loadu(x: c_ptrConst(real(64))): vecType {
      pragma "fn synchronization free"
      extern proc _mm_loadu_pd(x: c_ptrConst(real(64))): vecType;
      return _mm_loadu_pd(x);
    }
    inline proc type storeu(x: c_ptr(real(64)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm_storeu_pd(x: c_ptr(real(64)), y: vecType): void;
      _mm_storeu_pd(x, y);
    }

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapPairs64x2d(x: vecType): vecType;
      return swapPairs64x2d(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType do return this.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do return this.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do return this.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do return this.swapPairs(x);
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_unpacklo_pd(x: vecType, y: vecType): vecType;
      return _mm_unpacklo_pd(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_unpackhi_pd(x: vecType, y: vecType): vecType;
      return _mm_unpackhi_pd(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_unpacklo_pd(x: vecType, y: vecType): vecType;
      return _mm_unpacklo_pd(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_unpackhi_pd(x: vecType, y: vecType): vecType;
      return _mm_unpackhi_pd(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc blendLowHigh64x2d(x: vecType, y: vecType): vecType;
      return blendLowHigh64x2d(x, y);
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_add_pd(x: vecType, y: vecType): vecType;
      return _mm_add_pd(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_sub_pd(x: vecType, y: vecType): vecType;
      return _mm_sub_pd(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_mul_pd(x: vecType, y: vecType): vecType;
      return _mm_mul_pd(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_div_pd(x: vecType, y: vecType): vecType;
      return _mm_div_pd(x, y);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_hadd_pd(x: vecType, y: vecType): vecType;
      return _mm_hadd_pd(x, y);
    }

    inline proc type sqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_sqrt_pd(x: vecType): vecType;
      return _mm_sqrt_pd(x);
    }
    inline proc type rsqrt(x: vecType): vecType {
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
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_fmadd_pd(x: vecType, y: vecType, z: vecType): vecType;
      return _mm_fmadd_pd(x, y, z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_fmsub_pd(x: vecType, y: vecType, z: vecType): vecType;
      return _mm_fmsub_pd(x, y, z);
    }
  }
}
