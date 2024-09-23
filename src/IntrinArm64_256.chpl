
/* There is no 256 for neon, this emulates it */
module IntrinArm64_256 {
  use CTypes only c_ptr, c_ptrConst;
  use IntrinArm64_128;

  record vec32x8f {
    var lo: vec32x4f;
    var hi: vec32x4f;
  }
  record vec64x4d {
    var lo: vec64x2d;
    var hi: vec64x2d;
  }

  //
  // 32-bit float
  //
  inline proc extract32x8f(x: vec32x8f, param idx: int): real(32) {
    if idx < 4 then return extract32x4f(x.lo, idx);
               else return extract32x4f(x.hi, idx - 4);
  }
  inline proc insert32x8f(x: vec32x8f, y: real(32), param idx: int): vec32x8f {
    if idx < 4 then return new vec32x8f(insert32x4f(x.lo, y, idx), x.hi);
               else return new vec32x8f(x.lo, insert32x4f(x.hi, y, idx - 4));
  }

  inline proc splat32x8f(x: real(32)): vec32x8f do
    return new vec32x8f(splat32x4f(x), splat32x4f(x));
  inline proc set32x8f(x: real(32), y: real(32), z: real(32), w: real(32), a: real(32), b: real(32), c: real(32), d: real(32)): vec32x8f do
    return new vec32x8f(set32x4f(x, y, z, w), set32x4f(a, b, c, d));
  inline proc load32x8f(x: c_ptrConst(real(32))): vec32x8f do
    return new vec32x8f(load32x4f(x), load32x4f(x + 4));
  inline proc store32x8f(x: c_ptr(real(32)), y: vec32x8f): void {
    store32x4f(x, y.lo);
    store32x4f(x + 4, y.hi);
  }

  inline proc swapPairs32x8f(x: vec32x8f): vec32x8f do
    return new vec32x8f(swapPairs32x4f(x.lo), swapPairs32x4f(x.hi));
  inline proc swapLowHigh32x8f(x: vec32x8f): vec32x8f do
    return new vec32x8f(x.hi, x.lo);
  inline proc reverse32x8f(x: vec32x8f): vec32x8f do
    return new vec32x8f(reverse32x4f(x.hi), reverse32x4f(x.lo));
  inline proc rotateLeft32x8f(x: vec32x8f): vec32x8f do
    return x; // TODO
  inline proc rotateRight32x8f(x: vec32x8f): vec32x8f do
    return x; // TODO
  inline proc interleaveLower32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(interleaveLower32x4f(x.lo, y.lo), interleaveUpper32x4f(x.lo, y.lo));
  inline proc interleaveUpper32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(interleaveLower32x4f(x.hi, y.hi), interleaveUpper32x4f(x.hi, y.hi));
  inline proc deinterleaveLower32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(deinterleaveLower32x4f(x.lo, x.hi), deinterleaveLower32x4f(y.lo, y.hi));
  inline proc deinterleaveUpper32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(deinterleaveUpper32x4f(x.lo, x.hi), deinterleaveUpper32x4f(y.lo, y.hi));
  inline proc blendLowHigh32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(x.lo, y.hi);

  inline proc add32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(add32x4f(x.lo, y.lo), add32x4f(x.hi, y.hi));
  inline proc sub32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(sub32x4f(x.lo, y.lo), sub32x4f(x.hi, y.hi));
  inline proc mul32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(mul32x4f(x.lo, y.lo), mul32x4f(x.hi, y.hi));
  inline proc div32x8f(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(div32x4f(x.lo, y.lo), div32x4f(x.hi, y.hi));
  inline proc hadd32x8f(x: vec32x8f, y: vec32x8f): vec32x8f {
    pragma "fn synchronization free"
    extern proc vpaddq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    var temp1 = vpaddq_f32(x.lo, x.hi);
    var temp2 = vpaddq_f32(y.lo, y.hi);
    return new vec32x8f(interleaveLower32x4f(temp1, temp2), interleaveUpper32x4f(temp1, temp2));
  }

  inline proc sqrt32x8f(x: vec32x8f): vec32x8f do
    return new vec32x8f(sqrt32x4f(x.lo), sqrt32x4f(x.hi));
  inline proc rsqrt32x8f(x: vec32x8f): vec32x8f do
    return new vec32x8f(rsqrt32x4f(x.lo), rsqrt32x4f(x.hi));

  //
  // 64-bit float
  //
  inline proc extract64x4d(x: vec64x4d, param idx: int): real(64) {
    if idx < 2 then return extract64x2d(x.lo, idx);
               else return extract64x2d(x.hi, idx - 2);
  }
  inline proc insert64x4d(x: vec64x4d, y: real(64), param idx: int): vec64x4d {
    if idx < 2 then return new vec64x4d(insert64x2d(x.lo, y, idx), x.hi);
               else return new vec64x4d(x.lo, insert64x2d(x.hi, y, idx - 2));
  }

  inline proc splat64x4d(x: real(64)): vec64x4d do
    return new vec64x4d(splat64x2d(x), splat64x2d(x));
  inline proc set64x4d(x: real(64), y: real(64), z: real(64), w: real(64)): vec64x4d do
    return new vec64x4d(set64x2d(x, y), set64x2d(z, w));
  inline proc load64x4d(x: c_ptrConst(real(64))): vec64x4d do
    return new vec64x4d(load64x2d(x), load64x2d(x + 2));
  inline proc store64x4d(x: c_ptr(real(64)), y: vec64x4d): void {
    store64x2d(x, y.lo);
    store64x2d(x + 2, y.hi);
  }

  inline proc swapPairs64x4d(x: vec64x4d): vec64x4d do
    return new vec64x4d(swapPairs64x2d(x.lo), swapPairs64x2d(x.hi));
  inline proc swapLowHigh64x4d(x: vec64x4d): vec64x4d do
    return new vec64x4d(x.hi, x.lo);
  inline proc reverse64x4d(x: vec64x4d): vec64x4d do
    return new vec64x4d(reverse64x2d(x.hi), reverse64x2d(x.lo));
  inline proc rotateLeft64x4d(x: vec64x4d): vec64x4d do
    return x; // TODO
  inline proc rotateRight64x4d(x: vec64x4d): vec64x4d do
    return x; // TODO
  inline proc interleaveLower64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(interleaveLower64x2d(x.lo, y.lo), interleaveUpper64x2d(x.lo, y.lo));
  inline proc interleaveUpper64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(interleaveLower64x2d(x.hi, y.hi), interleaveUpper64x2d(x.hi, y.hi));
  inline proc deinterleaveLower64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(deinterleaveLower64x2d(x.lo, x.hi), deinterleaveLower64x2d(y.lo, y.hi));
  inline proc deinterleaveUpper64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(deinterleaveUpper64x2d(x.lo, x.hi), deinterleaveUpper64x2d(y.lo, y.hi));
  inline proc blendLowHigh64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(x.lo, y.hi);

  inline proc add64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(add64x2d(x.lo, y.lo), add64x2d(x.hi, y.hi));
  inline proc sub64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(sub64x2d(x.lo, y.lo), sub64x2d(x.hi, y.hi));
  inline proc mul64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(mul64x2d(x.lo, y.lo), mul64x2d(x.hi, y.hi));
  inline proc div64x4d(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(div64x2d(x.lo, y.lo), div64x2d(x.hi, y.hi));
  inline proc hadd64x4d(x: vec64x4d, y: vec64x4d): vec64x4d {
    pragma "fn synchronization free"
    extern proc vpaddq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    var temp1 = vpaddq_f64(x.lo, x.hi);
    var temp2 = vpaddq_f64(y.lo, y.hi);
    return new vec64x4d(interleaveLower64x2d(temp1, temp2), interleaveUpper64x2d(temp1, temp2));
  }

  inline proc sqrt64x4d(x: vec64x4d): vec64x4d do
    return new vec64x4d(sqrt64x2d(x.lo), sqrt64x2d(x.hi));
  inline proc rsqrt64x4d(x: vec64x4d): vec64x4d do
    return new vec64x4d(rsqrt64x2d(x.lo), rsqrt64x2d(x.hi));
}
