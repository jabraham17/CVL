@chplcheck.ignore("PascalCaseModules")
module IntrinX86_128 {
  use CTypes only c_ptr, c_ptrConst, c_int;
  use Reflection only canResolveTypeMethod;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "wrapper-x86-128.h";
    // require "wrapper-x86-128.c";
  }

  extern "__m128" type vec32x4r;
  extern "__m128d" type vec64x2r;
  extern "__m128i" type vec8x16i;
  extern "__m128i" type vec16x8i;
  extern "__m128i" type vec32x4i;
  extern "__m128i" type vec64x2i;
  extern "__m128i" type vec8x16u;
  extern "__m128i" type vec16x8u;
  extern "__m128i" type vec32x4u;
  extern "__m128i" type vec64x2u;

  proc numBits(type t) param: int
    where t == vec32x4r || t == vec64x2r ||
          t == vec8x16i || t == vec16x8i || t == vec32x4i || t == vec64x2i ||
          t == vec8x16u || t == vec16x8u || t == vec32x4u || t == vec64x2u
    do return 128;

  proc typeToSuffix(type t) param : string {
         if t == real(32) || t == vec32x4r then return "ps";
    else if t == real(64) || t == vec64x2r then return "pd";
    else if t == int(8)   || t == vec8x16i then return "epi8";
    else if t == int(16)  || t == vec16x8i then return "epi16";
    else if t == int(32)  || t == vec32x4i then return "epi32";
    else if t == int(64)  || t == vec64x2i then return "epi64";
    else if t == uint(8)  || t == vec8x16u then return "epu8";
    else if t == uint(16) || t == vec16x8u then return "epu16";
    else if t == uint(32) || t == vec32x4u then return "epu32";
    else if t == uint(64) || t == vec64x2u then return "epu64";
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
  inline proc doSimpleOp(param op: string, xs): xs(0).type where isTuple(xs) do
    return doSimpleOp(op, xs(0).type, xs);
  /*
    Call a simple op on a vector type
    returnType specifies the return type
  */
  inline proc doSimpleOp(param op: string, type returnType, x: ?t): returnType {
    param externName = op + typeToSuffix(returnType);

    pragma "fn synchronization free"
    extern externName proc func(externX: t): returnType;

    return func(x);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2): returnType {
    param externName = op + typeToSuffix(returnType);

    pragma "fn synchronization free"
    extern externName proc func(externX: t1, externY: t2): returnType;

    return func(x, y);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2, z: ?t3): returnType {
    param externName = op + typeToSuffix(returnType);

    pragma "fn synchronization free"
    extern externName
    proc func(externX: t1, externY: t2, externZ: t3): returnType;

    return func(x, y, z);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType, xs): returnType where isTuple(xs) {
    param externName = op + typeToSuffix(returnType);

    // workaround for https://github.com/chapel-lang/chapel/issues/26759
    param nArgs = xs.size;

    pragma "fn synchronization free"
    extern externName proc func(args...nArgs): returnType;

    return func((...xs));
  }



  // inline operator:(x: vec128d, type t: vec128) {
  //   pragma "fn synchronization free"
  //   extern proc _mm_castpd_ps(x: vec128d): vec128;
  //   return _mm_castpd_ps(x);
  // }
  // inline operator:(x: vec128, type t: vec128d) {
  //   pragma "fn synchronization free"
  //   extern proc _mm_castps_pd(x: vec128): vec128d;
  //   return _mm_castps_pd(x);
  // }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_NxM {
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
      return doSimpleOp("_mm_set1_", vecType, x);
    inline proc type set(xs...): vecType do
      return doSimpleOp("_mm_setr_", vecType, xs);

    inline proc type loada(x: c_ptrConst(laneType)): vecType do
      return doSimpleOp("_mm_load_", vecType, x);
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return doSimpleOp("_mm_loadu_", vecType, x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      param externName = "_mm_store_" + typeToSuffix(vecType);
      pragma "fn synchronization free"
      extern externName proc store(x: c_ptr(laneType), y: vecType): void;
      store(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void {
      param externName = "_mm_storeu_" + typeToSuffix(vecType);
      pragma "fn synchronization free"
      extern externName proc store(x: c_ptr(laneType), y: vecType): void;
      store(x, y);
    }

    // bit cast int to float or float to int
    // TODO im not happy with this api
    // inline proc type bitcast(x: vecType, type otherVecType): otherVecType

    inline proc type swapPairs(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "swapPairs", x) then
        return extensionType.swapPairs(x);
      else
        return doSimpleOp("swapPairs_", x);
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "swapLowHigh", x) then
        return extensionType.swapLowHigh(x);
      else
        return doSimpleOp("swapLowHigh_", x);
    }
    inline proc type reverse(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "reverse", x) then
        return extensionType.reverse(x);
      else
        return doSimpleOp("reverse_", x);
    }
    inline proc type rotateLeft(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rotateLeft", x) then
        return extensionType.rotateLeft(x);
      else
        return doSimpleOp("rotateLeft_", x);
    }
    inline proc type rotateRight(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rotateRight", x) then
        return extensionType.rotateRight(x);
      else
        return doSimpleOp("rotateRight_", x);
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType do
      return doSimpleOp("_mm_unpacklo_", x, y);
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType do
      return doSimpleOp("_mm_unpackhi_", x, y);
    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return this.interleaveLower(
        this.interleaveLower(x, y),
        this.interleaveUpper(x, y));

    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return this.interleaveUpper(
        this.interleaveLower(x, y),
        this.interleaveUpper(x, y));

    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "blendLowHigh", x, y) then
        return extensionType.blendLowHigh(x, y);
      else
        return doSimpleOp("blendLowHigh_", x, y);
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "add", x, y) then
        return extensionType.add(x, y);
      else
        return doSimpleOp("_mm_add_", x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "sub", x, y) then
        return extensionType.sub(x, y);
      else
        return doSimpleOp("_mm_sub_", x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "mul", x, y) then
        return extensionType.mul(x, y);
      else
        return doSimpleOp("_mm_mul_", x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "div", x, y) then
        return extensionType.div(x, y);
      else
        return doSimpleOp("_mm_div_", x, y);
    }
    inline proc type neg(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "neg", x) then
        return extensionType.neg(x);
      else {
        return this.sub(this.splat(0), x);
      }
    }

    inline proc type and(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "and", x, y) then
        return extensionType.and(x, y);
      else {
        pragma "fn synchronization free"
        extern proc _mm_and_si128(x: vecType, y: vecType): vecType;
        return _mm_and_si128(x, y);
      }
    }
    inline proc type or(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "or", x, y) then
        return extensionType.or(x, y);
      else {
        pragma "fn synchronization free"
        extern proc _mm_or_si128(x: vecType, y: vecType): vecType;
        return _mm_or_si128(x, y);
      }
    }
    inline proc type xor(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "xor", x, y) then
        return extensionType.xor(x, y);
      else {
        pragma "fn synchronization free"
        extern proc _mm_xor_si128(x: vecType, y: vecType): vecType;
        return _mm_xor_si128(x, y);
      }
    }
    inline proc type not(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "not", x) then
        return extensionType.not(x);
      else {
        // or with 1
        // TODO: revalidate this
        return this.xor(x, this.splat(-1));

      }
    }
    inline proc type andNot(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "andNot", x, y) then
        return extensionType.andNot(x, y);
      else {
        pragma "fn synchronization free"
        extern proc _mm_andnot_si128(x: vecType, y: vecType): vecType;
        return _mm_andnot_si128(x, y);
      }
    }
    // inline proc type shiftRightArith(x: vecType, param offset: int): vecType {
    //   if canResolveTypeMethod(extensionType, "shiftRightArith", x) then
    //     return extensionType.shiftRightArith(x);
    //   else
    //     return doSimpleOp("vshrq_n", x, offset); // TODO this is not going to work because of macros/const int issues
    // }
    // inline proc type shiftLeft(x: vecType, param offset: int): vecType {
    //   if canResolveTypeMethod(extensionType, "shiftLeft", x) then
    //     return extensionType.shiftLeft(x);
    //   else
    //     return doSimpleOp("vshlq_n", x, offset); // TODO this is not going to work because of macros/const int issues
    // }

    inline proc type cmpEq(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpEq", x, y) then
        return extensionType.cmpEq(x, y);
      else
        return doSimpleOp("_mm_cmpeq_", x, y);
    }
    inline proc type cmpNe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpNe", x, y) then
        return extensionType.cmpNe(x, y);
      else
        return doSimpleOp("_mm_cmpne_", x, y);
    }
    inline proc type cmpLt(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpLt", x, y) then
        return extensionType.cmpLt(x, y);
      else
        return doSimpleOp("_mm_cmplt_", x, y);
    }
    inline proc type cmpLe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpLe", x, y) then
        return extensionType.cmpLe(x, y);
      else
        return doSimpleOp("_mm_cmple_", x, y);
    }
    inline proc type cmpGt(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpGt", x, y) then
        return extensionType.cmpGt(x, y);
      else
        return doSimpleOp("_mm_cmpgt_", x, y);
    }
    inline proc type cmpGe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpGe", x, y) then
        return extensionType.cmpGe(x, y);
      else
        return doSimpleOp("_mm_cmpge_", x, y);
    }
    inline proc type bitSelect(mask: ?, x: vecType, y: vecType): vecType
      where numBits(mask.type) == numBits(vecType) {
      if canResolveTypeMethod(extensionType, "bitSelect", mask, x, y) then
        return extensionType.bitSelect(mask, x, y);
      else {
        import CVI;
        if CVI.implementationWarnings then
          compilerWarning("bitSelect is unimplemented");
        // _mm_or_si128(_mm_and_si128(mask, a), _mm_andnot_si128(mask, b));
        return x; // TODO
      }
    }

    inline proc type min(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "min", x, y) then
        return extensionType.min(x, y);
      else
        return doSimpleOp("_mm_max_", x, y);
    }
    inline proc type max(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "max", x, y) then
        return extensionType.max(x, y);
      else
        return doSimpleOp("_mm_min_", x, y);
    }
    inline proc type abs(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "abs", x) then
        return extensionType.abs(x);
      else
        return doSimpleOp("_mm_abs_", x);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType do
      if canResolveTypeMethod(extensionType, "hadd", x, y) then
        return extensionType.hadd(x, y);
      else
        return doSimpleOp("_mm_hadd_", x, y);

    inline proc type sqrt(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "sqrt", x) then
        return extensionType.sqrt(x);
      else
        return doSimpleOp("_mm_sqrt_", x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rsqrt", x) then
        return extensionType.rsqrt(x);
      else
        return doSimpleOp("_mm_rsqrt_", x);
    }

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      if canResolveTypeMethod(extensionType, "fmadd", x, y, z) then
        return extensionType.fmadd(x, y, z);
      else
        return doSimpleOp("_mm_fmadd_", x, y, z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      if canResolveTypeMethod(extensionType, "fmsub", x, y, z) then
        return extensionType.fmsub(x, y, z);
      else
        return doSimpleOp("_mm_fmsub_", x, y, z);
    }
  }


  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_32x4r type do return x8664_NxM(x8664_32x4r_extension(
                                  x8664_NxM(x8664_32x4r_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_64x2r type do return x8664_NxM(x8664_64x2r_extension(
                                  x8664_NxM(x8664_64x2r_extension(nothing))));
  // note: the int cases need extra recursion to work properly
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_8x16i type do return x8664_NxM(x8664_8x16i_extension(
                                  x8664_NxM(x8664_8x16i_extension(
                                  x8664_NxM(x8664_8x16i_extension(nothing))))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_16x8i type do return x8664_NxM(x8664_16x8i_extension(
                                  x8664_NxM(x8664_16x8i_extension(
                                  x8664_NxM(x8664_16x8i_extension(nothing))))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_32x4i type do return x8664_NxM(x8664_32x4i_extension(
                                  x8664_NxM(x8664_32x4i_extension(
                                  x8664_NxM(x8664_32x4i_extension(nothing))))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_64x2i type do return x8664_NxM(x8664_64x2i_extension(
                                  x8664_NxM(x8664_64x2i_extension(
                                  x8664_NxM(x8664_64x2i_extension(nothing))))));



  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_32x4r_extension {
    type base;
    proc type vecType type do return vec32x4r;
    proc type laneType type do return real(32);

    inline proc type hadd(x: vecType, y: vecType): vecType do
      return doSimpleOp("hadd", x, y);

    inline proc type abs(x: vecType): vecType {
      var mask = base.splat(0x7FFFFFFF:laneType);
      return doSimpleOp("_mm_and_", x, mask);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_64x2r_extension {
    type base;
    proc type vecType type do return vec64x2r;
    proc type laneType type do return real(64);

    inline proc type swapLowHigh(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do
      return base.swapPairs(x);

    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm_cvtpd_ps(x: vecType): x8664_32x4r.vecType;
      pragma "fn synchronization free"
      extern proc _mm_cvtps_pd(x: x8664_32x4r.vecType): vecType;

      var three = base.splat(3.0);
      var half = base.splat(0.5);

      var x_ps = _mm_cvtpd_ps(x);
      // do rsqrt at 32-bit precision
      var res = _mm_cvtps_pd(x8664_32x4r.rsqrt(x_ps));

      // TODO: would an FMA version be faster?
      // Newton-Raphson iteration
      // q = 0.5 * x * (3 - x * res * res)
      var muls = base.mul(base.mul(x, res), res);
      res = base.mul(base.mul(half, res), base.sub(three, muls));

      return res;
    }
    inline proc type abs(x: vecType): vecType {
      var mask = base.splat(0x7FFFFFFFFFFFFFFF:laneType);
      return doSimpleOp("_mm_and_", x, mask);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_8x16i_extension {
    type base;
    proc type vecType type do return vec8x16i;
    proc type laneType type do return int(8);

    inline proc type mul(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'mul' on int(8) is implemented as scalar operations");
      // TODO: theres no mul_epi8 instruction, we can emulate with mullo_epi16
      // the loop here is painfully slow
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) * base.extract(y, i), i);
      }
      return res;
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'div' on int(8) is implemented as scalar operations");
      // TODO: theres no div_epi8 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'hadd' on int(8) is implemented as scalar operations");
      // TODO: theres no hadd_epi8 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..#base.numLanes by 2 {
        res = base.insert(res, base.extract(x, i) + base.extract(x, i+1), i);
        res = base.insert(res, base.extract(y, i) + base.extract(y, i+1), i+1);
      }
      return res;
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return base.add(base.mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return base.sub(base.mul(x, y), z);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_16x8i_extension {
    type base;
    proc type vecType type do return vec16x8i;
    proc type laneType type do return int(16);

    inline proc type mul(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'mul' on int(16) is implemented as scalar operations");
      // TODO: theres no mul_epi16 instruction, we can emulate with mullo_epi16
      // and mulhi_epi16
      // the loop here is painfully slow
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) * base.extract(y, i), i);
      }
      return res;
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'div' on int(16) is implemented as scalar operations");
      // TODO: theres no div_epi16 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return base.add(base.mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return base.sub(base.mul(x, y), z);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_32x4i_extension {
    type base;
    proc type vecType type do return vec32x4i;
    proc type laneType type do return int(32);

    inline proc type div(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'div' on int(32) is implemented as scalar operations");
      // TODO: theres no div_epi16 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return base.add(base.mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return base.sub(base.mul(x, y), z);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_64x2i_extension {
    type base;
    proc type vecType type do return vec64x2i;
    proc type laneType type do return int(64);

    inline proc type div(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'div' on int(64) is implemented as scalar operations");
      // TODO: theres no div_epi16 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }
    inline proc type hadd(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'hadd' on int(64) is implemented as scalar operations");
      // TODO: theres no hadd_epi8 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..#base.numLanes by 2 {
        res = base.insert(res, base.extract(x, i) + base.extract(x, i+1), i);
        res = base.insert(res, base.extract(y, i) + base.extract(y, i+1), i+1);
      }
      return res;
    }
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return base.add(base.mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return base.sub(base.mul(x, y), z);
  }

  // @chplcheck.ignore("CamelCaseRecords")
  // @lint.typeOnly
  // record x8664_32x4r {
  //   proc type vecType type do return vec32x4r;
  //   proc type laneType type do return real(32);

  //   inline proc type extract(x: vecType, param idx: int): laneType {
  //     pragma "fn synchronization free"
  //     extern proc extract32x4r0(x: vecType): laneType;
  //     pragma "fn synchronization free"
  //     extern proc extract32x4r1(x: vecType): laneType;
  //     pragma "fn synchronization free"
  //     extern proc extract32x4r2(x: vecType): laneType;
  //     pragma "fn synchronization free"
  //     extern proc extract32x4r3(x: vecType): laneType;

  //     if idx == 0      then return extract32x4r0(x);
  //     else if idx == 1 then return extract32x4r1(x);
  //     else if idx == 2 then return extract32x4r2(x);
  //     else if idx == 3 then return extract32x4r3(x);
  //     else compilerError("invalid index");
  //   }
  //   inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
  //     pragma "fn synchronization free"
  //     extern proc insert32x4r0(x: vecType, y: laneType): vecType;
  //     pragma "fn synchronization free"
  //     extern proc insert32x4r1(x: vecType, y: laneType): vecType;
  //     pragma "fn synchronization free"
  //     extern proc insert32x4r2(x: vecType, y: laneType): vecType;
  //     pragma "fn synchronization free"
  //     extern proc insert32x4r3(x: vecType, y: laneType): vecType;

  //     if idx == 0      then return insert32x4r0(x, y);
  //     else if idx == 1 then return insert32x4r1(x, y);
  //     else if idx == 2 then return insert32x4r2(x, y);
  //     else if idx == 3 then return insert32x4r3(x, y);
  //     else compilerError("invalid index");
  //   }

  //   inline proc type splat(x: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_set1_ps(x: laneType): vecType;
  //     return _mm_set1_ps(x);
  //   }
  //   inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_setr_ps(x: laneType, y: laneType, z: laneType, w: laneType): vecType;
  //     return _mm_setr_ps(x, y, z, w);
  //   }
  //   inline proc type loada(x: c_ptrConst(real(32))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_load_ps(x: c_ptrConst(real(32))): vecType;
  //     return _mm_load_ps(x);
  //   }
  //   inline proc type storea(x: c_ptr(real(32)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm_store_ps(x: c_ptr(real(32)), y: vecType): void;
  //     _mm_store_ps(x, y);
  //   }
  //   inline proc type loadu(x: c_ptrConst(real(32))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_loadu_ps(x: c_ptrConst(real(32))): vecType;
  //     return _mm_loadu_ps(x);
  //   }
  //   inline proc type storeu(x: c_ptr(real(32)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm_storeu_ps(x: c_ptr(real(32)), y: vecType): void;
  //     _mm_storeu_ps(x, y);
  //   }

  //   inline proc type swapPairs(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapPairs32x4r(x: vecType): vecType;
  //     return swapPairs32x4r(x);
  //   }
  //   inline proc type swapLowHigh(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapLowHigh32x4r(x: vecType): vecType;
  //     return swapLowHigh32x4r(x);
  //   }
  //   inline proc type reverse(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc reverse32x4r(x: vecType): vecType;
  //     return reverse32x4r(x);
  //   }
  //   inline proc type rotateLeft(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc rotateLeft32x4r(x: vecType): vecType;
  //     return rotateLeft32x4r(x);
  //   }
  //   inline proc type rotateRight(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc rotateRight32x4r(x: vecType): vecType;
  //     return rotateRight32x4r(x);
  //   }
  //   inline proc type interleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_unpacklo_ps(x: vecType, y: vecType): vecType;
  //     return _mm_unpacklo_ps(x, y);
  //   }
  //   inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_unpackhi_ps(x: vecType, y: vecType): vecType;
  //     return _mm_unpackhi_ps(x, y);
  //   }
  //   inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
  //     return this.interleaveLower(this.interleaveLower(x, y), this.interleaveUpper(x, y));
  //   inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
  //     return this.interleaveUpper(this.interleaveLower(x, y), this.interleaveUpper(x, y));
  //   inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc blendLowHigh32x4r(x: vecType, y: vecType): vecType;
  //     return blendLowHigh32x4r(x, y);
  //   }

  //   inline proc type add(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_add_ps(x: vecType, y: vecType): vecType;
  //     return _mm_add_ps(x, y);
  //   }
  //   inline proc type sub(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_sub_ps(x: vecType, y: vecType): vecType;
  //     return _mm_sub_ps(x, y);
  //   }
  //   inline proc type mul(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_mul_ps(x: vecType, y: vecType): vecType;
  //     return _mm_mul_ps(x, y);
  //   }
  //   inline proc type div(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_div_ps(x: vecType, y: vecType): vecType;
  //     return _mm_div_ps(x, y);
  //   }
  //   inline proc type hadd(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc hadd32x4r(x: vecType, y: vecType): vecType;
  //     return hadd32x4r(x, y);
  //   }

  //   inline proc type sqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_sqrt_ps(x: vecType): vecType;
  //     return _mm_sqrt_ps(x);
  //   }
  //   inline proc type rsqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_rsqrt_ps(x: vecType): vecType;
  //     return _mm_rsqrt_ps(x);
  //   }
  //   inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_fmadd_ps(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm_fmadd_ps(x, y, z);
  //   }
  //   inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_fmsub_ps(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm_fmsub_ps(x, y, z);
  //   }
  // }

  // @chplcheck.ignore("CamelCaseRecords")
  // @lint.typeOnly
  // record x8664_64x2r {
  //   proc type vecType type do return vec64x2r;
  //   proc type laneType type do return real(64);

  //   inline proc type extract(x: vecType, param idx: int): laneType {
  //     pragma "fn synchronization free"
  //     extern proc extract64x2r0(x: vecType): laneType;
  //     pragma "fn synchronization free"
  //     extern proc extract64x2r1(x: vecType): laneType;

  //     if idx == 0      then return extract64x2r0(x);
  //     else if idx == 1 then return extract64x2r1(x);
  //     else compilerError("invalid index");
  //   }
  //   inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
  //     pragma "fn synchronization free"
  //     extern proc insert64x2r0(x: vecType, y: laneType): vecType;
  //     pragma "fn synchronization free"
  //     extern proc insert64x2r1(x: vecType, y: laneType): vecType;

  //     if idx == 0      then return insert64x2r0(x, y);
  //     else if idx == 1 then return insert64x2r1(x, y);
  //     else compilerError("invalid index");
  //   }

  //   inline proc type splat(x: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_set1_pd(x: laneType): vecType;
  //     return _mm_set1_pd(x);
  //   }
  //   inline proc type set(x: laneType, y: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_setr_pd(x: laneType, y: laneType): vecType;
  //     return _mm_setr_pd(x, y);
  //   }
  //   inline proc type loada(x: c_ptrConst(real(64))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_load_pd(x: c_ptrConst(real(64))): vecType;
  //     return _mm_load_pd(x);
  //   }
  //   inline proc type storea(x: c_ptr(real(64)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm_store_pd(x: c_ptr(real(64)), y: vecType): void;
  //     _mm_store_pd(x, y);
  //   }
  //   inline proc type loadu(x: c_ptrConst(real(64))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_loadu_pd(x: c_ptrConst(real(64))): vecType;
  //     return _mm_loadu_pd(x);
  //   }
  //   inline proc type storeu(x: c_ptr(real(64)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm_storeu_pd(x: c_ptr(real(64)), y: vecType): void;
  //     _mm_storeu_pd(x, y);
  //   }

  //   inline proc type swapPairs(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapPairs64x2r(x: vecType): vecType;
  //     return swapPairs64x2r(x);
  //   }
  //   inline proc type swapLowHigh(x: vecType): vecType do return this.swapPairs(x);
  //   inline proc type reverse(x: vecType): vecType do return this.swapPairs(x);
  //   inline proc type rotateLeft(x: vecType): vecType do return this.swapPairs(x);
  //   inline proc type rotateRight(x: vecType): vecType do return this.swapPairs(x);
  //   inline proc type interleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_unpacklo_pd(x: vecType, y: vecType): vecType;
  //     return _mm_unpacklo_pd(x, y);
  //   }
  //   inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_unpackhi_pd(x: vecType, y: vecType): vecType;
  //     return _mm_unpackhi_pd(x, y);
  //   }
  //   inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_unpacklo_pd(x: vecType, y: vecType): vecType;
  //     return _mm_unpacklo_pd(x, y);
  //   }
  //   inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_unpackhi_pd(x: vecType, y: vecType): vecType;
  //     return _mm_unpackhi_pd(x, y);
  //   }
  //   inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc blendLowHigh64x2r(x: vecType, y: vecType): vecType;
  //     return blendLowHigh64x2r(x, y);
  //   }

  //   inline proc type add(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_add_pd(x: vecType, y: vecType): vecType;
  //     return _mm_add_pd(x, y);
  //   }
  //   inline proc type sub(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_sub_pd(x: vecType, y: vecType): vecType;
  //     return _mm_sub_pd(x, y);
  //   }
  //   inline proc type mul(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_mul_pd(x: vecType, y: vecType): vecType;
  //     return _mm_mul_pd(x, y);
  //   }
  //   inline proc type div(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_div_pd(x: vecType, y: vecType): vecType;
  //     return _mm_div_pd(x, y);
  //   }
  //   inline proc type hadd(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_hadd_pd(x: vecType, y: vecType): vecType;
  //     return _mm_hadd_pd(x, y);
  //   }

  //   inline proc type sqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_sqrt_pd(x: vecType): vecType;
  //     return _mm_sqrt_pd(x);
  //   }
  //   inline proc type rsqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_cvtpd_ps(x: vecType): x8664_32x4r.vecType;
  //     pragma "fn synchronization free"
  //     extern proc _mm_cvtps_pd(x: x8664_32x4r.vecType): vecType;

  //     var three = this.splat(3.0);
  //     var half = this.splat(0.5);

  //     var x_ps = _mm_cvtpd_ps(x);
  //     // do rsqrt at 32-bit precision
  //     var res = _mm_cvtps_pd(x8664_32x4r.rsqrt(x_ps));

  //     // TODO: would an FMA version be faster?
  //     // Newton-Raphson iteration
  //     // q = 0.5 * x * (3 - x * res * res)
  //     var muls = this.mul(this.mul(x, res), res);
  //     res = this.mul(this.mul(half, res), this.sub(three, muls));

  //     return res;
  //   }
  //   inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_fmadd_pd(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm_fmadd_pd(x, y, z);
  //   }
  //   inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm_fmsub_pd(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm_fmsub_pd(x, y, z);
  //   }
  // }

}
