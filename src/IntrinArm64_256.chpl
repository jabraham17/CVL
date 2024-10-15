
/* There is no 256 for neon, this emulates it */
module IntrinArm64_256 {
  use CTypes only c_ptr, c_ptrConst;
  use IntrinArm64_128;

  record vecPair {
    type vt; // value type
    var lo: vt;
    var hi: vt;
    proc init(type vt) do this.vt = vt;
    proc init(type vt, lo: vt, hi: vt) {
      this.vt = vt;
      this.lo = lo;
      this.hi = hi;
    }
    proc init(lo: ?t, hi: t) {
      this.vt = t;
      this.lo = lo;
      this.hi = hi;
    }
  }

  // unneeded for now, nobody should be using the raw types directly
  // proc vec32x8f type do return vecPair(vec32x4f);
  // proc vec64x4d type do return vecPair(vec64x2d);
  // proc vec8x32i type do return vecPair(vec8x16i);
  // proc vec16x16i type do return vecPair(vec16x8i);
  // proc vec32x8i type do return vecPair(vec32x4i);
  // proc vec64x4i type do return vecPair(vec64x2i);


  proc numBits(type t) param where isSubtype(t, vecPair) do
    return numBits(t.vt) * 2;


  record generic_wide {
    // operations that are generic for all wide types, which use vecPair

    type implVecType;
    proc type vecType type do return vecPair(implVecType.vecType);
    proc type laneType type do return implVecType.laneType;
    proc type offset param do return numBits(implVecType.vecType) / numBits(laneType);

    inline proc type extract(x: vecType, param idx: int): laneType {
      if idx < offset then return implVecType.extract(x.lo, idx);
                      else return implVecType.extract(x.hi, idx - offset);
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      if idx < offset then
        return new vecType(implVecType.insert(x.lo, y, idx), x.hi);
      else
        return new vecType(x.lo, implVecType.insert(x.hi, y, idx - offset));
    }

    inline proc type splat(x: laneType): vecType do
      return new vecType(implVecType.splat(x), implVecType.splat(x));
    inline proc type set(xs...): vecType do
      compilerError("Not implemented");
    inline proc type loada(x: c_ptrConst(laneType)): vecType do
      return new vecType(implVecType.loada(x), implVecType.loada(x + offset));
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return this.loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      implVecType.storea(x, y.lo);
      implVecType.storea(x + offset, y.hi);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      this.storea(x, y);

    inline proc type swapPairs(x: vecType): vecType do
      return new vecType(implVecType.swapPairs(x.lo), implVecType.swapPairs(x.hi));
    inline proc type swapLowHigh(x: vecType): vecType do
      return new vecType(x.hi, x.lo);
    inline proc type reverse(x: vecType): vecType do
      return new vecType(implVecType.reverse(x.hi), implVecType.reverse(x.lo));
    inline proc type rotateLeft(x: vecType): vecType {
      compilerWarning("rotateLeft not implemented");
      return x; // TODO
    }
    inline proc type rotateRight(x: vecType): vecType {
      compilerWarning("rotateRight not implemented");
      return x; // TODO
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.interleaveLower(x.lo, y.lo), implVecType.interleaveUpper(x.lo, y.lo));
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.interleaveLower(x.hi, y.hi), implVecType.interleaveUpper(x.hi, y.hi));
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.deinterleaveLower(x.lo, x.hi), implVecType.deinterleaveLower(y.lo, y.hi));
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.deinterleaveUpper(x.lo, x.hi), implVecType.deinterleaveUpper(y.lo, y.hi));
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType do
      return new vecType(x.lo, y.hi);

    inline proc type add(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.add(x.lo, y.lo), implVecType.add(x.hi, y.hi));
    inline proc type sub(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.sub(x.lo, y.lo), implVecType.sub(x.hi, y.hi));
    inline proc type mul(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.mul(x.lo, y.lo), implVecType.mul(x.hi, y.hi));
    inline proc type div(x: vecType, y: vecType): vecType do
      return new vecType(implVecType.div(x.lo, y.lo), implVecType.div(x.hi, y.hi));

    inline proc type hadd(x: vecType, y: vecType): vecType {

      proc vpaddName(type t) param {
        if t == vec32x4f then return "vpaddq_f32";
        if t == vec64x2d then return "vpaddq_f64";
        if t == vec8x16i then return "vpaddq_s8";
        if t == vec16x8i then return "vpaddq_s16";
        if t == vec32x4i then return "vpaddq_s32";
        if t == vec64x2i then return "vpaddq_s64";
        compilerError("Unsupported type");
      }

      type vpaddType = implVecType.vecType;
      pragma "fn synchronization free"
      extern vpaddName(vpaddType)
      proc vpadd(x: vpaddType, y: vpaddType): vpaddType;

      var temp1 = vpadd(x.lo, x.hi);
      var temp2 = vpadd(y.lo, y.hi);
      return new vecType(implVecType.interleaveLower(temp1, temp2),
                         implVecType.interleaveUpper(temp1, temp2));
    }

    inline proc type sqrt(x: vecType): vecType do
      return new vecType(implVecType.sqrt(x.lo), implVecType.sqrt(x.hi));
    inline proc type rsqrt(x: vecType): vecType do
      return new vecType(implVecType.rsqrt(x.lo), implVecType.rsqrt(x.hi));

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return new vecType(implVecType.fmadd(x.lo, y.lo, z.lo),
                         implVecType.fmadd(x.hi, y.hi, z.hi));
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return new vecType(implVecType.fmsub(x.lo, y.lo, z.lo),
                         implVecType.fmsub(x.hi, y.hi, z.hi));

  }


  proc arm64_32x8f type do return generic_wide(arm64_32x4f);
  proc arm64_64x4d type do return generic_wide(arm64_64x2d);
  proc arm64_8x32i type do return generic_wide(arm64_8x16i);
  proc arm64_16x16i type do return generic_wide(arm64_16x8i);
  proc arm64_32x8i type do return generic_wide(arm64_32x4i);
  proc arm64_64x4i type do return generic_wide(arm64_64x2i);


  inline proc type generic_wide.set(
    x0: laneType, x1: laneType, x2: laneType, x3: laneType,
    x4: laneType, x5: laneType, x6: laneType, x7: laneType,
    x8: laneType, x9: laneType, x10: laneType, x11: laneType,
    x12: laneType, x13: laneType, x14: laneType, x15: laneType,
    x16: laneType, x17: laneType, x18: laneType, x19: laneType,
    x20: laneType, x21: laneType, x22: laneType, x23: laneType,
    x24: laneType, x25: laneType, x26: laneType, x27: laneType,
    x28: laneType, x29: laneType, x30: laneType, x31: laneType
  ): vecType where offset == 16 do
    return new vecType(implVecType.set(x0, x1, x2, x3, x4, x5, x6, x7,
                                       x8, x9, x10, x11, x12, x13, x14, x15),
                       implVecType.set(x16, x17, x18, x19, x20, x21, x22, x23,
                                       x24, x25, x26, x27, x28, x29, x30, x31));

  inline proc type generic_wide.set(
    x0: laneType, x1: laneType, x2: laneType, x3: laneType,
    x4: laneType, x5: laneType, x6: laneType, x7: laneType,
    x8: laneType, x9: laneType, x10: laneType, x11: laneType,
    x12: laneType, x13: laneType, x14: laneType, x15: laneType
  ): vecType where offset == 8 do
    return new vecType(implVecType.set(x0, x1, x2, x3, x4, x5, x6, x7),
                       implVecType.set(x8, x9, x10, x11, x12, x13, x14, x15));

  inline proc type generic_wide.set(
    x0: laneType, x1: laneType, x2: laneType, x3: laneType,
    x4: laneType, x5: laneType, x6: laneType, x7: laneType
  ): vecType where offset == 4 do
    return new vecType(implVecType.set(x0, x1, x2, x3),
                       implVecType.set(x4, x5, x6, x7));

  inline proc type generic_wide.set(
    x0: laneType, x1: laneType, x2: laneType,x3: laneType
  ): vecType where offset == 2 do
    return new vecType(implVecType.set(x0, x1), implVecType.set(x2, x3));

}
