@chplcheck.ignore("PascalCaseModules")
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

  extern "__m128" type vec128;
  extern "__m128d" type vec128d;

  @chplcheck.ignore("UnusedFormal")
  inline operator:(x: vec256d, type t: vec256) {
    pragma "fn synchronization free"
    extern proc _mm256_castpd_ps(x: vec256d): vec256;
    return _mm256_castpd_ps(x);
  }
  @chplcheck.ignore("UnusedFormal")
  inline operator:(x: vec256, type t: vec256d) {
    pragma "fn synchronization free"
    extern proc _mm256_castps_pd(x: vec256): vec256d;
    return _mm256_castps_pd(x);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_32x8r {
    proc type vecType type do return vec256;
    proc type laneType type do return real(32);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc extract128x2f0(x: vecType): vec128;
      pragma "fn synchronization free"
      extern proc extract128x2f1(x: vecType): vec128;

      if idx == 0      then return x8664_32x4r.extract(extract128x2f0(x), 0);
      else if idx == 1 then return x8664_32x4r.extract(extract128x2f0(x), 1);
      else if idx == 2 then return x8664_32x4r.extract(extract128x2f0(x), 2);
      else if idx == 3 then return x8664_32x4r.extract(extract128x2f0(x), 3);
      else if idx == 4 then return x8664_32x4r.extract(extract128x2f1(x), 0);
      else if idx == 5 then return x8664_32x4r.extract(extract128x2f1(x), 1);
      else if idx == 6 then return x8664_32x4r.extract(extract128x2f1(x), 2);
      else if idx == 7 then return x8664_32x4r.extract(extract128x2f1(x), 3);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc insert128x2f0(x: vecType, y: vec128): vecType;
      pragma "fn synchronization free"
      extern proc insert128x2f1(x: vecType, y: vec128): vecType;
      pragma "fn synchronization free"
      extern proc extract128x2f0(x: vecType): vec128;
      pragma "fn synchronization free"
      extern proc extract128x2f1(x: vecType): vec128;

      if idx == 0      then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 0));
      else if idx == 1 then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 1));
      else if idx == 2 then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 2));
      else if idx == 3 then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 3));
      else if idx == 4 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 0));
      else if idx == 5 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 1));
      else if idx == 6 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 2));
      else if idx == 7 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 3));
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_set1_ps(x: laneType): vecType;
      return _mm256_set1_ps(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_setr_ps(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType): vecType;
      return _mm256_setr_ps(x, y, z, w, a, b, c, d);
    }
    inline proc type loada(x: c_ptrConst(real(32))): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_load_ps(x: c_ptrConst(real(32))): vecType;
      return _mm256_load_ps(x);
    }
    inline proc type storea(x: c_ptr(real(32)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm256_store_ps(x: c_ptr(real(32)), y: vecType): void;
      _mm256_store_ps(x, y);
    }
    inline proc type loadu(x: c_ptrConst(real(32))): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_loadu_ps(x: c_ptrConst(real(32))): vecType;
      return _mm256_loadu_ps(x);
    }
    inline proc type storeu(x: c_ptr(real(32)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm256_storeu_ps(x: c_ptr(real(32)), y: vecType): void;
      _mm256_storeu_ps(x, y);
    }

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapPairs32x8r(x: vecType): vecType;
      return swapPairs32x8r(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapLowHigh32x8r(x: vecType): vecType;
      return swapLowHigh32x8r(x);
    }
    inline proc type reverse(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc reverse32x8r(x: vecType): vecType;
      return reverse32x8r(x);
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc rotateLeft32x8r(x: vecType): vecType;
      return rotateLeft32x8r(x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc rotateRight32x8r(x: vecType): vecType;
      return rotateRight32x8r(x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc interleaveLower32x8r(x: vecType, y: vecType): vecType;
      return interleaveLower32x8r(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc interleaveUpper32x8r(x: vecType, y: vecType): vecType;
      return interleaveUpper32x8r(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc deinterleaveLower32x8r(x: vecType, y: vecType): vecType;
      return deinterleaveLower32x8r(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc deinterleaveUpper32x8r(x: vecType, y: vecType): vecType;
      return deinterleaveUpper32x8r(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc blendLowHigh32x8r(x: vecType, y: vecType): vecType;
      return blendLowHigh32x8r(x, y);
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_add_ps(x: vecType, y: vecType): vecType;
      return _mm256_add_ps(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_sub_ps(x: vecType, y: vecType): vecType;
      return _mm256_sub_ps(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_mul_ps(x: vecType, y: vecType): vecType;
      return _mm256_mul_ps(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_div_ps(x: vecType, y: vecType): vecType;
      return _mm256_div_ps(x, y);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc hadd32x8r(x: vecType, y: vecType): vecType;
      return hadd32x8r(x, y);
    }

    inline proc type sqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_sqrt_ps(x: vecType): vecType;
      return _mm256_sqrt_ps(x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_rsqrt_ps(x: vecType): vecType;
      return _mm256_rsqrt_ps(x);
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_fmadd_ps(x: vecType, y: vecType, z: vecType): vecType;
      return _mm256_fmadd_ps(x, y, z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_fmsub_ps(x: vecType, y: vecType, z: vecType): vecType;
      return _mm256_fmsub_ps(x, y, z);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_64x4r {
    proc type vecType type do return vec256d;
    proc type laneType type do return real(64);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc extract128x2d0(x: vecType): vec128d;
      pragma "fn synchronization free"
      extern proc extract128x2d1(x: vecType): vec128d;

      if idx == 0      then return x8664_64x2r.extract(extract128x2d0(x), 0);
      else if idx == 1 then return x8664_64x2r.extract(extract128x2d0(x), 1);
      else if idx == 2 then return x8664_64x2r.extract(extract128x2d1(x), 0);
      else if idx == 3 then return x8664_64x2r.extract(extract128x2d1(x), 1);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc insert128x2d0(x: vecType, y: vec128d): vecType;
      pragma "fn synchronization free"
      extern proc insert128x2d1(x: vecType, y: vec128d): vecType;
      pragma "fn synchronization free"
      extern proc extract128x2d0(x: vecType): vec128d;
      pragma "fn synchronization free"
      extern proc extract128x2d1(x: vecType): vec128d;

      if idx == 0      then return insert128x2d0(x, x8664_64x2r.insert(extract128x2d0(x), y, 0));
      else if idx == 1 then return insert128x2d0(x, x8664_64x2r.insert(extract128x2d0(x), y, 1));
      else if idx == 2 then return insert128x2d1(x, x8664_64x2r.insert(extract128x2d1(x), y, 0));
      else if idx == 3 then return insert128x2d1(x, x8664_64x2r.insert(extract128x2d1(x), y, 1));
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_set1_pd(x: laneType): vecType;
      return _mm256_set1_pd(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_setr_pd(x: laneType, y: laneType, z: laneType, w: laneType): vecType;
      return _mm256_setr_pd(x, y, z, w);
    }
    inline proc type loada(x: c_ptrConst(real(64))): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_load_pd(x: c_ptrConst(real(64))): vecType;
      return _mm256_load_pd(x);
    }
    inline proc type storea(x: c_ptr(real(64)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm256_store_pd(x: c_ptr(real(64)), y: vecType): void;
      _mm256_store_pd(x, y);
    }
    inline proc type loadu(x: c_ptrConst(real(64))): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_loadu_pd(x: c_ptrConst(real(64))): vecType;
      return _mm256_loadu_pd(x);
    }
    inline proc type storeu(x: c_ptr(real(64)), y: vecType): void {
      pragma "fn synchronization free"
      extern proc _mm256_storeu_pd(x: c_ptr(real(64)), y: vecType): void;
      _mm256_storeu_pd(x, y);
    }

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapPairs64x4r(x: vecType): vecType;
      return swapPairs64x4r(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc swapLowHigh64x4r(x: vecType): vecType;
      return swapLowHigh64x4r(x);
    }
    inline proc type reverse(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc reverse64x4r(x: vecType): vecType;
      return reverse64x4r(x);
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc rotateLeft64x4r(x: vecType): vecType;
      return rotateLeft64x4r(x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc rotateRight64x4r(x: vecType): vecType;
      return rotateRight64x4r(x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc interleaveLower64x4r(x: vecType, y: vecType): vecType;
      return interleaveLower64x4r(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc interleaveUpper64x4r(x: vecType, y: vecType): vecType;
      return interleaveUpper64x4r(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc deinterleaveLower64x4r(x: vecType, y: vecType): vecType;
      return deinterleaveLower64x4r(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc deinterleaveUpper64x4r(x: vecType, y: vecType): vecType;
      return deinterleaveUpper64x4r(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc blendLowHigh64x4r(x: vecType, y: vecType): vecType;
      return blendLowHigh64x4r(x, y);
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_add_pd(x: vecType, y: vecType): vecType;
      return _mm256_add_pd(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_sub_pd(x: vecType, y: vecType): vecType;
      return _mm256_sub_pd(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_mul_pd(x: vecType, y: vecType): vecType;
      return _mm256_mul_pd(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_div_pd(x: vecType, y: vecType): vecType;
      return _mm256_div_pd(x, y);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_hadd_pd(x: vecType, y: vecType): vecType;
      return _mm256_hadd_pd(x, y);
    }

    inline proc type sqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_sqrt_pd(x: vecType): vecType;
      return _mm256_sqrt_pd(x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_cvtpd_ps(x: vecType): x8664_32x4r.vecType;
      pragma "fn synchronization free"
      extern proc _mm256_cvtps_pd(x: x8664_32x4r.vecType): vecType;

      var three = this.splat(3.0);
      var half = this.splat(0.5);

      var x_ps = _mm256_cvtpd_ps(x);
      // do rsqrt at 32-bit precision
      var res = _mm256_cvtps_pd(x8664_32x4r.rsqrt(x_ps));

      // TODO: would an FMA version be faster?
      // Newton-Raphson iteration
      // q = 0.5 * x * (3 - x * res * res)
      var muls = this.mul(this.mul(x, res), res);
      res = this.mul(this.mul(half, res), this.sub(three, muls));

      return res;
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_fmadd_pd(x: vecType, y: vecType, z: vecType): vecType;
      return _mm256_fmadd_pd(x, y, z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_fmsub_pd(x: vecType, y: vecType, z: vecType): vecType;
      return _mm256_fmsub_pd(x, y, z);
    }
  }

}
