module IntrinArm64_128 {
  use CTypes only c_ptr, c_ptrConst;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    require "arm_neon.h";
    require "wrapper-arm64-128.h";
    require "wrapper-arm64-128-float.c";
    require "wrapper-arm64-128-double.c";
  }

  extern "float32x4_t" type vec32x4f;
  extern "float64x2_t" type vec64x2d;

  extern "int8x16_t" type vec8x16i;
  extern "int16x8_t" type vec16x8i;
  extern "int32x4_t" type vec32x4i;
  extern "int64x2_t" type vec64x2i;
  extern "uint8x16_t" type vec8x16u;
  extern "uint16x8_t" type vec16x8u;
  extern "uint32x4_t" type vec32x4u;
  extern "uint64x2_t" type vec64x2u;

  proc numBits(type t) param
    where t == vec32x4f || t == vec64x2d ||
          t == vec8x16i || t == vec16x8i || t == vec32x4i || t == vec64x2i ||
          t == vec8x16u || t == vec16x8u || t == vec32x4u || t == vec64x2u
    do return 128;


  record arm64_32x4f {
    proc type vecType type do return vec32x4f;
    proc type laneType type do return real(32);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc get_lane_32x4f0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_32x4f1(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_32x4f2(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_32x4f3(x: vecType): laneType;

      if idx == 0      then return get_lane_32x4f0(x);
      else if idx == 1 then return get_lane_32x4f1(x);
      else if idx == 2 then return get_lane_32x4f2(x);
      else if idx == 3 then return get_lane_32x4f3(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc set_lane_32x4f0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_32x4f1(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_32x4f2(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_32x4f3(x: vecType, y: laneType): vecType;

      if idx == 0      then return set_lane_32x4f0(x, y);
      else if idx == 1 then return set_lane_32x4f1(x, y);
      else if idx == 2 then return set_lane_32x4f2(x, y);
      else if idx == 3 then return set_lane_32x4f3(x, y);
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc vdupq_n_f32(x: laneType): vecType;
      return vdupq_n_f32(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType {
      var result: vecType;
      result = this.splat(x);
      result = this.insert(result, y, 1);
      result = this.insert(result, z, 2);
      result = this.insert(result, w, 3);
      return result;
    }
    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      pragma "fn synchronization free"
      extern proc load32x4f(x: c_ptrConst(laneType)): vecType;
      return load32x4f(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      pragma "fn synchronization free"
      extern proc store32x4f(x: c_ptr(laneType), y: vecType): void;
      store32x4f(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vrev64q_f32(x: vecType): vecType;
      return vrev64q_f32(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4f2(x: vecType, y: vecType): vecType;
      return extractVector32x4f2(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return this.swapPairs(this.swapLowHigh(x));
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4f1(x: vecType, y: vecType): vecType;
      return extractVector32x4f1(x, x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4f3(x: vecType, y: vecType): vecType;
      return extractVector32x4f3(x, x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip1q_f32(x: vecType, y: vecType): vecType;
      return vzip1q_f32(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip2q_f32(x: vecType, y: vecType): vecType;
      return vzip2q_f32(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp1q_f32(x: vecType, y: vecType): vecType;
      return vuzp1q_f32(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp2q_f32(x: vecType, y: vecType): vecType;
      return vuzp2q_f32(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      extern "float32x2_t" type vec32x2f;
      pragma "fn synchronization free"
      extern proc vget_low_f32(x: vecType): vec32x2f;
      pragma "fn synchronization free"
      extern proc vget_high_f32(x: vecType): vec32x2f;
      pragma "fn synchronization free"
      extern proc vcombine_f32(x: vec32x2f, y: vec32x2f): vecType;
      return vcombine_f32(vget_low_f32(x), vget_high_f32(y));
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vaddq_f32(x: vecType, y: vecType): vecType;
      return vaddq_f32(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsubq_f32(x: vecType, y: vecType): vecType;
      return vsubq_f32(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vmulq_f32(x: vecType, y: vecType): vecType;
      return vmulq_f32(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vdivq_f32(x: vecType, y: vecType): vecType;
      return vdivq_f32(x, y);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_f32(x: vecType, y: vecType): vecType;
      var temp = vpaddq_f32(x, y);
      return interleaveLower(temp, swapLowHigh(temp));
    }

    inline proc type sqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsqrtq_f32(x: vecType): vecType;
      return vsqrtq_f32(x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vrsqrteq_f32(x: vecType): vecType;
      return vrsqrteq_f32(x);
    }

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vfmaq_f32(x: vecType, y: vecType, z: vecType): vecType;
      return vfmaq_f32(z, x, y);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vnegq_f32(x: vecType): vecType;
      return this.fmadd(x, y, vnegq_f32(z));
    }

  }

  record arm64_64x2d {
    proc type vecType type do return vec64x2d;
    proc type laneType type do return real(64);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc get_lane_64x2d0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_64x2d1(x: vecType): laneType;

      if idx == 0      then return get_lane_64x2d0(x);
      else if idx == 1 then return get_lane_64x2d1(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc set_lane_64x2d0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_64x2d1(x: vecType, y: laneType): vecType;

      if idx == 0      then return set_lane_64x2d0(x, y);
      else if idx == 1 then return set_lane_64x2d1(x, y);
      else compilerError("invalid index");
    }
    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc vdupq_n_f64(x: laneType): vecType;
      return vdupq_n_f64(x);
    }
    inline proc type set(x: laneType, y: laneType): vecType {
      var result: vecType;
      result = this.splat(x);
      result = this.insert(result, y, 1);
      return result;
    }
    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      pragma "fn synchronization free"
      extern proc load64x2d(x: c_ptrConst(laneType)): vecType;
      return load64x2d(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      pragma "fn synchronization free"
      extern proc store64x2d(x: c_ptr(laneType), y: vecType): void;
      store64x2d(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);


    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector64x2f1(x: vecType, y: vecType): vecType;
      return extractVector64x2f1(x, x);
    }
    inline proc type swapLowHigh(x: vecType): vecType do return this.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do return this.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do return this.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do return this.swapPairs(x);
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip1q_f64(x: vecType, y: vecType): vecType;
      return vzip1q_f64(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip2q_f64(x: vecType, y: vecType): vecType;
      return vzip2q_f64(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp1q_f64(x: vecType, y: vecType): vecType;
      return vuzp1q_f64(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp2q_f64(x: vecType, y: vecType): vecType;
      return vuzp2q_f64(x, y);
    }

    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      extern "float64x1_t" type vec64x1d;
      pragma "fn synchronization free"
      extern proc vget_low_f64(x: vecType): vec64x1d;
      pragma "fn synchronization free"
      extern proc vget_high_f64(x: vecType): vec64x1d;
      pragma "fn synchronization free"
      extern proc vcombine_f64(x: vec64x1d, y: vec64x1d): vecType;
      return vcombine_f64(vget_low_f64(x), vget_high_f64(y));
    }


    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vaddq_f64(x: vecType, y: vecType): vecType;
      return vaddq_f64(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsubq_f64(x: vecType, y: vecType): vecType;
      return vsubq_f64(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vmulq_f64(x: vecType, y: vecType): vecType;
      return vmulq_f64(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vdivq_f64(x: vecType, y: vecType): vecType;
      return vdivq_f64(x, y);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_f64(x: vecType, y: vecType): vecType;
      var temp = vpaddq_f64(x, y);
      return this.interleaveLower(temp, this.swapLowHigh(temp));
    }

    inline proc type sqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsqrtq_f64(x: vecType): vecType;
      return vsqrtq_f64(x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vrsqrteq_f64(x: vecType): vecType;
      return vrsqrteq_f64(x);
    }

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vfmaq_f64(x: vecType, y: vecType, z: vecType): vecType;
      return vfmaq_f64(z, x, y);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vnegq_f64(x: vecType): vecType;
      return this.fmadd(x, y, vnegq_f64(z));
    }
  }


  record arm64_8x16i {
    proc type vecType type do return vec8x16i;
    proc type laneType type do return int(8);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc get_lane_8x16i0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i1(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i2(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i3(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i4(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i5(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i6(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i7(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i8(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i9(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i10(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i11(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i12(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i13(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i14(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_8x16i15(x: vecType): laneType;

      if idx == 0      then return get_lane_8x16i0(x);
      else if idx == 1 then return get_lane_8x16i1(x);
      else if idx == 2 then return get_lane_8x16i2(x);
      else if idx == 3 then return get_lane_8x16i3(x);
      else if idx == 4 then return get_lane_8x16i4(x);
      else if idx == 5 then return get_lane_8x16i5(x);
      else if idx == 6 then return get_lane_8x16i6(x);
      else if idx == 7 then return get_lane_8x16i7(x);
      else if idx == 8 then return get_lane_8x16i8(x);
      else if idx == 9 then return get_lane_8x16i9(x);
      else if idx == 10 then return get_lane_8x16i10(x);
      else if idx == 11 then return get_lane_8x16i11(x);
      else if idx == 12 then return get_lane_8x16i12(x);
      else if idx == 13 then return get_lane_8x16i13(x);
      else if idx == 14 then return get_lane_8x16i14(x);
      else if idx == 15 then return get_lane_8x16i15(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc set_lane_8x16i0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i1(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i2(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i3(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i4(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i5(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i6(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i7(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i8(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i9(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i10(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i11(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i12(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i13(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i14(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_8x16i15(x: vecType, y: laneType): vecType;

      if idx == 0      then return set_lane_8x16i0(x, y);
      else if idx == 1 then return set_lane_8x16i1(x, y);
      else if idx == 2 then return set_lane_8x16i2(x, y);
      else if idx == 3 then return set_lane_8x16i3(x, y);
      else if idx == 4 then return set_lane_8x16i4(x, y);
      else if idx == 5 then return set_lane_8x16i5(x, y);
      else if idx == 6 then return set_lane_8x16i6(x, y);
      else if idx == 7 then return set_lane_8x16i7(x, y);
      else if idx == 8 then return set_lane_8x16i8(x, y);
      else if idx == 9 then return set_lane_8x16i9(x, y);
      else if idx == 10 then return set_lane_8x16i10(x, y);
      else if idx == 11 then return set_lane_8x16i11(x, y);
      else if idx == 12 then return set_lane_8x16i12(x, y);
      else if idx == 13 then return set_lane_8x16i13(x, y);
      else if idx == 14 then return set_lane_8x16i14(x, y);
      else if idx == 15 then return set_lane_8x16i15(x, y);
      else compilerError("invalid index");
    }
    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc vdupq_n_s8(x: laneType): vecType;
      return vdupq_n_s8(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType, e: laneType, f: laneType, g: laneType, h: laneType, i: laneType, j: laneType, k: laneType, l: laneType): vecType {
      var result: vecType;
      result = this.splat(x);
      result = this.insert(result, y, 1);
      result = this.insert(result, z, 2);
      result = this.insert(result, w, 3);
      result = this.insert(result, a, 4);
      result = this.insert(result, b, 5);
      result = this.insert(result, c, 6);
      result = this.insert(result, d, 7);
      result = this.insert(result, e, 8);
      result = this.insert(result, f, 9);
      result = this.insert(result, g, 10);
      result = this.insert(result, h, 11);
      result = this.insert(result, i, 12);
      result = this.insert(result, j, 13);
      result = this.insert(result, k, 14);
      result = this.insert(result, l, 15);
      return result;
    }

    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      pragma "fn synchronization free"
      extern proc load8x16i(x: c_ptrConst(laneType)): vecType;
      return load8x16i(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      pragma "fn synchronization free"
      extern proc store8x16i(x: c_ptr(laneType), y: vecType): void;
      store8x16i(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vrev16q_s8(x: vecType): vecType;
      return vrev16q_s8(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector8x16i8(x: vecType, y: vecType): vecType;
      return extractVector8x16i8(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return this.swapPairs(this.swapLowHigh(x));
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector8x16i1(x: vecType, y: vecType): vecType;
      return extractVector8x16i1(x, x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector8x16i15(x: vecType, y: vecType): vecType;
      return extractVector8x16i15(x, x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip1q_s8(x: vecType, y: vecType): vecType;
      return vzip1q_s8(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip2q_s8(x: vecType, y: vecType): vecType;
      return vzip2q_s8(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp1q_s8(x: vecType, y: vecType): vecType;
      return vuzp1q_s8(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp2q_s8(x: vecType, y: vecType): vecType;
      return vuzp2q_s8(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      extern "int8x8_t" type vec8x8i;
      pragma "fn synchronization free"
      extern proc vget_low_s8(x: vecType): vec8x8i;
      pragma "fn synchronization free"
      extern proc vget_high_s8(x: vecType): vec8x8i;
      pragma "fn synchronization free"
      extern proc vcombine_s8(x: vec8x8i, y: vec8x8i): vecType;
      return vcombine_s8(vget_low_s8(x), vget_high_s8(y));
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vaddq_s8(x: vecType, y: vecType): vecType;
      return vaddq_s8(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsubq_s8(x: vecType, y: vecType): vecType;
      return vsubq_s8(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vmulq_s8(x: vecType, y: vecType): vecType;
      return vmulq_s8(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to int 16
      // convert to float16
      // do float division
      // convert back to int16
      // convert back to int8
      extern "int8x8_t" type vec8x8i;
      extern "float16x8_t" type vec16x8f;
      pragma "fn synchronization free"
      extern proc vmovl_s8(x: vecType): vec16x8i;
      pragma "fn synchronization free"
      extern proc vmovl_high_s8(x: vecType): vec16x8i;
      pragma "fn synchronization free"
      extern proc vmovn_s16(x: vec16x8i): vec8x8i;
      pragma "fn synchronization free"
      extern proc vmovn_high_s16(x: vec8x8i, y: vec16x8i): vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_f16_s16(x: vec16x8i): vec16x8f;
      pragma "fn synchronization free"
      extern proc vcvtq_s16_f16(x: vec16x8f): vec16x8i;
      pragma "fn synchronization free"
      extern proc vcvtq_s16_s8(x: vec16x8i): vecType;
      pragma "fn synchronization free"
      extern proc vdivq_f16(x: vec16x8f, y: vec16x8f): vec16x8f;

      proc inner(x: vec16x8i, y: vec16x8i): vec16x8i {
        var x16f = vcvtq_f16_s16(x);
        var y16f = vcvtq_f16_s16(y);
        var result16f = vdivq_f16(x16f, y16f);
        return vcvtq_s16_f16(result16f);
      }

      var res_low = inner(vmovl_s8(x), vmovl_s8(y));
      var res_high = inner(vmovl_high_s8(x), vmovl_high_s8(y));
      var res = vmovn_high_s16(vmovn_s16(res_low), res_high);
      return res;
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_s8(x: vecType, y: vecType): vecType;
      var temp = vpaddq_s8(x, y);
      return interleaveLower(temp, swapLowHigh(temp));
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      return add(mul(x, y), z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      return sub(mul(x, y), z);
    }

  }

  record arm64_16x8i {
    proc type vecType type do return vec16x8i;
    proc type laneType type do return int(16);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc get_lane_16x8i0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i1(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i2(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i3(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i4(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i5(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i6(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_16x8i7(x: vecType): laneType;

      if idx == 0      then return get_lane_16x8i0(x);
      else if idx == 1 then return get_lane_16x8i1(x);
      else if idx == 2 then return get_lane_16x8i2(x);
      else if idx == 3 then return get_lane_16x8i3(x);
      else if idx == 4 then return get_lane_16x8i4(x);
      else if idx == 5 then return get_lane_16x8i5(x);
      else if idx == 6 then return get_lane_16x8i6(x);
      else if idx == 7 then return get_lane_16x8i7(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc set_lane_16x8i0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i1(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i2(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i3(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i4(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i5(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i6(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_16x8i7(x: vecType, y: laneType): vecType;

      if idx == 0      then return set_lane_16x8i0(x, y);
      else if idx == 1 then return set_lane_16x8i1(x, y);
      else if idx == 2 then return set_lane_16x8i2(x, y);
      else if idx == 3 then return set_lane_16x8i3(x, y);
      else if idx == 4 then return set_lane_16x8i4(x, y);
      else if idx == 5 then return set_lane_16x8i5(x, y);
      else if idx == 6 then return set_lane_16x8i6(x, y);
      else if idx == 7 then return set_lane_16x8i7(x, y);
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc vdupq_n_s16(x: laneType): vecType;
      return vdupq_n_s16(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType): vecType {
      var result: vecType;
      result = this.splat(x);
      result = this.insert(result, y, 1);
      result = this.insert(result, z, 2);
      result = this.insert(result, w, 3);
      result = this.insert(result, a, 4);
      result = this.insert(result, b, 5);
      result = this.insert(result, c, 6);
      result = this.insert(result, d, 7);
      return result;
    }

    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      pragma "fn synchronization free"
      extern proc load16x8i(x: c_ptrConst(laneType)): vecType;
      return load16x8i(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      pragma "fn synchronization free"
      extern proc store16x8i(x: c_ptr(laneType), y: vecType): void;
      store16x8i(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vrev32q_s16(x: vecType): vecType;
      return vrev32q_s16(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector16x8i4(x: vecType, y: vecType): vecType;
      return extractVector16x8i4(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return this.swapPairs(this.swapLowHigh(x));
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector16x8i1(x: vecType, y: vecType): vecType;
      return extractVector16x8i1(x, x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector16x8i7(x: vecType, y: vecType): vecType;
      return extractVector16x8i7(x, x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip1q_s16(x: vecType, y: vecType): vecType;
      return vzip1q_s16(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip2q_s16(x: vecType, y: vecType): vecType;
      return vzip2q_s16(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp1q_s16(x: vecType, y: vecType): vecType;
      return vuzp1q_s16(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp2q_s16(x: vecType, y: vecType): vecType;
      return vuzp2q_s16(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      extern "int16x4_t" type vec16x4i;
      pragma "fn synchronization free"
      extern proc vget_low_s16(x: vecType): vec16x4i;
      pragma "fn synchronization free"
      extern proc vget_high_s16(x: vecType): vec16x4i;
      pragma "fn synchronization free"
      extern proc vcombine_s16(x: vec16x4i, y: vec16x4i): vecType;
      return vcombine_s16(vget_low_s16(x), vget_high_s16(y));
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vaddq_s16(x: vecType, y: vecType): vecType;
      return vaddq_s16(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsubq_s16(x: vecType, y: vecType): vecType;
      return vsubq_s16(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vmulq_s16(x: vecType, y: vecType): vecType;
      return vmulq_s16(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to int 32
      // convert to float32
      // do float division
      // convert back to int32
      // convert back to int16
      extern "int16x4_t" type vec16x4i;
      pragma "fn synchronization free"
      extern proc vmovl_s16(x: vecType): vec32x4i;
      pragma "fn synchronization free"
      extern proc vmovl_high_s16(x: vecType): vec32x4i;
      pragma "fn synchronization free"
      extern proc vmovn_s32(x: vec32x4i): vec16x4i;
      pragma "fn synchronization free"
      extern proc vmovn_high_s32(x: vec16x4i, y: vec32x4i): vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_f32_s32(x: vec32x4i): vec32x4f;
      pragma "fn synchronization free"
      extern proc vcvtq_s32_f32(x: vec32x4f): vec32x4i;
      pragma "fn synchronization free"
      extern proc vcvtq_s32_s16(x: vec32x4i): vecType;
      pragma "fn synchronization free"
      extern proc vdivq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;

      proc inner(x: vec32x4i, y: vec32x4i): vec32x4i {
        var x32f = vcvtq_f32_s32(x);
        var y32f = vcvtq_f32_s32(y);
        var result32f = vdivq_f32(x32f, y32f);
        return vcvtq_s32_f32(result32f);
      }

      var res_low = inner(vmovl_s16(x), vmovl_s16(y));
      var res_high = inner(vmovl_high_s16(x), vmovl_high_s16(y));
      var res = vmovn_high_s32(vmovn_s32(res_low), res_high);
      return res;
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_s16(x: vecType, y: vecType): vecType;
      var temp = vpaddq_s16(x, y);
      return interleaveLower(temp, swapLowHigh(temp));
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      return add(mul(x, y), z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      return sub(mul(x, y), z);
    }
  }

  record arm64_32x4i {
    proc type vecType type do return vec32x4i;
    proc type laneType type do return int(32);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc get_lane_32x4i0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_32x4i1(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_32x4i2(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_32x4i3(x: vecType): laneType;

      if idx == 0      then return get_lane_32x4i0(x);
      else if idx == 1 then return get_lane_32x4i1(x);
      else if idx == 2 then return get_lane_32x4i2(x);
      else if idx == 3 then return get_lane_32x4i3(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc set_lane_32x4i0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_32x4i1(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_32x4i2(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_32x4i3(x: vecType, y: laneType): vecType;

      if idx == 0      then return set_lane_32x4i0(x, y);
      else if idx == 1 then return set_lane_32x4i1(x, y);
      else if idx == 2 then return set_lane_32x4i2(x, y);
      else if idx == 3 then return set_lane_32x4i3(x, y);
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc vdupq_n_s32(x: laneType): vecType;
      return vdupq_n_s32(x);
    }
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType {
      var result: vecType;
      result = this.splat(x);
      result = this.insert(result, y, 1);
      result = this.insert(result, z, 2);
      result = this.insert(result, w, 3);
      return result;
    }

    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      pragma "fn synchronization free"
      extern proc load32x4i(x: c_ptrConst(laneType)): vecType;
      return load32x4i(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      pragma "fn synchronization free"
      extern proc store32x4i(x: c_ptr(laneType), y: vecType): void;
      store32x4i(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vrev64q_s32(x: vecType): vecType;
      return vrev64q_s32(x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4i2(x: vecType, y: vecType): vecType;
      return extractVector32x4i2(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return this.swapPairs(this.swapLowHigh(x));
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4i1(x: vecType, y: vecType): vecType;
      return extractVector32x4i1(x, x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4i3(x: vecType, y: vecType): vecType;
      return extractVector32x4i3(x, x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip1q_s32(x: vecType, y: vecType): vecType;
      return vzip1q_s32(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip2q_s32(x: vecType, y: vecType): vecType;
      return vzip2q_s32(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp1q_s32(x: vecType, y: vecType): vecType;
      return vuzp1q_s32(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp2q_s32(x: vecType, y: vecType): vecType;
      return vuzp2q_s32(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      extern "int32x2_t" type vec32x2i;
      pragma "fn synchronization free"
      extern proc vget_low_s32(x: vecType): vec32x2i;
      pragma "fn synchronization free"
      extern proc vget_high_s32(x: vecType): vec32x2i;
      pragma "fn synchronization free"
      extern proc vcombine_s32(x: vec32x2i, y: vec32x2i): vecType;
      return vcombine_s32(vget_low_s32(x), vget_high_s32(y));
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vaddq_s32(x: vecType, y: vecType): vecType;
      return vaddq_s32(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsubq_s32(x: vecType, y: vecType): vecType;
      return vsubq_s32(x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vmulq_s32(x: vecType, y: vecType): vecType;
      return vmulq_s32(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to float32
      // do float division
      // convert back to int32
      pragma "fn synchronization free"
      extern proc vcvtq_f32_s32(x: vecType): arm64_32x4f.vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_s32_f32(x: arm64_32x4f.vecType): vecType;

      var x_f32 = vcvtq_f32_s32(x);
      var y_f32 = vcvtq_f32_s32(y);
      var res_f32 = arm64_32x4f.div(x_f32, y_f32);
      return vcvtq_s32_f32(res_f32);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_s32(x: vecType, y: vecType): vecType;
      var temp = vpaddq_s32(x, y);
      return interleaveLower(temp, swapLowHigh(temp));
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return add(mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return sub(mul(x, y), z);
  }

  record arm64_64x2i {
    proc type vecType type do return vec64x2i;
    proc type laneType type do return int(64);

    inline proc type extract(x: vecType, param idx: int): laneType {
      pragma "fn synchronization free"
      extern proc get_lane_64x2i0(x: vecType): laneType;
      pragma "fn synchronization free"
      extern proc get_lane_64x2i1(x: vecType): laneType;

      if idx == 0      then return get_lane_64x2i0(x);
      else if idx == 1 then return get_lane_64x2i1(x);
      else compilerError("invalid index");
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      pragma "fn synchronization free"
      extern proc set_lane_64x2i0(x: vecType, y: laneType): vecType;
      pragma "fn synchronization free"
      extern proc set_lane_64x2i1(x: vecType, y: laneType): vecType;

      if idx == 0      then return set_lane_64x2i0(x, y);
      else if idx == 1 then return set_lane_64x2i1(x, y);
      else compilerError("invalid index");
    }

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc vdupq_n_s64(x: laneType): vecType;
      return vdupq_n_s64(x);
    }
    inline proc type set(x: laneType, y: laneType): vecType {
      var result: vecType;
      result = this.splat(x);
      result = this.insert(result, y, 1);
      return result;
    }

    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      pragma "fn synchronization free"
      extern proc load64x2i(x: c_ptrConst(laneType)): vecType;
      return load64x2i(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      pragma "fn synchronization free"
      extern proc store64x2i(x: c_ptr(laneType), y: vecType): void;
      store64x2i(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector64x2i1(x: vecType, y: vecType): vecType;
      return extractVector64x2i1(x, x);
    }
    inline proc type swapLowHigh(x: vecType): vecType do return this.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do return this.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do return this.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do return this.swapPairs(x);
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip1q_s64(x: vecType, y: vecType): vecType;
      return vzip1q_s64(x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vzip2q_s64(x: vecType, y: vecType): vecType;
      return vzip2q_s64(x, y);
    }
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp1q_s64(x: vecType, y: vecType): vecType;
      return vuzp1q_s64(x, y);
    }
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vuzp2q_s64(x: vecType, y: vecType): vecType;
      return vuzp2q_s64(x, y);
    }
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      extern "int64x1_t" type vec64x1i;
      pragma "fn synchronization free"
      extern proc vget_low_s64(x: vecType): vec64x1i;
      pragma "fn synchronization free"
      extern proc vget_high_s64(x: vecType): vec64x1i;
      pragma "fn synchronization free"
      extern proc vcombine_s64(x: vec64x1i, y: vec64x1i): vecType;
      return vcombine_s64(vget_low_s64(x), vget_high_s64(y));
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vaddq_s64(x: vecType, y: vecType): vecType;
      return vaddq_s64(x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vsubq_s64(x: vecType, y: vecType): vecType;
      return vsubq_s64(x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to float64
      // do float division
      // convert back to int64
      pragma "fn synchronization free"
      extern proc vcvtq_f64_s64(x: vecType): arm64_64x2d.vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_s64_f64(x: arm64_64x2d.vecType): vecType;

      var x_f64 = vcvtq_f64_s64(x);
      var y_f64 = vcvtq_f64_s64(y);
      var res_f64 = arm64_64x2d.div(x_f64, y_f64);
      return vcvtq_s64_f64(res_f64);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_s64(x: vecType, y: vecType): vecType;
      var temp = vpaddq_s64(x, y);
      return interleaveLower(temp, swapLowHigh(temp));
    }
  }



}
