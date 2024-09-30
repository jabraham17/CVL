
/* There is no 256 for neon, this emulates it */
module IntrinArm64_256 {
  use CTypes only c_ptr, c_ptrConst;
  use IntrinArm64_128;

  record arm64_32x8f {}
  record arm64_64x4d {}

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
  inline proc type arm64_32x8f.extract(x: vec32x8f, param idx: int): real(32) {
    if idx < 4 then return arm64_32x4f.extract(x.lo, idx);
               else return arm64_32x4f.extract(x.hi, idx - 4);
  }
  inline proc type arm64_32x8f.insert(x: vec32x8f, y: real(32), param idx: int): vec32x8f {
    if idx < 4 then return new vec32x8f(arm64_32x4f.insert(x.lo, y, idx), x.hi);
               else return new vec32x8f(x.lo, arm64_32x4f.insert(x.hi, y, idx - 4));
  }

  inline proc type arm64_32x8f.splat(x: real(32)): vec32x8f do
    return new vec32x8f(arm64_32x4f.splat(x), arm64_32x4f.splat(x));
  inline proc type arm64_32x8f.set(x: real(32), y: real(32), z: real(32), w: real(32), a: real(32), b: real(32), c: real(32), d: real(32)): vec32x8f do
    return new vec32x8f(arm64_32x4f.set(x, y, z, w), arm64_32x4f.set(a, b, c, d));
  inline proc type arm64_32x8f.loada(x: c_ptrConst(real(32))): vec32x8f do
    return new vec32x8f(arm64_32x4f.loada(x), arm64_32x4f.loada(x + 4));
  inline proc type arm64_32x8f.loadu(x: c_ptrConst(real(32))): vec32x8f do
    return this.loada(x);
  inline proc type arm64_32x8f.storea(x: c_ptr(real(32)), y: vec32x8f): void {
    arm64_32x4f.storea(x, y.lo);
    arm64_32x4f.storea(x + 4, y.hi);
  }
  inline proc type arm64_32x8f.storeu(x: c_ptr(real(32)), y: vec32x8f): void do
    this.storea(x, y);

  inline proc type arm64_32x8f.swapPairs(x: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.swapPairs(x.lo), arm64_32x4f.swapPairs(x.hi));
  inline proc type arm64_32x8f.swapLowHigh(x: vec32x8f): vec32x8f do
    return new vec32x8f(x.hi, x.lo);
  inline proc type arm64_32x8f.reverse(x: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.reverse(x.hi), arm64_32x4f.reverse(x.lo));
  inline proc type arm64_32x8f.rotateLeft(x: vec32x8f): vec32x8f do
    return x; // TODO
  inline proc type arm64_32x8f.rotateRight(x: vec32x8f): vec32x8f do
    return x; // TODO
  inline proc type arm64_32x8f.interleaveLower(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.interleaveLower(x.lo, y.lo), arm64_32x4f.interleaveUpper(x.lo, y.lo));
  inline proc type arm64_32x8f.interleaveUpper(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.interleaveLower(x.hi, y.hi), arm64_32x4f.interleaveUpper(x.hi, y.hi));
  inline proc type arm64_32x8f.deinterleaveLower(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.deinterleaveLower(x.lo, x.hi), arm64_32x4f.deinterleaveLower(y.lo, y.hi));
  inline proc type arm64_32x8f.deinterleaveUpper(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.deinterleaveUpper(x.lo, x.hi), arm64_32x4f.deinterleaveUpper(y.lo, y.hi));
  inline proc type arm64_32x8f.blendLowHigh(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(x.lo, y.hi);

  inline proc type arm64_32x8f.add(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.add(x.lo, y.lo), arm64_32x4f.add(x.hi, y.hi));
  inline proc type arm64_32x8f.sub(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.sub(x.lo, y.lo), arm64_32x4f.sub(x.hi, y.hi));
  inline proc type arm64_32x8f.mul(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.mul(x.lo, y.lo), arm64_32x4f.mul(x.hi, y.hi));
  inline proc type arm64_32x8f.div(x: vec32x8f, y: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.div(x.lo, y.lo), arm64_32x4f.div(x.hi, y.hi));
  inline proc type arm64_32x8f.hadd(x: vec32x8f, y: vec32x8f): vec32x8f {
    pragma "fn synchronization free"
    extern proc vpaddq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
    var temp1 = vpaddq_f32(x.lo, x.hi);
    var temp2 = vpaddq_f32(y.lo, y.hi);
    return new vec32x8f(arm64_32x4f.interleaveLower(temp1, temp2), arm64_32x4f.interleaveUpper(temp1, temp2));
  }

  inline proc type arm64_32x8f.sqrt(x: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.sqrt(x.lo), arm64_32x4f.sqrt(x.hi));
  inline proc type arm64_32x8f.rsqrt(x: vec32x8f): vec32x8f do
    return new vec32x8f(arm64_32x4f.rsqrt(x.lo), arm64_32x4f.rsqrt(x.hi));

  //
  // 64-bit float
  //
  inline proc type arm64_64x4d.extract(x: vec64x4d, param idx: int): real(64) {
    if idx < 2 then return arm64_64x2d.extract(x.lo, idx);
               else return arm64_64x2d.extract(x.hi, idx - 2);
  }
  inline proc type arm64_64x4d.insert(x: vec64x4d, y: real(64), param idx: int): vec64x4d {
    if idx < 2 then return new vec64x4d(arm64_64x2d.insert(x.lo, y, idx), x.hi);
               else return new vec64x4d(x.lo, arm64_64x2d.insert(x.hi, y, idx - 2));
  }

  inline proc type arm64_64x4d.splat(x: real(64)): vec64x4d do
    return new vec64x4d(arm64_64x2d.splat(x), arm64_64x2d.splat(x));
  inline proc type arm64_64x4d.set(x: real(64), y: real(64), z: real(64), w: real(64)): vec64x4d do
    return new vec64x4d(arm64_64x2d.set(x, y), arm64_64x2d.set(z, w));
  inline proc type arm64_64x4d.loada(x: c_ptrConst(real(64))): vec64x4d do
    return new vec64x4d(arm64_64x2d.loada(x), arm64_64x2d.loada(x + 2));
  inline proc type arm64_64x4d.loadu(x: c_ptrConst(real(64))): vec64x4d do
    return this.loada(x);
  inline proc type arm64_64x4d.storea(x: c_ptr(real(64)), y: vec64x4d): void {
    arm64_64x2d.storea(x, y.lo);
    arm64_64x2d.storea(x + 2, y.hi);
  }
  inline proc type arm64_64x4d.storeu(x: c_ptr(real(64)), y: vec64x4d): void do
    this.storea(x, y);

  inline proc type arm64_64x4d.swapPairs(x: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.swapPairs(x.lo), arm64_64x2d.swapPairs(x.hi));
  inline proc type arm64_64x4d.swapLowHigh(x: vec64x4d): vec64x4d do
    return new vec64x4d(x.hi, x.lo);
  inline proc type arm64_64x4d.reverse(x: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.reverse(x.hi), arm64_64x2d.reverse(x.lo));
  inline proc type arm64_64x4d.rotateLeft(x: vec64x4d): vec64x4d do
    return x; // TODO
  inline proc type arm64_64x4d.rotateRight(x: vec64x4d): vec64x4d do
    return x; // TODO
  inline proc type arm64_64x4d.interleaveLower(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.interleaveLower(x.lo, y.lo), arm64_64x2d.interleaveUpper(x.lo, y.lo));
  inline proc type arm64_64x4d.interleaveUpper(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.interleaveLower(x.hi, y.hi), arm64_64x2d.interleaveUpper(x.hi, y.hi));
  inline proc type arm64_64x4d.deinterleaveLower(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.deinterleaveLower(x.lo, x.hi), arm64_64x2d.deinterleaveLower(y.lo, y.hi));
  inline proc type arm64_64x4d.deinterleaveUpper(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.deinterleaveUpper(x.lo, x.hi), arm64_64x2d.deinterleaveUpper(y.lo, y.hi));
  inline proc type arm64_64x4d.blendLowHigh(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(x.lo, y.hi);

  inline proc type arm64_64x4d.add(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.add(x.lo, y.lo), arm64_64x2d.add(x.hi, y.hi));
  inline proc type arm64_64x4d.sub(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.sub(x.lo, y.lo), arm64_64x2d.sub(x.hi, y.hi));
  inline proc type arm64_64x4d.mul(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.mul(x.lo, y.lo), arm64_64x2d.mul(x.hi, y.hi));
  inline proc type arm64_64x4d.div(x: vec64x4d, y: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.div(x.lo, y.lo), arm64_64x2d.div(x.hi, y.hi));
  inline proc type arm64_64x4d.hadd(x: vec64x4d, y: vec64x4d): vec64x4d {
    pragma "fn synchronization free"
    extern proc vpaddq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
    var temp1 = vpaddq_f64(x.lo, x.hi);
    var temp2 = vpaddq_f64(y.lo, y.hi);
    return new vec64x4d(arm64_64x2d.interleaveLower(temp1, temp2), arm64_64x2d.interleaveUpper(temp1, temp2));
  }

  inline proc type arm64_64x4d.sqrt(x: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.sqrt(x.lo), arm64_64x2d.sqrt(x.hi));
  inline proc type arm64_64x4d.rsqrt(x: vec64x4d): vec64x4d do
    return new vec64x4d(arm64_64x2d.rsqrt(x.lo), arm64_64x2d.rsqrt(x.hi));
}
