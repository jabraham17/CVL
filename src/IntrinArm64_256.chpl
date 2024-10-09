
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

  record arm64_32x8f {
    proc type vecType type do return vec32x8f;
    proc type laneType type do return real(32);

    inline proc type extract(x: vecType, param idx: int): laneType {
      if idx < 4 then return arm64_32x4f.extract(x.lo, idx);
                else return arm64_32x4f.extract(x.hi, idx - 4);
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      if idx < 4 then return new vecType(arm64_32x4f.insert(x.lo, y, idx), x.hi);
                else return new vecType(x.lo, arm64_32x4f.insert(x.hi, y, idx - 4));
    }

    inline proc type splat(x: laneType): vecType do
      return new vecType(arm64_32x4f.splat(x), arm64_32x4f.splat(x));
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType): vecType do
      return new vecType(arm64_32x4f.set(x, y, z, w), arm64_32x4f.set(a, b, c, d));
    inline proc type loada(x: c_ptrConst(laneType)): vecType do
      return new vecType(arm64_32x4f.loada(x), arm64_32x4f.loada(x + 4));
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      arm64_32x4f.storea(x, y.lo);
      arm64_32x4f.storea(x + 4, y.hi);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType do
      return new vecType(arm64_32x4f.swapPairs(x.lo), arm64_32x4f.swapPairs(x.hi));
    inline proc type swapLowHigh(x: vecType): vecType do
      return new vecType(x.hi, x.lo);
    inline proc type reverse(x: vecType): vecType do
      return new vecType(arm64_32x4f.reverse(x.hi), arm64_32x4f.reverse(x.lo));
    inline proc type rotateLeft(x: vecType): vecType do
      return x; // TODO
    inline proc type rotateRight(x: vecType): vecType do
      return x; // TODO
    inline proc type interleaveLower(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.interleaveLower(x.lo, y.lo), arm64_32x4f.interleaveUpper(x.lo, y.lo));
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.interleaveLower(x.hi, y.hi), arm64_32x4f.interleaveUpper(x.hi, y.hi));
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.deinterleaveLower(x.lo, x.hi), arm64_32x4f.deinterleaveLower(y.lo, y.hi));
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.deinterleaveUpper(x.lo, x.hi), arm64_32x4f.deinterleaveUpper(y.lo, y.hi));
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType do
      return new vecType(x.lo, y.hi);

    inline proc type add(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.add(x.lo, y.lo), arm64_32x4f.add(x.hi, y.hi));
    inline proc type sub(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.sub(x.lo, y.lo), arm64_32x4f.sub(x.hi, y.hi));
    inline proc type mul(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.mul(x.lo, y.lo), arm64_32x4f.mul(x.hi, y.hi));
    inline proc type div(x: vecType, y: vecType): vecType do
      return new vecType(arm64_32x4f.div(x.lo, y.lo), arm64_32x4f.div(x.hi, y.hi));
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_f32(x: vec32x4f, y: vec32x4f): vec32x4f;
      var temp1 = vpaddq_f32(x.lo, x.hi);
      var temp2 = vpaddq_f32(y.lo, y.hi);
      return new vecType(arm64_32x4f.interleaveLower(temp1, temp2), arm64_32x4f.interleaveUpper(temp1, temp2));
    }

    inline proc type sqrt(x: vecType): vecType do
      return new vecType(arm64_32x4f.sqrt(x.lo), arm64_32x4f.sqrt(x.hi));
    inline proc type rsqrt(x: vecType): vecType do
      return new vecType(arm64_32x4f.rsqrt(x.lo), arm64_32x4f.rsqrt(x.hi));

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return new vecType(arm64_32x4f.fmadd(x.lo, y.lo, z.lo), arm64_32x4f.fmadd(x.hi, y.hi, z.hi));
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return new vecType(arm64_32x4f.fmsub(x.lo, y.lo, z.lo), arm64_32x4f.fmsub(x.hi, y.hi, z.hi));
  }

  record arm64_64x4d {
    proc type vecType type do return vec64x4d;
    proc type laneType type do return real(64);

    inline proc type extract(x: vecType, param idx: int): laneType {
      if idx < 2 then return arm64_64x2d.extract(x.lo, idx);
                else return arm64_64x2d.extract(x.hi, idx - 2);
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      if idx < 2 then return new vecType(arm64_64x2d.insert(x.lo, y, idx), x.hi);
                else return new vecType(x.lo, arm64_64x2d.insert(x.hi, y, idx - 2));
    }

    inline proc type splat(x: laneType): vecType do
      return new vecType(arm64_64x2d.splat(x), arm64_64x2d.splat(x));
    inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType do
      return new vecType(arm64_64x2d.set(x, y), arm64_64x2d.set(z, w));
    inline proc type loada(x: c_ptrConst(laneType)): vecType do
      return new vecType(arm64_64x2d.loada(x), arm64_64x2d.loada(x + 2));
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      arm64_64x2d.storea(x, y.lo);
      arm64_64x2d.storea(x + 2, y.hi);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType do
      return new vecType(arm64_64x2d.swapPairs(x.lo), arm64_64x2d.swapPairs(x.hi));
    inline proc type swapLowHigh(x: vecType): vecType do
      return new vecType(x.hi, x.lo);
    inline proc type reverse(x: vecType): vecType do
      return new vecType(arm64_64x2d.reverse(x.hi), arm64_64x2d.reverse(x.lo));
    inline proc type rotateLeft(x: vecType): vecType do
      return x; // TODO
    inline proc type rotateRight(x: vecType): vecType do
      return x; // TODO
    inline proc type interleaveLower(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.interleaveLower(x.lo, y.lo), arm64_64x2d.interleaveUpper(x.lo, y.lo));
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.interleaveLower(x.hi, y.hi), arm64_64x2d.interleaveUpper(x.hi, y.hi));
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.deinterleaveLower(x.lo, x.hi), arm64_64x2d.deinterleaveLower(y.lo, y.hi));
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.deinterleaveUpper(x.lo, x.hi), arm64_64x2d.deinterleaveUpper(y.lo, y.hi));
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType do
      return new vecType(x.lo, y.hi);

    inline proc type add(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.add(x.lo, y.lo), arm64_64x2d.add(x.hi, y.hi));
    inline proc type sub(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.sub(x.lo, y.lo), arm64_64x2d.sub(x.hi, y.hi));
    inline proc type mul(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.mul(x.lo, y.lo), arm64_64x2d.mul(x.hi, y.hi));
    inline proc type div(x: vecType, y: vecType): vecType do
      return new vecType(arm64_64x2d.div(x.lo, y.lo), arm64_64x2d.div(x.hi, y.hi));
    inline proc type hadd(x: vecType, y: vecType): vecType {
      pragma "fn synchronization free"
      extern proc vpaddq_f64(x: vec64x2d, y: vec64x2d): vec64x2d;
      var temp1 = vpaddq_f64(x.lo, x.hi);
      var temp2 = vpaddq_f64(y.lo, y.hi);
      return new vecType(arm64_64x2d.interleaveLower(temp1, temp2), arm64_64x2d.interleaveUpper(temp1, temp2));
    }

    inline proc type sqrt(x: vecType): vecType do
      return new vecType(arm64_64x2d.sqrt(x.lo), arm64_64x2d.sqrt(x.hi));
    inline proc type rsqrt(x: vecType): vecType do
      return new vecType(arm64_64x2d.rsqrt(x.lo), arm64_64x2d.rsqrt(x.hi));

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return new vecType(arm64_64x2d.fmadd(x.lo, y.lo, z.lo), arm64_64x2d.fmadd(x.hi, y.hi, z.hi));
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return new vecType(arm64_64x2d.fmsub(x.lo, y.lo, z.lo), arm64_64x2d.fmsub(x.hi, y.hi, z.hi));
  }

}
