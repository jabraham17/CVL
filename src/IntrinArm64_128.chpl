module IntrinArm64_128 {
  use CTypes only c_ptr, c_ptrConst;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    require "arm_neon.h";
    require "wrapper-arm64-128.h";
    require "wrapper-arm64-128.c";
  }

  record arm64_32x4f {}
  record arm64_64x2d {}

  extern "float32x4_t" type vec32x4f;
  extern "float64x2_t" type vec64x2d;


  //
  // 32-bit float
  //
  inline proc type arm64_32x4f.extract(x: vec32x4f, param idx: int): real(32) {
    pragma "fn synchronization free"
    extern proc get_lane_32x4f0(x: vec32x4f): real(32);
    pragma "fn synchronization free"
    extern proc get_lane_32x4f1(x: vec32x4f): real(32);
    pragma "fn synchronization free"
    extern proc get_lane_32x4f2(x: vec32x4f): real(32);
    pragma "fn synchronization free"
    extern proc get_lane_32x4f3(x: vec32x4f): real(32);

    if idx == 0      then return get_lane_32x4f0(x);
    else if idx == 1 then return get_lane_32x4f1(x);
    else if idx == 2 then return get_lane_32x4f2(x);
    else if idx == 3 then return get_lane_32x4f3(x);
    else compilerError("invalid index");
  }
  inline proc type arm64_32x4f.insert(x: vec32x4f, y: real(32), param idx: int): vec32x4f {
    pragma "fn synchronization free"
    extern proc set_lane_32x4f0(x: vec32x4f, y: real(32)): vec32x4f;
    pragma "fn synchronization free"
    extern proc set_lane_32x4f1(x: vec32x4f, y: real(32)): vec32x4f;
    pragma "fn synchronization free"
    extern proc set_lane_32x4f2(x: vec32x4f, y: real(32)): vec32x4f;
    pragma "fn synchronization free"
    extern proc set_lane_32x4f3(x: vec32x4f, y: real(32)): vec32x4f;

    if idx == 0      then return set_lane_32x4f0(x, y);
    else if idx == 1 then return set_lane_32x4f1(x, y);
    else if idx == 2 then return set_lane_32x4f2(x, y);
    else if idx == 3 then return set_lane_32x4f3(x, y);
    else compilerError("invalid index");
  }

  inline proc type arm64_32x4f.splat(x: real(32)): vec32x4f {
    pragma "fn synchronization free"
    extern proc vdupq_n_f32(x: real(32)): vec32x4f;
    return vdupq_n_f32(x);
  }
  inline proc type arm64_32x4f.set(x: real(32), y: real(32), z: real(32), w: real(32)): vec32x4f {
    var result: vec32x4f;
    result = this.splat(x);
    result = this.insert(result, y, 1);
    result = this.insert(result, z, 2);
    result = this.insert(result, w, 3);
    return result;
  }
  inline proc type arm64_32x4f.loada(x: c_ptrConst(real(32))): vec32x4f {
    pragma "fn synchronization free"
    extern proc load32x4f(x: c_ptrConst(real(32))): vec32x4f;
    return load32x4f(x);
  }
  inline proc type arm64_32x4f.loadu(x: c_ptrConst(real(32))): vec32x4f do
    return this.loada(x);
  inline proc type arm64_32x4f.storea(x: c_ptr(real(32)), y: vec32x4f): void {
    pragma "fn synchronization free"
    extern proc store32x4f(x: c_ptr(real(32)), y: vec32x4f): void;
    store32x4f(x, y);
  }
  inline proc type arm64_32x4f.storeu(x: c_ptr(real(32)), y: vec32x4f): void do
    this.storea(x, y);

  inline proc type arm64_32x4f.swapPairs(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vrev64q_f32(x: vec32x4f): vec32x4f;
    return vrev64q_f32(x);
  }
  inline proc type arm64_32x4f.swapLowHigh(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f2(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f2(x, x);
  }
  inline proc type arm64_32x4f.reverse(x: vec32x4f): vec32x4f {
    return this.swapPairs(this.swapLowHigh(x));
  }
  inline proc type arm64_32x4f.rotateLeft(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f1(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f1(x, x);
  }
  inline proc type arm64_32x4f.rotateRight(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f3(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f3(x, x);
  }
  inline proc type arm64_32x4f.interleaveLower(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vzip1q_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vzip1q_f32(x, y);
  }
  inline proc type arm64_32x4f.interleaveUpper(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vzip2q_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vzip2q_f32(x, y);
  }
  inline proc type arm64_32x4f.deinterleaveLower(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vuzp1q_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vuzp1q_f32(x, y);
  }
  inline proc type arm64_32x4f.deinterleaveUpper(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vuzp2q_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vuzp2q_f32(x, y);
  }
  inline proc type arm64_32x4f.blendLowHigh(x: vec32x4f, y: vec32x4f): vec32x4f {
    extern "float32x2_t" type vec32x2f;
    pragma "fn synchronization free"
    extern proc vget_low_f32(x: vec32x4f): vec32x2f;
    pragma "fn synchronization free"
    extern proc vget_high_f32(x: vec32x4f): vec32x2f;
    pragma "fn synchronization free"
    extern proc vcombine_f32(x: vec32x2f, y: vec32x2f): vec32x4f;
    return vcombine_f32(vget_low_f32(x), vget_high_f32(y));
  }

  inline proc type arm64_32x4f.add(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vaddq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vaddq_f32(x, y);
  }
  inline proc type arm64_32x4f.sub(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vsubq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vsubq_f32(x, y);
  }
  inline proc type arm64_32x4f.mul(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vmulq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vmulq_f32(x, y);
  }
  inline proc type arm64_32x4f.div(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vdivq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    return vdivq_f32(x, y);
  }
  inline proc type arm64_32x4f.hadd(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vpaddq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    var temp = vpaddq_f32(x, y);
    return interleaveLower(temp, swapLowHigh(temp));
  }

  inline proc type arm64_32x4f.sqrt(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vsqrtq_f32(x: vec32x4f): vec32x4f;
    return vsqrtq_f32(x);
  }
  inline proc type arm64_32x4f.rsqrt(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vrsqrteq_f32(x: vec32x4f): vec32x4f;
    return vrsqrteq_f32(x);
  }

  inline proc type arm64_32x4f.fmadd(x: vec32x4f, y: vec32x4f, z: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vfmaq_f32(x: vec32x4f, y: vec32x4f, z: vec32x4f): vec32x4f;
    return vfmaq_f32(z, x, y);
  }
  inline proc type arm64_32x4f.fmsub(x: vec32x4f, y: vec32x4f, z: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vnegq_f32(x: vec32x4f): vec32x4f;
    return this.fmadd(x, y, vnegq_f32(z));
  }

  //
  // 64-bit float
  //

  inline proc type arm64_64x2d.extract(x: vec64x2d, param idx: int): real(64) {
    pragma "fn synchronization free"
    extern proc get_lane_64x2d0(x: vec64x2d): real(64);
    pragma "fn synchronization free"
    extern proc get_lane_64x2d1(x: vec64x2d): real(64);

    if idx == 0      then return get_lane_64x2d0(x);
    else if idx == 1 then return get_lane_64x2d1(x);
    else compilerError("invalid index");
  }
  inline proc type arm64_64x2d.insert(x: vec64x2d, y: real(64), param idx: int): vec64x2d {
    pragma "fn synchronization free"
    extern proc set_lane_64x2d0(x: vec64x2d, y: real(64)): vec64x2d;
    pragma "fn synchronization free"
    extern proc set_lane_64x2d1(x: vec64x2d, y: real(64)): vec64x2d;

    if idx == 0      then return set_lane_64x2d0(x, y);
    else if idx == 1 then return set_lane_64x2d1(x, y);
    else compilerError("invalid index");
  }
  inline proc type arm64_64x2d.splat(x: real(64)): vec64x2d {
    pragma "fn synchronization free"
    extern proc vdupq_n_f64(x: real(64)): vec64x2d;
    return vdupq_n_f64(x);
  }
  inline proc type arm64_64x2d.set(x: real(64), y: real(64)): vec64x2d {
    var result: vec64x2d;
    result = this.splat(x);
    result = this.insert(result, y, 1);
    return result;
  }
  inline proc type arm64_64x2d.loada(x: c_ptrConst(real(64))): vec64x2d {
    pragma "fn synchronization free"
    extern proc load64x2d(x: c_ptrConst(real(64))): vec64x2d;
    return load64x2d(x);
  }
  inline proc type arm64_64x2d.loadu(x: c_ptrConst(real(64))): vec64x2d do
    return this.loada(x);
  inline proc type arm64_64x2d.storea(x: c_ptr(real(64)), y: vec64x2d): void {
    pragma "fn synchronization free"
    extern proc store64x2d(x: c_ptr(real(64)), y: vec64x2d): void;
    store64x2d(x, y);
  }
  inline proc type arm64_64x2d.storeu(x: c_ptr(real(64)), y: vec64x2d): void do
    this.storea(x, y);


  inline proc type arm64_64x2d.swapPairs(x: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc extractVector64x2f1(x: vec64x2d, y: vec64x2d): vec64x2d;
    return extractVector64x2f1(x, x);
  }
  inline proc type arm64_64x2d.swapLowHigh(x: vec64x2d): vec64x2d do return this.swapPairs(x);
  inline proc type arm64_64x2d.reverse(x: vec64x2d): vec64x2d do return this.swapPairs(x);
  inline proc type arm64_64x2d.rotateLeft(x: vec64x2d): vec64x2d do return this.swapPairs(x);
  inline proc type arm64_64x2d.rotateRight(x: vec64x2d): vec64x2d do return this.swapPairs(x);
  inline proc type arm64_64x2d.interleaveLower(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vzip1q_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vzip1q_f64(x, y);
  }
  inline proc type arm64_64x2d.interleaveUpper(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vzip2q_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vzip2q_f64(x, y);
  }
  inline proc type arm64_64x2d.deinterleaveLower(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vuzp1q_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vuzp1q_f64(x, y);
  }
  inline proc type arm64_64x2d.deinterleaveUpper(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vuzp2q_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vuzp2q_f64(x, y);
  }

  inline proc type arm64_64x2d.blendLowHigh(x: vec64x2d, y: vec64x2d): vec64x2d {
    extern "float64x1_t" type vec64x1d;
    pragma "fn synchronization free"
    extern proc vget_low_f64(x: vec64x2d): vec64x1d;
    pragma "fn synchronization free"
    extern proc vget_high_f64(x: vec64x2d): vec64x1d;
    pragma "fn synchronization free"
    extern proc vcombine_f64(x: vec64x1d, y: vec64x1d): vec64x2d;
    return vcombine_f64(vget_low_f64(x), vget_high_f64(y));
  }


  inline proc type arm64_64x2d.add(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vaddq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vaddq_f64(x, y);
  }
  inline proc type arm64_64x2d.sub(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vsubq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vsubq_f64(x, y);
  }
  inline proc type arm64_64x2d.mul(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vmulq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vmulq_f64(x, y);
  }
  inline proc type arm64_64x2d.div(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vdivq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    return vdivq_f64(x, y);
  }
  inline proc type arm64_64x2d.hadd(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vpaddq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    var temp = vpaddq_f64(x, y);
    return this.interleaveLower(temp, this.swapLowHigh(temp));
  }

  inline proc type arm64_64x2d.sqrt(x: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vsqrtq_f64(x: vec64x2d): vec64x2d;
    return vsqrtq_f64(x);
  }
  inline proc type arm64_64x2d.rsqrt(x: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vrsqrteq_f64(x: vec64x2d): vec64x2d;
    return vrsqrteq_f64(x);
  }

  inline proc type arm64_64x2d.fmadd(x: vec64x2d, y: vec64x2d, z: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vfmaq_f64(x: vec64x2d, y: vec64x2d, z: vec64x2d): vec64x2d;
    return vfmaq_f64(z, x, y);
  }
  inline proc type arm64_64x2d.fmsub(x: vec64x2d, y: vec64x2d, z: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vnegq_f64(x: vec64x2d): vec64x2d;
    return this.fmadd(x, y, vnegq_f64(z));
  }

}
