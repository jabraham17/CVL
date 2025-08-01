@chplcheck.ignore("PascalCaseModules")
module IntrinX86_128 {
  use CTypes only c_ptr, c_ptrConst, c_int;
  use Reflection only canResolveTypeMethod, getRoutineName;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "IntrinX86_128/wrapper-x86-128.h";
    require "IntrinX86_128/wrapper-x86-gathers.h";
    require "IntrinX86_128/wrapper-x86-fp-compare.h";
  }

  extern "__m128"  type vec32x4r;
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
  proc type vec32x4r.numBits param : int do return 128;
  proc type vec64x2r.numBits param : int do return 128;
  proc type vec8x16i.numBits param : int do return 128;
  proc type vec16x8i.numBits param : int do return 128;
  proc type vec32x4i.numBits param : int do return 128;
  proc type vec64x2i.numBits param : int do return 128;
  proc type vec8x16u.numBits param : int do return 128;
  proc type vec16x8u.numBits param : int do return 128;
  proc type vec32x4u.numBits param : int do return 128;
  proc type vec64x2u.numBits param : int do return 128;

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
    else compilerError("Unknown type: " + t:string);
  }
  proc type vec32x4r.typeSuffix param : string do return typeToSuffix(this);
  proc type vec64x2r.typeSuffix param : string do return typeToSuffix(this);
  proc type vec8x16i.typeSuffix param : string do return typeToSuffix(this);
  proc type vec16x8i.typeSuffix param : string do return typeToSuffix(this);
  proc type vec32x4i.typeSuffix param : string do return typeToSuffix(this);
  proc type vec64x2i.typeSuffix param : string do return typeToSuffix(this);
  proc type vec8x16u.typeSuffix param : string do return typeToSuffix(this);
  proc type vec16x8u.typeSuffix param : string do return typeToSuffix(this);
  proc type vec32x4u.typeSuffix param : string do return typeToSuffix(this);
  proc type vec64x2u.typeSuffix param : string do return typeToSuffix(this);
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
    else compilerError("Unknown type: " + t:string);
  }
  proc type vec32x4r.typeStr param : string do return vecTypeStr(this);
  proc type vec64x2r.typeStr param : string do return vecTypeStr(this);
  proc type vec8x16i.typeStr param : string do return vecTypeStr(this);
  proc type vec16x8i.typeStr param : string do return vecTypeStr(this);
  proc type vec32x4i.typeStr param : string do return vecTypeStr(this);
  proc type vec64x2i.typeStr param : string do return vecTypeStr(this);
  proc type vec8x16u.typeStr param : string do return vecTypeStr(this);
  proc type vec16x8u.typeStr param : string do return vecTypeStr(this);
  proc type vec32x4u.typeStr param : string do return vecTypeStr(this);
  proc type vec64x2u.typeStr param : string do return vecTypeStr(this);

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
  inline proc doSimpleOp(param op: string, x: ?t, y: ?, z: ?, w: ?): t do
    return doSimpleOp(op, t, x, y, z, w);
  inline proc doSimpleOp(param op: string, xs): xs(0).type where isTuple(xs) do
    return doSimpleOp(op, xs(0).type, xs);
  /*
    Call a simple op on a vector type
    returnType specifies the return type
  */
  inline proc doSimpleOp(param op: string, type returnType, x: ?t): returnType {
    param externName = op + returnType.typeSuffix;

    pragma "fn synchronization free"
    extern externName proc func(externX: t): returnType;

    return func(x);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2): returnType {
    param externName = op + returnType.typeSuffix;

    pragma "fn synchronization free"
    extern externName proc func(externX: t1, externY: t2): returnType;

    return func(x, y);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2, z: ?t3): returnType {
    param externName = op + returnType.typeSuffix;

    pragma "fn synchronization free"
    extern externName
    proc func(externX: t1, externY: t2, externZ: t3): returnType;

    return func(x, y, z);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType,
                         x: ?t1, y: ?t2, z: ?t3, w: ?t4): returnType {
    param externName = op + returnType.typeSuffix;

    pragma "fn synchronization free"
    extern externName
    proc func(externX: t1, externY: t2, externZ: t3, externW: t4): returnType;

    return func(x, y, z, w);
  }
  inline proc doSimpleOp(param op: string,
                         type returnType, xs): returnType where isTuple(xs) {
    param externName = op + returnType.typeSuffix;

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
      return vecType.numBits / numBits(laneType);
    proc type mmPrefix param : string {
      if canResolveTypeMethod(extensionType, "mmPrefix") then
        return extensionType.mmPrefix;
      else
        return "_mm";
    }

    inline proc type extract(x: vecType, param idx: int): laneType {
      // TODO: only check if we can resolve a type method with no args,
      // canResolveTypeMethod does not preserve the paramness of the args, so
      // `idx` is non-param,
      // and `canResolveTypeMethod(extensionType, "extract", x, idx)`
      // doesn't work
      if canResolveTypeMethod(extensionType, "extract") then
        return extensionType.extract(x, idx);
      else {
        if idx < 0 || idx >= numLanes then compilerError("invalid index");
        param externName = "get_lane_" + vecType.typeStr + idx:string;

        pragma "fn synchronization free"
        extern externName proc getLane(x: vecType): laneType;
        return getLane(x);
      }
    }
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
      // TODO: same problem as extract
      if canResolveTypeMethod(extensionType, "insert") then
        return extensionType.insert(x, y, idx);
      else {
        if idx < 0 || idx >= numLanes then compilerError("invalid index");
        param externName = "set_lane_" + vecType.typeStr + idx:string;

        pragma "fn synchronization free"
        extern externName proc setLane(x: vecType, y: laneType): vecType;
        return setLane(x, y);
      }
    }
    inline proc type splat(x: laneType): vecType {
      if canResolveTypeMethod(extensionType, "splat", x) then
        return extensionType.splat(x);
      else {
        return doSimpleOp(mmPrefix+"_set1_", vecType, x);
      }
    }
    inline proc type set(xs...): vecType {
      if canResolveTypeMethod(extensionType, "set", (...xs)) then
        return extensionType.set((...xs));
      else {
        return doSimpleOp(mmPrefix+"_setr_", vecType, xs);
      }
    }

    inline proc type loada(x: c_ptrConst(laneType)): vecType do
      return doSimpleOp(mmPrefix+"_load_", vecType, x);
    inline proc type loadu(x: c_ptrConst(laneType)): vecType do
      return doSimpleOp(mmPrefix+"_loadu_", vecType, x);
    inline proc type storea(x: c_ptr(laneType), y: vecType): void {
      param externName = mmPrefix+"_store_" + vecType.typeSuffix;
      pragma "fn synchronization free"
      extern externName proc store(x: c_ptr(laneType), y: vecType): void;
      store(x, y);
    }
    inline proc type storeu(x: c_ptr(laneType), y: vecType): void {
      param externName = mmPrefix+"_storeu_" + vecType.typeSuffix;
      pragma "fn synchronization free"
      extern externName proc store(x: c_ptr(laneType), y: vecType): void;
      store(x, y);
    }

    @chplcheck.ignore("UnusedFormal")
    inline proc type loadMasked(x: c_ptrConst(laneType), mask: ?): vecType {
      if canResolveTypeMethod(extensionType, "loadMasked", x, mask) then
        return extensionType.loadMasked(x, mask);
      else {
        if laneType == int(8) || laneType == int(16) {
          compilerError(getRoutineName() +
                        " is not supported with " +
                        laneType:string +
                        " on this platform");
        } else {
          return doSimpleOp(mmPrefix+"_maskload_", vecType, x, mask);
        }
      }
    }

    @chplcheck.ignore("UnusedFormal")
    inline proc type gather(
      x: c_ptrConst(laneType),
      type indexType,
      indices: ?,
      param scale: int
    ): vecType {
      // TODO: canResolveTypeMethod can't mix param, type, and value
      if canResolveTypeMethod(extensionType, "gather") then
        return extensionType.gather(x, indexType, indices, scale);
      else {
        if laneType == int(8) || laneType == int(16) {
          compilerError(getRoutineName() +
                        " is not supported with " +
                        laneType:string +
                        " on this platform");
        } else if indexType != int(32) {
          compilerError(getRoutineName() + " only supports int(32) indices");
        } else if !(scale == 0 || scale == 1 ||
                    scale == 2 || scale == 4 || scale == 8) {
          compilerError(getRoutineName() +
                        " only supports a scale of 0, 1, 2, 4, or 8");
        } else {
          // if scale is 0, compute the proper scale based on the laneType
          param computedScale = if scale == 0
                                  then numBits(laneType)/8
                                  else scale;
          return doSimpleOp(mmPrefix+"_i32gather_" + computedScale:string + "_",
                            vecType, x, indices);
        }
      }
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
      // TODO: canResolveTypeMethod can't mix param, type, and value
      if canResolveTypeMethod(extensionType, "gatherMasked") then
        return extensionType.gatherMasked(x, indexType, indices, scale, mask);
      else {
        if laneType == int(8) || laneType == int(16) {
          compilerError(getRoutineName() +
                        " is not supported with " +
                        laneType:string +
                        " on this platform");
        } else if indexType != int(32) {
          compilerError(getRoutineName() + " only supports int(32) indices");
        } else if !(scale == 0 || scale == 1 ||
                    scale == 2 || scale == 4 || scale == 8) {
          compilerError(getRoutineName() +
                        " only supports a scale of 0, 1, 2, 4, or 8");
        } else {
          // if scale is 0, compute the proper scale based on the laneType
          param computedScale = if scale == 0
                                  then numBits(laneType)/8
                                  else scale;
          return doSimpleOp(mmPrefix+"_mask_i32gather_" +
                            computedScale:string + "_",
                            vecType, src, x, indices, mask);
        }
      }
    }

    // bit cast int to float or float to int
    // TODO im not happy with this api
    // inline proc type bitcast(x: vecType, type otherVecType): otherVecType

    inline proc type swapPairs(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "swapPairs", x) then
        return extensionType.swapPairs(x);
      else {
        if vecType.numBits == 128 {
          return doSimpleOp("swapPairs_", x);
        } else {
          return doSimpleOp("swapPairs_" + vecType.numBits:string, x);
        }
      }
    }
    inline proc type swapLowHigh(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "swapLowHigh", x) then
        return extensionType.swapLowHigh(x);
      else {
        if vecType.numBits == 128 {
          return doSimpleOp("swapLowHigh_", x);
        } else {
          return doSimpleOp("swapLowHigh_" + vecType.numBits:string, x);
        }
      }
    }
    inline proc type reverse(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "reverse", x) then
        return extensionType.reverse(x);
      else {
        if vecType.numBits == 128 {
          return doSimpleOp("reverse_", x);
        } else {
          return doSimpleOp("reverse_" + vecType.numBits:string, x);
        }
      }
    }
    inline proc type rotateLeft(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rotateLeft", x) then
        return extensionType.rotateLeft(x);
      else {
        if vecType.numBits == 128 {
          return doSimpleOp("rotateLeft_", x);
        } else {
          return doSimpleOp("rotateLeft_" + vecType.numBits:string, x);
        }
      }
    }
    inline proc type rotateRight(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rotateRight", x) then
        return extensionType.rotateRight(x);
      else {
        if vecType.numBits == 128 {
          return doSimpleOp("rotateRight_", x);
        } else {
          return doSimpleOp("rotateRight_" + vecType.numBits:string, x);
        }
      }
    }
    inline proc type interleaveLower(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "interleaveLower", x, y) then
        return extensionType.interleaveLower(x, y);
      else
        return doSimpleOp(mmPrefix+"_unpacklo_", x, y);
    }
    inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "interleaveUpper", x, y) then
        return extensionType.interleaveUpper(x, y);
      else
        return doSimpleOp(mmPrefix+"_unpackhi_", x, y);
    }

    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "deinterleaveLower", x, y) then
        return extensionType.deinterleaveLower(x, y);
      else
        return this.interleaveLower(
          this.interleaveLower(x, y),
          this.interleaveUpper(x, y));
    }

    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "deinterleaveUpper", x, y) then
        return extensionType.deinterleaveUpper(x, y);
      else
        return this.interleaveUpper(
          this.interleaveLower(x, y),
          this.interleaveUpper(x, y));
    }

    inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "blendLowHigh", x, y) then
        return extensionType.blendLowHigh(x, y);
      else {
        if vecType.numBits == 128 {
          return doSimpleOp("blendLowHigh_", x, y);
        } else {
          return doSimpleOp("blendLowHigh_" + vecType.numBits:string, x, y);
        }
      }
    }

    inline proc type add(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "add", x, y) then
        return extensionType.add(x, y);
      else
        return doSimpleOp(mmPrefix+"_add_", x, y);
    }
    inline proc type sub(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "sub", x, y) then
        return extensionType.sub(x, y);
      else
        return doSimpleOp(mmPrefix+"_sub_", x, y);
    }
    inline proc type mul(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "mul", x, y) then
        return extensionType.mul(x, y);
      else
        return doSimpleOp(mmPrefix+"_mul_", x, y);
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "div", x, y) then
        return extensionType.div(x, y);
      else
        return doSimpleOp(mmPrefix+"_div_", x, y);
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
        // TODO: use proper xor for ps, pd, and si128, and si256
        pragma "fn synchronization free"
        extern proc _mm_and_si128(x: vecType, y: vecType): vecType;
        return _mm_and_si128(x, y);
      }
    }
    inline proc type or(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "or", x, y) then
        return extensionType.or(x, y);
      else {
        // // TODO: use proper xor for ps, pd, and si128, and si256
        pragma "fn synchronization free"
        extern proc _mm_or_si128(x: vecType, y: vecType): vecType;
        return _mm_or_si128(x, y);
      }
    }
    inline proc type xor(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "xor", x, y) then
        return extensionType.xor(x, y);
      else {
        if isIntegralType(laneType) {
          param name = mmPrefix + "_xor_si" + vecType.numBits:string;
          pragma "fn synchronization free"
          extern name proc mmXor(x: vecType, y: vecType): vecType;
          return mmXor(x, y);
        } else {
          return doSimpleOp(mmPrefix+"_xor_", x, y);
        }
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
        if vecType.numBits == 128 {
          pragma "fn synchronization free"
          extern proc _mm_andnot_si128(x: vecType, y: vecType): vecType;
          return _mm_andnot_si128(x, y);
        } else if vecType.numBits == 256 {
          pragma "fn synchronization free"
          extern proc _mm256_andnot_si256(x: vecType, y: vecType): vecType;
          return _mm256_andnot_si256(x, y);
        } else {
          compilerError("unsupported vector size");
        }
      }
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

    /*
      For floating point types, the comparison is ordered and non-signaling.
    */
    inline proc type cmpEq(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpEq", x, y) then
        return extensionType.cmpEq(x, y);
      else if isRealType(laneType) then
        return doSimpleOp("cmpEq"+vecType.numBits:string, x, y);
      else
        return doSimpleOp(mmPrefix+"_cmpeq_", x, y);
    }
    inline proc type cmpNe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpNe", x, y) then
        return extensionType.cmpNe(x, y);
      else if isRealType(laneType) then
        return doSimpleOp("cmpNe"+vecType.numBits:string, x, y);
      else
        return doSimpleOp(mmPrefix+"_cmpne_", x, y);
    }
    inline proc type cmpLt(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpLt", x, y) then
        return extensionType.cmpLt(x, y);
      else if isRealType(laneType) then
        return doSimpleOp("cmpLt"+vecType.numBits:string, x, y);
      else
        return doSimpleOp(mmPrefix+"_cmplt_", x, y);
    }
    inline proc type cmpLe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpLe", x, y) then
        return extensionType.cmpLe(x, y);
      else if isRealType(laneType) then
        return doSimpleOp("cmpLe"+vecType.numBits:string, x, y);
      else
        return doSimpleOp(mmPrefix+"_cmple_", x, y);
    }
    inline proc type cmpGt(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpGt", x, y) then
        return extensionType.cmpGt(x, y);
      else if isRealType(laneType) then
        return doSimpleOp("cmpGt"+vecType.numBits:string, x, y);
      else
        return doSimpleOp(mmPrefix+"_cmpgt_", x, y);
    }
    inline proc type cmpGe(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "cmpGe", x, y) then
        return extensionType.cmpGe(x, y);
      else if isRealType(laneType) then
        return doSimpleOp("cmpGe"+vecType.numBits:string, x, y);
      else
        return doSimpleOp(mmPrefix+"_cmpge_", x, y);
    }
    inline proc type bitSelect(mask: ?, x: vecType, y: vecType): vecType
      where numBits(mask.type) == numBits(vecType) {
      if canResolveTypeMethod(extensionType, "bitSelect", mask, x, y) then
        return extensionType.bitSelect(mask, x, y);
      else {
        import CVL;
        if CVL.implementationWarnings then
          compilerWarning("bitSelect is unimplemented");
        // _mm_or_si128(_mm_and_si128(mask, a), _mm_andnot_si128(mask, b));
        return x; // TODO
      }
    }

    inline proc type isAllZeros(x: vecType): bool {
      if canResolveTypeMethod(extensionType, "isAllZeros", x) then
        return extensionType.isAllZeros(x);
      else {
        import CVL;
        if CVL.implementationWarnings then
          compilerWarning("isAllZeros is unimplemented");
        return false;
      }
    }
    inline proc type allOnes(): vecType {
      if canResolveTypeMethod(extensionType, "allOnes") then
        return extensionType.allOnes();
      else {
        const zero = this.allZeros();
        return this.andNot(zero, zero);
      }
    }
    inline proc type allZeros(): vecType {
      if canResolveTypeMethod(extensionType, "allZeros") then
        return extensionType.allZeros();
      else {
        if isIntegralType(laneType) {
          param name = mmPrefix + "_setzero_si" + vecType.numBits:string;
          pragma "fn synchronization free"
          extern name proc setZero(): vecType;
          return setZero();
        } else {
          return doSimpleOp(mmPrefix+"_setzero_", vecType);
        }
      }
    }

    // TODO: moveMask?
    inline proc type moveMask(x: vecType): c_int {
      x;
      return 0;
    }

    inline proc type min(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "min", x, y) then
        return extensionType.min(x, y);
      else
        return doSimpleOp(mmPrefix+"_min_", x, y);
    }
    inline proc type max(x: vecType, y: vecType): vecType {
      if canResolveTypeMethod(extensionType, "max", x, y) then
        return extensionType.max(x, y);
      else
        return doSimpleOp(mmPrefix+"_max_", x, y);
    }
    inline proc type abs(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "abs", x) then
        return extensionType.abs(x);
      else
        return doSimpleOp(mmPrefix+"_abs_", x);
    }
    inline proc type hadd(x: vecType, y: vecType): vecType do
      if canResolveTypeMethod(extensionType, "hadd", x, y) then
        return extensionType.hadd(x, y);
      else
        return doSimpleOp(mmPrefix+"_hadd_", x, y);

    inline proc type sqrt(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "sqrt", x) then
        return extensionType.sqrt(x);
      else
        return doSimpleOp(mmPrefix+"_sqrt_", x);
    }
    inline proc type rsqrt(x: vecType): vecType {
      if canResolveTypeMethod(extensionType, "rsqrt", x) then
        return extensionType.rsqrt(x);
      else
        return doSimpleOp(mmPrefix+"_rsqrt_", x);
    }

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
      if canResolveTypeMethod(extensionType, "fmadd", x, y, z) then
        return extensionType.fmadd(x, y, z);
      else
        return doSimpleOp(mmPrefix+"_fmadd_", x, y, z);
    }
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
      if canResolveTypeMethod(extensionType, "fmsub", x, y, z) then
        return extensionType.fmsub(x, y, z);
      else
        return doSimpleOp(mmPrefix+"_fmsub_", x, y, z);
    }

    inline proc type reinterpretCast(type toVecType, x: vecType): toVecType {
      // TODO
      // _mm256_castps_si256
      // return x;
      import CVL;
      if CVL.implementationWarnings then
        compilerWarning("reinterpretCast is unimplemented");
      x;
      var y: toVecType;
      return y;
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
      return doSimpleOp("hadd_", x, y);

    inline proc type abs(x: vecType): vecType {
      var mask = base.splat(-0.0:laneType);
      var cast = doSimpleOp(base.mmPrefix+"_castsi128_", vecType, mask);
      return base.andNot(cast, x);
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

    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return base.interleaveLower(x, y);
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return base.interleaveUpper(x, y);

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
      var mask = base.splat(-0.0:laneType);
      var cast = doSimpleOp(base.mmPrefix+"_castsi128_", vecType, mask);
      return base.andNot(cast, x);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_8x16i_extension {
    type base;
    proc type vecType type do return vec8x16i;
    proc type laneType type do return int(8);

    inline proc type mul(x: vecType, y: vecType): vecType {
      import CVL;
      if CVL.implementationWarnings then
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
      import CVL;
      if CVL.implementationWarnings then
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
      import CVL;
      if CVL.implementationWarnings then
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
      import CVL;
      if CVL.implementationWarnings then
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
      import CVL;
      if CVL.implementationWarnings then
        compilerWarning("'div' on int(16) is implemented as scalar operations");
      // TODO: theres no div_epi16 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }

    inline proc type hadd(x: vecType, y: vecType): vecType do
      return doSimpleOp("hadd_", x, y);

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
      import CVL;
      if CVL.implementationWarnings then
        compilerWarning("'div' on int(32) is implemented as scalar operations");
      // TODO: theres no div_epi32 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }

    inline proc type mul(x: vecType, y: vecType): vecType {
      import CVL;
      if CVL.implementationWarnings then
        compilerWarning("'mul' on int(32) is implemented as scalar operations");
      // TODO: we could do somthing with mul_epi32 and mulhi_epi32
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) * base.extract(y, i), i);
      }
      return res;
    }

    inline proc type hadd(x: vecType, y: vecType): vecType do
      return doSimpleOp("hadd_", x, y);

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

    inline proc type set(xs...): vecType {
      pragma "fn synchronization free"
      extern proc _mm_set_epi64x(x: int(64), y: int(64)): vec64x2i;
      return _mm_set_epi64x(xs(1), xs(0));
    }

    inline proc type swapLowHigh(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type reverse(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateLeft(x: vecType): vecType do
      return base.swapPairs(x);
    inline proc type rotateRight(x: vecType): vecType do
      return base.swapPairs(x);

    inline proc type deinterleaveLower(x: vecType, y: vecType): vecType do
      return base.interleaveLower(x, y);
    inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType do
      return base.interleaveUpper(x, y);

    inline proc type div(x: vecType, y: vecType): vecType {
      import CVL;
      if CVL.implementationWarnings then
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
      import CVL;
      if CVL.implementationWarnings then
        compilerWarning("'hadd' on int(64) is " +
                        "implemented as scalar operations");
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
}
