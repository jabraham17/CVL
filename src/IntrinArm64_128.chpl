@chplcheck.ignore("PascalCaseModules")
module IntrinArm64_128 {
  use CTypes only c_ptr, c_ptrConst, c_int;
  use Reflection only canResolveTypeMethod, getRoutineName;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    require "arm_neon.h";
    require "IntrinArm64_128/wrapper-arm64-128.h";
  }

  // these are all internal types
  extern "float32x4_t" type vec32x4r;
  extern "float64x2_t" type vec64x2r;
  extern "int8x16_t" type vec8x16i;
  extern "int16x8_t" type vec16x8i;
  extern "int32x4_t" type vec32x4i;
  extern "int64x2_t" type vec64x2i;
  extern "uint8x16_t" type vec8x16u;
  extern "uint16x8_t" type vec16x8u;
  extern "uint32x4_t" type vec32x4u;
  extern "uint64x2_t" type vec64x2u;

  // these are especially internal types
  extern "float32x2_t" type vec32x2r;
  extern "float64x1_t" type vec64x1r;
  extern "int8x8_t" type vec8x8i;
  extern "int16x4_t" type vec16x4i;
  extern "int32x2_t" type vec32x2i;
  extern "int64x1_t" type vec64x1i;
  extern "uint8x8_t" type vec8x8u;
  extern "uint16x4_t" type vec16x4u;
  extern "uint32x2_t" type vec32x2u;
  extern "uint64x1_t" type vec64x1u;

  proc numBits(type t) param: int
    where t == vec32x4r || t == vec64x2r ||
          t == vec8x16i || t == vec16x8i || t == vec32x4i || t == vec64x2i ||
          t == vec8x16u || t == vec16x8u || t == vec32x4u || t == vec64x2u
    do return 128;

  proc getHalfType(type t) type {
         if t == vec32x4r then return vec32x2r;
    else if t == vec64x2r then return vec64x1r;
    else if t == vec8x16i then return vec8x8i;
    else if t == vec16x8i then return vec16x4i;
    else if t == vec32x4i then return vec32x2i;
    else if t == vec64x2i then return vec64x1i;
    else if t == vec8x16u then return vec8x8u;
    else if t == vec16x8u then return vec16x4u;
    else if t == vec32x4u then return vec32x2u;
    else if t == vec64x2u then return vec64x1u;
    else compilerError("Unknown type: ", t);
  }

  proc getBitMaskType(type t) type {
          if t == vec32x4r then return vec32x4u;
      else if t == vec64x2r then return vec64x2u;
      else if t == vec8x16i then return vec8x16u;
      else if t == vec16x8i then return vec16x8u;
      else if t == vec32x4i then return vec32x4u;
      else if t == vec64x2i then return vec64x2u;
      else if t == vec8x16u then return vec8x16u;
      else if t == vec16x8u then return vec16x8u;
      else if t == vec32x4u then return vec32x4u;
      else if t == vec64x2u then return vec64x2u;
      else compilerError("Unknown type: ", t);
  }

  proc typeToSuffix(type t) param : string {
         if t == real(32) || t == vec32x4r || t == vec32x2r then return "f32";
    else if t == real(64) || t == vec64x2r || t == vec64x1r then return "f64";
    else if t == int(8)   || t == vec8x16i || t == vec8x8i  then return "s8";
    else if t == int(16)  || t == vec16x8i || t == vec16x4i then return "s16";
    else if t == int(32)  || t == vec32x4i || t == vec32x2i then return "s32";
    else if t == int(64)  || t == vec64x2i || t == vec64x1i then return "s64";
    else if t == uint(8)  || t == vec8x16u || t == vec8x8u  then return "u8";
    else if t == uint(16) || t == vec16x8u || t == vec16x4u then return "u16";
    else if t == uint(32) || t == vec32x4u || t == vec32x2u then return "u32";
    else if t == uint(64) || t == vec64x2u || t == vec64x1u then return "u64";
    else compilerError("Unknown type: ", t);
  }
  proc vecTypeStr(type t) param : string {
         if t == vec32x4r then return "32x4r";
    else if t == vec64x2r then return "64x2r";
    else if t == vec8x16i then return "8x16i";
    else if t == vec16x8i then return "16x8i";
    else if t == vec32x4i then return "32x4i";
    else if t == vec64x2i then return "64x2i";
    else if t == vec8x16u then return "8x16u";
    else if t == vec16x8u then return "16x8u";
    else if t == vec32x4u then return "32x4u";
    else if t == vec64x2u then return "64x2u";
    else compilerError("Unknown type: ", t);
  }


  /*
    Call a simple op on a vector type
    x must be a vector type and also specifies the return type
  */
   inline proc doSimpleOp(param op: string, x: ?t): t do
    return doSimpleOp(op, t, x);
  inline proc doSimpleOp(param op: string, x: ?t, y: ?): t do
    return doSimpleOp(op, t, x, y);
  inline proc doSimpleOp(param op: string, x: ?t, y: ?, z: ?): t do
    return doSimpleOp(op, t, x, y, z);
  /*
    Call a simple op on a vector type
    returnType specifies the return type
  */
  inline proc doSimpleOp(param op: string, type returnType, x: ?t): returnType {
    param externName = op + "_" + typeToSuffix(returnType);

    pragma "fn synchronization free"
    extern externName proc func(externX: t): returnType;

    return func(x);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2): returnType {
    param externName = op + "_" + typeToSuffix(returnType);

    pragma "fn synchronization free"
    extern externName proc func(externX: t1, externY: t2): returnType;

    return func(x, y);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2, z: ?t3): returnType {
    param externName = op + "_" + typeToSuffix(returnType);

    pragma "fn synchronization free"
    extern externName
    proc func(externX: t1, externY: t2, externZ: t3): returnType;

    return func(x, y, z);
  }


  inline proc reinterpret(vec: ?, type t): t {
    param fromType = typeToSuffix(vec.type);
    param toType = typeToSuffix(t);
    param externName = "vreinterpret_" + fromType + "_" + toType;

    pragma "fn synchronization free"
    extern externName proc func(externVec: vec.type): t;
    return func(vec);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_NxM {
    type extensionType;
    proc type vecType type do return extensionType.vecType;
    proc type laneType type do return extensionType.laneType;
    proc type numLanes param: int do
      return numBits(vecType) / numBits(laneType);

    inline proc type extract(x: vecType, param idx: int): laneType {
      if idx < 0 || idx >= numLanes then compilerError("invalid index");
      param externName = "get_lane_" + vecTypeStr(vecType) + idx:string;

      pragma "fn synchronization free"
      extern externName proc getLane(x: vecType): laneType;
      return getLane(x);
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      if idx < 0 || idx >= numLanes then compilerError("invalid index");
      param externName = "set_lane_" + vecTypeStr(vecType) + idx:string;

      pragma "fn synchronization free"
      extern externName proc setLane(x: vecType, y: laneType): vecType;
      return setLane(x, y);
    }
    inline proc type splat(x: laneType): vecType do
      return doSimpleOp("vdupq_n", vecType, x);
    inline proc type set(xs...): vecType do
      return extensionType.set((...xs));

    inline proc type loada(x: c_ptrConst(laneType)): vecType {
      param externName = "load" + vecTypeStr(vecType);
      pragma "fn synchronization free"
      extern externName proc load(x: c_ptrConst(laneType)): vecType;
      return load(x);
    }
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do return loada(x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      param externName = "store" + vecTypeStr(vecType);
      pragma "fn synchronization free"
      extern externName proc store(x: c_ptr(laneType), y: vecType): void;
      store(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void do
      storea(x, y);

    @chplcheck.ignore("UnusedFormal")
    inline proc type loadMasked(x: c_ptrConst(laneType), mask: ?): vecType {
      compilerError(getRoutineName() +
                    " is not supported with " +
                    laneType:string +
                    " on this platform");
    }

    @chplcheck.ignore("UnusedFormal")
    inline proc type gather(
      x: c_ptrConst(laneType),
      type indexType,
      indices: ?,
      param scale: int
    ): vecType {
      compilerError(getRoutineName() +
                    " is not supported with " +
                    laneType:string +
                    " on this platform");
    }
    @chplcheck.ignore("UnusedFormal")
    inline proc type gatherMasked(
      x: c_ptrConst(laneType),
      type indexType,
      indices: ?,
      param scale: int,
      mask: ?,
      src: vecType
    ): vecType {
      compilerError(getRoutineName() +
                    " is not supported with " +
                    laneType:string +
                    " on this platform");
    }


    // bit cast int to float or float to int
    // TODO im not happy with this api
    // inline proc type bitcast(x: vecType, type otherVecType): otherVecType

    inline proc type swapPairs(x: vecType): vecType do
      return extensionType.swapPairs(x);
    inline proc type swapLowHigh(x: vecType): vecType do
      return extensionType.swapLowHigh(x);
    inline proc type reverse(x: vecType): vecType do
      return extensionType.reverse(x);
    inline proc type rotateLeft(x: vecType): vecType do
      return extensionType.rotateLeft(x);
    inline proc type rotateRight(x: vecType): vecType do
      return extensionType.rotateRight(x);
    inline proc type interleaveLower(x: vecType, y: vecType): vecType do
      return doSimpleOp("vzip1q", x, y);
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType do
      return doSimpleOp("vzip2q", x, y);
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return doSimpleOp("vuzp1q", x, y);
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return doSimpleOp("vuzp2q", x, y);
    inline proc type blendLowHigh(x: vecType, y: vecType): vecType do
      return doSimpleOp("vcombine", vecType,
                doSimpleOp("vget_low", getHalfType(vecType), x),
                doSimpleOp("vget_high", getHalfType(vecType), y));


    inline proc type add(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "add", x, y) then
        return extensionType.add(x, y);
      else
        return doSimpleOp("vaddq", x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "sub", x, y) then
        return extensionType.sub(x, y);
      else
        return doSimpleOp("vsubq", x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "mul", x, y) then
        return extensionType.mul(x, y);
      else
        return doSimpleOp("vmulq", x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "div", x, y) then
        return extensionType.div(x, y);
      else
        return doSimpleOp("vdivq", x, y);
    }
    inline proc type neg(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "neg", x) then
        return extensionType.neg(x);
      else
        return doSimpleOp("vnegq", x);
    }

    inline proc type and(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "and", x, y) then
        return extensionType.and(x, y);
      else
        return doSimpleOp("vandq", x, y);
    }
    inline proc type or(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "or", x, y) then
        return extensionType.or(x, y);
      else
        return doSimpleOp("vorrq", x, y);
    }
    inline proc type xor(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "xor", x, y) then
        return extensionType.xor(x, y);
      else
        return doSimpleOp("veorq", x, y);
    }
    inline proc type not(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "not", x) then
        return extensionType.not(x);
      else
        return doSimpleOp("vmvnq", x);
    }
    inline proc type andNot(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "andNot", x, y) then
        return extensionType.andNot(x, y);
      else
        return doSimpleOp("vbicq", y, x);
    }
    // inline proc type shiftRightArith(x: vecType, param offset: int): vecType{
    //   if canResolveTypeMethod(extensionType, "shiftRightArith", x) then
    //     return extensionType.shiftRightArith(x);
    //   else
    //     return doSimpleOp("vshrq_n", x, offset);
    // TODO this is not going to work because of macros/const int issues
    // }
    // inline proc type shiftLeft(x: vecType, param offset: int): vecType {
    //   if canResolveTypeMethod(extensionType, "shiftLeft", x) then
    //     return extensionType.shiftLeft(x);
    //   else
    //     return doSimpleOp("vshlq_n", x, offset);
    // TODO this is not going to work because of macros/const int issues
    // }

    inline proc type cmpEq(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpEq", x, y) then
        return extensionType.cmpEq(x, y);
      else
        return doSimpleOp("vceqq", x, y);
    }
    inline proc type cmpNe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpNe", x, y) then
        return extensionType.cmpNe(x, y);
      else
        return not(cmpEq(x, y));
    }
    inline proc type cmpLt(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpLt", x, y) then
        return extensionType.cmpLt(x, y);
      else
        return doSimpleOp("vcltq", x, y);
    }
    inline proc type cmpLe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpLe", x, y) then
        return extensionType.cmpLe(x, y);
      else
        return doSimpleOp("vcleq", x, y);
    }
    inline proc type cmpGt(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpGt", x, y) then
        return extensionType.cmpGt(x, y);
      else
        return doSimpleOp("vcgtq", x, y);
    }
    inline proc type cmpGe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpGe", x, y) then
        return extensionType.cmpGe(x, y);
      else
        return doSimpleOp("vcgeq", x, y);
    }
    inline proc type bitSelect(mask: ?, x: vecType, y: vecType): vecType
      where numBits(mask.type) == numBits(vecType) {
      if canResolveTypeMethod(extensionType, "bitSelect", mask, x, y) then
        return extensionType.bitSelect(mask, x, y);
      else {
        // var maskT = reinterpret(mask, getBitMaskType(vecType));
        return doSimpleOp("vbslq", vecType, mask, x, y);
      }
    }

    inline proc type min(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "min", x, y) then
        return extensionType.min(x, y);
      else
        return doSimpleOp("vminq", x, y);
    }
    inline proc type max(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "max", x, y) then
        return extensionType.max(x, y);
      else
        return doSimpleOp("vmaxq", x, y);
    }
    inline proc type abs(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "abs", x) then
        return extensionType.abs(x);
      else
        return doSimpleOp("vabsq", x);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "hadd", x, y) then
        return extensionType.hadd(x, y);
      else {
        var temp = doSimpleOp("vpaddq", x, y);
        return interleaveLower(temp, swapLowHigh(temp));
      }
    }

    inline proc type sqrt(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "sqrt", x) then
        return extensionType.sqrt(x);
      else
        return doSimpleOp("vsqrtq", x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rsqrt", x) then
        return extensionType.rsqrt(x);
      else
        return doSimpleOp("vrsqrteq", x);
    }

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      if canResolveTypeMethod(extensionType, "fmadd", x, y, z) then
        return extensionType.fmadd(x, y, z);
      else
        return doSimpleOp("vfmaq", z, x, y); // arm fma has weird order
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      if canResolveTypeMethod(extensionType, "fmsub", x, y, z) then
        return extensionType.fmsub(x, y, z);
      else
        return fmadd(x, y, doSimpleOp("vnegq", z));
    }
  }


  @chplcheck.ignore("CamelCaseFunctions")
  proc arm64_32x4r type do return arm64_NxM(arm64_32x4r_extension(
                                    arm64_NxM(arm64_32x4r_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc arm64_64x2r type do return arm64_NxM(arm64_64x2r_extension(
                                    arm64_NxM(arm64_64x2r_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc arm64_8x16i type do return arm64_NxM(arm64_8x16i_extension(
                                    arm64_NxM(arm64_8x16i_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc arm64_16x8i type do return arm64_NxM(arm64_16x8i_extension(
                                    arm64_NxM(arm64_16x8i_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc arm64_32x4i type do return arm64_NxM(arm64_32x4i_extension(
                                    arm64_NxM(arm64_32x4i_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc arm64_64x2i type do return arm64_NxM(arm64_64x2i_extension(
                                    arm64_NxM(arm64_64x2i_extension(nothing))));

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_32x4r_extension {
    type base;
    proc type vecType type do return vec32x4r;
    proc type laneType type do return real(32);

    inline proc type set(x: laneType,
                         y: laneType,
                         z: laneType,
                         w: laneType): vecType {
      var result: vecType;
      result = base.splat(x);
      result = base.insert(result, y, 1);
      result = base.insert(result, z, 2);
      result = base.insert(result, w, 3);
      return result;
    }

    // inline proc type bitcast(x: vecType, type otherVecType): otherVecType {
    //   if otherVecType != vec32x4i then compilerError("Unsupported bitcast");
    //   pragma "fn synchronization free"
    //   extern proc vreinterpretq_s32_f32(x: vecType): vec32x4i;
    //   return vreinterpretq_s32_f32(x);
    // }
    inline proc type swapPairs(x: vecType): vecType {
      return doSimpleOp("vrev64q", x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4r2(x: vecType, y: vecType): vecType;
      return extractVector32x4r2(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return base.swapPairs(base.swapLowHigh(x));
    }
    inline proc type rotateLeft(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4r1(x: vecType, y: vecType): vecType;
      return extractVector32x4r1(x, x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4r3(x: vecType, y: vecType): vecType;
      return extractVector32x4r3(x, x);
    }

    inline proc type and(x: vecType, y: vecType): vecType {
      // no vandq_f32, convert to mask type, do and, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vandq", maskX, maskY), vecType);
    }
    inline proc type or(x: vecType, y: vecType): vecType {
      // no vorrq_f32, convert to mask type, do or, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vorrq", maskX, maskY), vecType);
    }
    inline proc type xor(x: vecType, y: vecType): vecType {
      // no veorq_f32, convert to mask type, do xor, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("veorq", maskX, maskY), vecType);
    }
    inline proc type not(x: vecType): vecType {
      // no vmvnq_f32, convert to mask type, do not, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vmvnq", maskX), vecType);
    }
    inline proc type andNot(x: vecType, y: vecType): vecType {
      // no vbicq_f32, convert to mask type, do and not, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vbicq", maskY, maskX), vecType);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_64x2r_extension {
    type base;
    proc type vecType type do return vec64x2r;
    proc type laneType type do return real(64);

    inline proc type set(x: laneType, y: laneType): vecType {
      var result: vecType;
      result = base.splat(x);
      result = base.insert(result, y, 1);
      return result;
    }
    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector64x2r1(x: vecType, y: vecType): vecType;
      return extractVector64x2r1(x, x);
    }
    inline proc type swapLowHigh(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do
      return base.swapPairs(x);

    inline proc type and(x: vecType, y: vecType): vecType {
      // no vandq_f64, convert to mask type, do and, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vandq", maskX, maskY), vecType);
    }
    inline proc type or(x: vecType, y: vecType): vecType {
      // no vorrq_f64, convert to mask type, do or, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vorrq", maskX, maskY), vecType);
    }
    inline proc type xor(x: vecType, y: vecType): vecType {
      // no veorq_f64, convert to mask type, do xor, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("veorq", maskX, maskY), vecType);
    }
    inline proc type not(x: vecType): vecType {
      // no vmvnq_f64, convert to mask type, do not, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vmvnq", maskX), vecType);
    }
    inline proc type andNot(x: vecType, y: vecType): vecType {
      // no vbicq_f64, convert to mask type, do and not, convert back
      var maskX = reinterpret(x, getBitMaskType(vecType));
      var maskY = reinterpret(y, getBitMaskType(vecType));
      return reinterpret(doSimpleOp("vbicq", maskY, maskX), vecType);
    }

  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_8x16i_extension {
    type base;
    proc type vecType type do return vec8x16i;
    proc type laneType type do return int(8);

    inline proc type set(
      x: laneType, y: laneType, z: laneType, w: laneType,
      a: laneType, b: laneType, c: laneType, d: laneType,
      e: laneType, f: laneType, g: laneType, h: laneType,
      i: laneType, j: laneType, k: laneType, l: laneType
    ): vecType {
      var result: vecType;
      result = base.splat(x);
      result = base.insert(result, y, 1);
      result = base.insert(result, z, 2);
      result = base.insert(result, w, 3);
      result = base.insert(result, a, 4);
      result = base.insert(result, b, 5);
      result = base.insert(result, c, 6);
      result = base.insert(result, d, 7);
      result = base.insert(result, e, 8);
      result = base.insert(result, f, 9);
      result = base.insert(result, g, 10);
      result = base.insert(result, h, 11);
      result = base.insert(result, i, 12);
      result = base.insert(result, j, 13);
      result = base.insert(result, k, 14);
      result = base.insert(result, l, 15);
      return result;
    }


    inline proc type swapPairs(x: vecType): vecType {
      return doSimpleOp("vrev16q", x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector8x16i8(x: vecType, y: vecType): vecType;
      return extractVector8x16i8(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return base.swapPairs(base.swapLowHigh(x));
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

    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to int 16
      // convert to float16
      // do float division
      // convert back to int16
      // convert back to int8
      extern "float16x8_t" type vec16x8r;
      pragma "fn synchronization free"
      extern proc vmovl_s8(x: vecType): vec16x8i;
      pragma "fn synchronization free"
      extern proc vmovl_high_s8(x: vecType): vec16x8i;
      pragma "fn synchronization free"
      extern proc vmovn_s16(x: vec16x8i): vec8x8i;
      pragma "fn synchronization free"
      extern proc vmovn_high_s16(x: vec8x8i, y: vec16x8i): vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_f16_s16(x: vec16x8i): vec16x8r;
      pragma "fn synchronization free"
      extern proc vcvtq_s16_f16(x: vec16x8r): vec16x8i;
      pragma "fn synchronization free"
      extern proc vcvtq_s16_s8(x: vec16x8i): vecType;
      pragma "fn synchronization free"
      extern proc vdivq_f16(x: vec16x8r, y: vec16x8r): vec16x8r;

      inline proc inner(x: vec16x8i, y: vec16x8i): vec16x8i {
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

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      return base.add(base.mul(x, y), z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      return base.sub(base.mul(x, y), z);
    }

  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_16x8i_extension {
    type base;
    proc type vecType type do return vec16x8i;
    proc type laneType type do return int(16);

    inline proc type set(
      x: laneType, y: laneType, z: laneType, w: laneType,
      a: laneType, b: laneType, c: laneType, d: laneType
    ): vecType {
      var result: vecType;
      result = base.splat(x);
      result = base.insert(result, y, 1);
      result = base.insert(result, z, 2);
      result = base.insert(result, w, 3);
      result = base.insert(result, a, 4);
      result = base.insert(result, b, 5);
      result = base.insert(result, c, 6);
      result = base.insert(result, d, 7);
      return result;
    }

    inline proc type swapPairs(x: vecType): vecType {
      return doSimpleOp("vrev32q", x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector16x8i4(x: vecType, y: vecType): vecType;
      return extractVector16x8i4(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return base.swapPairs(base.swapLowHigh(x));
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

    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to int 32
      // convert to float32
      // do float division
      // convert back to int32
      // convert back to int16
      pragma "fn synchronization free"
      extern proc vmovl_s16(x: vecType): vec32x4i;
      pragma "fn synchronization free"
      extern proc vmovl_high_s16(x: vecType): vec32x4i;
      pragma "fn synchronization free"
      extern proc vmovn_s32(x: vec32x4i): vec16x4i;
      pragma "fn synchronization free"
      extern proc vmovn_high_s32(x: vec16x4i, y: vec32x4i): vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_f32_s32(x: vec32x4i): vec32x4r;
      pragma "fn synchronization free"
      extern proc vcvtq_s32_f32(x: vec32x4r): vec32x4i;
      pragma "fn synchronization free"
      extern proc vcvtq_s32_s16(x: vec32x4i): vecType;
      pragma "fn synchronization free"
      extern proc vdivq_f32(x: vec32x4r, y: vec32x4r): vec32x4r;

      inline proc inner(x: vec32x4i, y: vec32x4i): vec32x4i {
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

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      return base.add(base.mul(x, y), z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      return base.sub(base.mul(x, y), z);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_32x4i_extension {
    type base;
    proc type vecType type do return vec32x4i;
    proc type laneType type do return int(32);

    inline proc type set(x: laneType, y: laneType,
                         z: laneType, w: laneType): vecType {
      var result: vecType;
      result = base.splat(x);
      result = base.insert(result, y, 1);
      result = base.insert(result, z, 2);
      result = base.insert(result, w, 3);
      return result;
    }

    inline proc type swapPairs(x: vecType): vecType {
      return doSimpleOp("vrev64q", x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector32x4i2(x: vecType, y: vecType): vecType;
      return extractVector32x4i2(x, x);
    }
    inline proc type reverse(x: vecType): vecType {
      return base.swapPairs(base.swapLowHigh(x));
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

    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y because neon does not have integer division
      // emulate it
      // convert to float32
      // do float division
      // convert back to int32
      pragma "fn synchronization free"
      extern proc vcvtq_f32_s32(x: vecType): arm64_32x4r.vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_s32_f32(x: arm64_32x4r.vecType): vecType;

      var x_f32 = vcvtq_f32_s32(x);
      var y_f32 = vcvtq_f32_s32(y);
      var res_f32 = arm64_32x4r.div(x_f32, y_f32);
      return vcvtq_s32_f32(res_f32);
    }

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      return base.add(base.mul(x, y), z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      return base.sub(base.mul(x, y), z);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record arm64_64x2i_extension {
    type base;
    proc type vecType type do return vec64x2i;
    proc type laneType type do return int(64);

    inline proc type set(x: laneType, y: laneType): vecType {
      var result: vecType;
      result = base.splat(x);
      result = base.insert(result, y, 1);
      return result;
    }

    inline proc type swapPairs(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc extractVector64x2i1(x: vecType, y: vecType): vecType;
      return extractVector64x2i1(x, x);
    }
    inline proc type swapLowHigh(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do
      return base.swapPairs(x);

    inline proc type div(x: vecType, y: vecType): vecType {
      // cant do x/y becase neon does not have integer division
      // emulate it
      // convert to float64
      // do float division
      // convert back to int64
      pragma "fn synchronization free"
      extern proc vcvtq_f64_s64(x: vecType): arm64_64x2r.vecType;
      pragma "fn synchronization free"
      extern proc vcvtq_s64_f64(x: arm64_64x2r.vecType): vecType;

      var x_f64 = vcvtq_f64_s64(x);
      var y_f64 = vcvtq_f64_s64(y);
      var res_f64 = arm64_64x2r.div(x_f64, y_f64);
      return vcvtq_s64_f64(res_f64);
    }

    inline proc type min(x: vecType, y: vecType): vecType {
      // no vminq_s64, emulate with cmp and select
      return base.bitSelect(base.cmpLt(x, y), x, y);
    }
    inline proc type max(x: vecType, y: vecType): vecType {
      // no vmaxq_s64, emulate with cmp and select
      return base.bitSelect(base.cmpGt(x, y), x, y);
    }

  }



}
