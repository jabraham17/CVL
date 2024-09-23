module IntrinArm64_128 {
  use CTypes only c_ptr, c_ptrConst;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    require "arm_neon.h";
    require "wrapper-arm64-128.h";
    require "wrapper-arm64-128.c";
  }


  extern "float32x4_t" type vec32x4f;
  extern "float64x2_t" type vec64x2d;


  //
  // 32-bit float
  //
  inline proc extract32x4f(x: vec32x4f, param idx: int): real(32) {
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
  inline proc insert32x4f(x: vec32x4f, y: real(32), param idx: int): vec32x4f {
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

  pragma "fn synchronization free"
  extern "vdupq_n_f32" proc splat32x4f(x: real(32)): vec32x4f;
  inline proc set32x4f(x: real(32), y: real(32), z: real(32), w: real(32)): vec32x4f {
    var result: vec32x4f;
    result = splat32x4f(x);
    result = insert32x4f(result, y, 1);
    result = insert32x4f(result, z, 2);
    result = insert32x4f(result, w, 3);
    return result;
  }
  pragma "fn synchronization free"
  extern proc load32x4f(x: c_ptrConst(real(32))): vec32x4f;
  pragma "fn synchronization free"
  extern proc store32x4f(x: c_ptr(real(32)), y: vec32x4f): void;

  pragma "fn synchronization free"
  extern "vrev64q_f32" proc swapPairs32x4f(x: vec32x4f): vec32x4f;
  inline proc swapLowHigh32x4f(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f2(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f2(x, x);
  }
  inline proc reverse32x4f(x: vec32x4f): vec32x4f {
    return swapPairs32x4f(swapLowHigh32x4f(x));
  }
  inline proc rotateLeft32x4f(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f1(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f1(x, x);
  }
  inline proc rotateRight32x4f(x: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f3(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f3(x, x);
  }
  pragma "fn synchronization free"
  extern "vzip1q_f32" proc interleaveLower32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vzip2q_f32" proc interleaveUpper32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vuzp1q_f32" proc deinterleaveLower32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vuzp2q_f32" proc deinterleaveUpper32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;

  inline proc blendLowHigh32x4f(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc extractVector32x4f2(x: vec32x4f, y: vec32x4f): vec32x4f;
    return extractVector32x4f2(x, y);
  }

  pragma "fn synchronization free"
  extern "vaddq_f32" proc add32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vsubq_f32" proc sub32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vmulq_f32" proc mul32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vdivq_f32" proc div32x4f(x: vec32x4f, y: vec32x4f): vec32x4f;
  inline proc hadd32x4f(x: vec32x4f, y: vec32x4f): vec32x4f {
    pragma "fn synchronization free"
    extern proc vpaddq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    var temp = vpaddq_f32(x, y);
    return interleaveLower32x4f(temp, swapLowHigh32x4f(temp));
  }

  pragma "fn synchronization free"
  extern "vsqrtq_f32" proc sqrt32x4f(x: vec32x4f): vec32x4f;
  pragma "fn synchronization free"
  extern "vrsqrteq_f32" proc rsqrt32x4f(x: vec32x4f): vec32x4f;

  //
  // 64-bit float
  //

  inline proc extract64x2d(x: vec64x2d, param idx: int): real(64) {
    pragma "fn synchronization free"
    extern proc get_lane_64x2d0(x: vec64x2d): real(64);
    pragma "fn synchronization free"
    extern proc get_lane_64x2d1(x: vec64x2d): real(64);

    if idx == 0      then return get_lane_64x2d0(x);
    else if idx == 1 then return get_lane_64x2d1(x);
    else compilerError("invalid index");
  }
  inline proc insert64x2d(x: vec64x2d, y: real(64), param idx: int): vec64x2d {
    pragma "fn synchronization free"
    extern proc set_lane_64x2d0(x: vec64x2d, y: real(64)): vec64x2d;
    pragma "fn synchronization free"
    extern proc set_lane_64x2d1(x: vec64x2d, y: real(64)): vec64x2d;

    if idx == 0      then return set_lane_64x2d0(x, y);
    else if idx == 1 then return set_lane_64x2d1(x, y);
    else compilerError("invalid index");
  }
  pragma "fn synchronization free"
  extern "vdupq_n_f64" proc splat64x2d(x: real(64)): vec64x2d;
  inline proc set64x2d(x: real(64), y: real(64)): vec64x2d {
    var result: vec64x2d;
    result = splat64x2d(x);
    result = insert64x2d(result, y, 1);
    return result;
  }
  pragma "fn synchronization free"
  extern proc load64x2d(x: c_ptrConst(real(64))): vec64x2d;
  pragma "fn synchronization free"
  extern proc store64x2d(x: c_ptr(real(64)), y: vec64x2d): void;


  inline proc swapPairs64x2d(x: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc extractVector64x2f0(x: vec64x2d, y: vec64x2d): vec64x2d;
    return extractVector64x2f0(x, x);
  }
  inline proc swapLowHigh64x2d(x: vec64x2d): vec64x2d do return swapPairs64x2d(x);
  inline proc reverse64x2d(x: vec64x2d): vec64x2d do return swapPairs64x2d(x);
  inline proc rotateLeft64x2d(x: vec64x2d): vec64x2d do return swapPairs64x2d(x);
  inline proc rotateRight64x2d(x: vec64x2d): vec64x2d do return swapPairs64x2d(x);
  pragma "fn synchronization free"
  extern "vzip1q_f64" proc interleaveLower64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vzip2q_f64" proc interleaveUpper64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vuzp1q_f64" proc deinterleaveLower64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vuzp2q_f64" proc deinterleaveUpper64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;

  inline proc blendLowHigh64x2d(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc extractVector64x2f1(x: vec64x2d, y: vec64x2d): vec64x2d;
    return extractVector64x2f1(x, y);
  }


  pragma "fn synchronization free"
  extern "vaddq_f64" proc add64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vsubq_f64" proc sub64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vmulq_f64" proc mul64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vdivq_f64" proc div64x2d(x: vec64x2d, y: vec64x2d): vec64x2d;
  inline proc hadd64x2d(x: vec64x2d, y: vec64x2d): vec64x2d {
    pragma "fn synchronization free"
    extern proc vpaddq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    var temp = vpaddq_f64(x, y);
    return interleaveLower64x2d(temp, swapLowHigh64x2d(temp));
  }

  pragma "fn synchronization free"
  extern "vsqrtq_f64" proc sqrt64x2d(x: vec64x2d): vec64x2d;
  pragma "fn synchronization free"
  extern "vrsqrteq_f64" proc rsqrt64x2d(x: vec64x2d): vec64x2d;

}
