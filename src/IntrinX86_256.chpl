@chplcheck.ignore("PascalCaseModules")
module IntrinX86_256 {
  use IntrinX86_128 only doSimpleOp, numBits, x8664_NxM,
                         vec32x4r, vec64x2r,
                         vec8x16i, vec16x8i, vec32x4i, vec64x2i,
                         vec8x16u, vec16x8u, vec32x4u, vec64x2u,
                         x8664_32x4r, x8664_64x2r,
                         x8664_8x16i, x8664_16x8i, x8664_32x4i, x8664_64x2i;


  use CTypes only c_ptr, c_ptrConst;
  use Reflection only canResolveTypeMethod;
  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    require "x86intrin.h";
    require "wrapper-x86-256.h";
  }

  extern "__m256"  type vec32x8r;
  extern "__m256d" type vec64x4r;
  extern "__m256i" type vec8x32i;
  extern "__m256i" type vec16x16i;
  extern "__m256i" type vec32x8i;
  extern "__m256i" type vec64x4i;
  extern "__m256i" type vec8x32u;
  extern "__m256i" type vec16x16u;
  extern "__m256i" type vec32x8u;
  extern "__m256i" type vec64x4u;

  proc numBits(type t) param: int
    where t == vec32x8r || t == vec64x4r ||
          t == vec8x32i || t == vec16x16i || t == vec32x8i || t == vec64x4i ||
          t == vec8x32u || t == vec16x16u || t == vec32x8u || t == vec64x4u
    do return 256;

  proc type vec32x8r.numBits  param: int do return 256;
  proc type vec64x4r.numBits  param: int do return 256;
  proc type vec8x32i.numBits  param: int do return 256;
  proc type vec16x16i.numBits param: int do return 256;
  proc type vec32x8i.numBits  param: int do return 256;
  proc type vec64x4i.numBits  param: int do return 256;
  proc type vec8x32u.numBits  param: int do return 256;
  proc type vec16x16u.numBits param: int do return 256;
  proc type vec32x8u.numBits  param: int do return 256;
  proc type vec64x4u.numBits  param: int do return 256;

  proc typeToSuffix(type t) param : string {
         if t == real(32) || t == vec32x8r  then return "ps";
    else if t == real(64) || t == vec64x4r  then return "pd";
    else if t == int(8)   || t == vec8x32i  then return "epi8";
    else if t == int(16)  || t == vec16x16i then return "epi16";
    else if t == int(32)  || t == vec32x8i  then return "epi32";
    else if t == int(64)  || t == vec64x4i  then return "epi64";
    else if t == uint(8)  || t == vec8x32u  then return "epu8";
    else if t == uint(16) || t == vec16x16u then return "epu16";
    else if t == uint(32) || t == vec32x8u  then return "epu32";
    else if t == uint(64) || t == vec64x4u  then return "epu64";
    else compilerError("Unknown type: " + t:string);
  }
  proc type vec32x8r.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec64x4r.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec8x32i.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec16x16i.typeSuffix param : string do return typeToSuffix(this);
  proc type vec32x8i.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec64x4i.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec8x32u.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec16x16u.typeSuffix param : string do return typeToSuffix(this);
  proc type vec32x8u.typeSuffix  param : string do return typeToSuffix(this);
  proc type vec64x4u.typeSuffix  param : string do return typeToSuffix(this);
  proc vecTypeStr(type t) param : string {
         if t == vec32x8r  then return "32x8r";
    else if t == vec64x4r  then return "64x4r";
    else if t == vec8x32i  then return "8x32i";
    else if t == vec16x16i then return "v6x16i";
    else if t == vec32x8i  then return "32x8i";
    else if t == vec64x4i  then return "64x4i";
    else if t == vec8x32u  then return "8x32u";
    else if t == vec16x16u then return "v6x16u";
    else if t == vec32x8u  then return "32x8u";
    else if t == vec64x4u  then return "64x4u";
    else compilerError("Unknown type: " + t:string);
  }
  proc type vec32x8r.typeStr  param : string do return vecTypeStr(this);
  proc type vec64x4r.typeStr  param : string do return vecTypeStr(this);
  proc type vec8x32i.typeStr  param : string do return vecTypeStr(this);
  proc type vec16x16i.typeStr param : string do return vecTypeStr(this);
  proc type vec32x8i.typeStr  param : string do return vecTypeStr(this);
  proc type vec64x4i.typeStr  param : string do return vecTypeStr(this);
  proc type vec8x32u.typeStr  param : string do return vecTypeStr(this);
  proc type vec16x16u.typeStr param : string do return vecTypeStr(this);
  proc type vec32x8u.typeStr  param : string do return vecTypeStr(this);
  proc type vec64x4u.typeStr  param : string do return vecTypeStr(this);

  proc halfVectorHW(type t) type {
         if t == vec32x8r  then return vec32x4r;
    else if t == vec64x4r  then return vec64x2r;
    else if t == vec8x32i  then return vec8x16i;
    else if t == vec16x16i then return vec16x8i;
    else if t == vec32x8i  then return vec32x4i;
    else if t == vec64x4i  then return vec64x2i;
    else if t == vec8x32u  then return vec8x16u;
    else if t == vec16x16u then return vec16x8u;
    else if t == vec32x8u  then return vec32x4u;
    else if t == vec64x4u  then return vec64x2u;
    else compilerError("Unknown type: " + t:string);
  }
  proc offset(type vecType, type laneType) param: int do
    return numBits(vecType) / numBits(laneType);

  proc numLanes(type vecType, type laneType) param: int do
    return vecType.numBits / numBits(laneType);

  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_32x8r type do return x8664_NxM(x8664_32x8r_extension(
                                  x8664_NxM(x8664_32x8r_extension(nothing))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_64x4r type do return x8664_NxM(x8664_64x4r_extension(
                                  x8664_NxM(x8664_64x4r_extension(nothing))));
  // note: the int cases need extra recursion to work properly
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_8x32i type do return x8664_NxM(x8664_8x32i_extension(
                                  x8664_NxM(x8664_8x32i_extension(
                                  x8664_NxM(x8664_8x32i_extension(nothing))))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_16x16i type do
    return x8664_NxM(x8664_16x16i_extension(
           x8664_NxM(x8664_16x16i_extension(
           x8664_NxM(x8664_16x16i_extension(nothing))))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_32x8i type do return x8664_NxM(x8664_32x8i_extension(
                                  x8664_NxM(x8664_32x8i_extension(
                                  x8664_NxM(x8664_32x8i_extension(nothing))))));
  @chplcheck.ignore("CamelCaseFunctions")
  proc x8664_64x4i type do return x8664_NxM(x8664_64x4i_extension(
                                  x8664_NxM(x8664_64x4i_extension(
                                  x8664_NxM(x8664_64x4i_extension(nothing))))));


  proc getGenericInsertExtractName(param base: string,
                                   type laneType,
                                   param i: int) param : string {
    if laneType == real(32) then return base + "128x2f" + i:string;
    else if laneType == real(64) then return base + "128x2d" + i:string;
    else return base + "128x2i" + i:string;
  }

  inline proc generic256Extract(type laneType,
                                x: ?vecType,
                                param idx: int,
                                type halfVectorTy): laneType {
    if idx < 0 || idx >= numLanes(vecType, laneType) then
      compilerError("invalid index");
    type HV = halfVectorHW(vecType);

    pragma "fn synchronization free"
    extern getGenericInsertExtractName("extract", laneType, 0)
    proc extract0(x: vecType): HV;
    pragma "fn synchronization free"
    extern getGenericInsertExtractName("extract", laneType, 1)
    proc extract1(x: vecType): HV;

    param off = offset(HV, laneType);
    if idx < off then
      return halfVectorTy.extract(extract0(x), idx);
    else
      return halfVectorTy.extract(extract1(x), idx - off);
  }
  inline proc generic256Insert(x: ?vecType,
                               y: ?laneType,
                               param idx: int,
                               type halfVectorTy): vecType {
    if idx < 0 || idx >= numLanes(vecType, laneType) then
      compilerError("invalid index");
    type HV = halfVectorHW(vecType);
    
    pragma "fn synchronization free"
    extern getGenericInsertExtractName("insert", laneType, 0)
    proc insert0(x: vecType, y: HV): vecType;
    pragma "fn synchronization free"
    extern getGenericInsertExtractName("insert", laneType, 1)
    proc insert1(x: vecType, y: HV): vecType;

    pragma "fn synchronization free"
    extern getGenericInsertExtractName("extract", laneType, 0)
    proc extract0(x: vecType): HV;
    pragma "fn synchronization free"
    extern getGenericInsertExtractName("extract", laneType, 1)
    proc extract1(x: vecType): HV;

    param off = offset(HV, laneType);
    if idx < off {
      const temp = halfVectorTy.insert(extract0(x), y, idx);
      return insert0(x, temp);
    } else {
      const temp = halfVectorTy.insert(extract1(x), y, idx - off);
      return insert1(x, temp);
    }
  }


  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_32x8r_extension {
    type base;
    proc type vecType type do return vec32x8r;
    proc type laneType type do return real(32);
    proc type mmPrefix param : string do return "_mm256";

    inline proc type extract() {} // dummy for canResolve
    inline proc type extract(x: vecType, param idx: int): laneType do
      return generic256Extract(laneType, x, idx, x8664_32x4r);
    inline proc type insert() {} // dummy for canResolve
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType do
      return generic256Insert(x, y, idx, x8664_32x4r);

    inline proc type hadd(x: vecType, y: vecType): vecType do
      return doSimpleOp("hadd_256", x, y);

    inline proc type abs(x: vecType): vecType {
      var mask = base.splat(-0.0:laneType);
      var cast = doSimpleOp(base.mmPrefix+"_castsi256_", vecType, mask);
      return base.andNot(cast, x);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_64x4r_extension {
    type base;
    proc type vecType type do return vec64x4r;
    proc type laneType type do return real(64);
    proc type mmPrefix param : string do return "_mm256";

    inline proc type extract() {} // dummy for canResolve
    inline proc type extract(x: vecType, param idx: int): laneType do
      return generic256Extract(laneType, x, idx, x8664_64x2r);
    inline proc type insert() {} // dummy for canResolve
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType do
      return generic256Insert(x, y, idx, x8664_64x2r);

    inline proc type rsqrt(x: vecType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_cvtpd_ps(x: vecType): x8664_32x4r.vecType;
      pragma "fn synchronization free"
      extern proc _mm256_cvtps_pd(x: x8664_32x4r.vecType): vecType;

      var three = base.splat(3.0);
      var half = base.splat(0.5);

      var x_ps = _mm256_cvtpd_ps(x);
      // do rsqrt at 32-bit precision
      var res = _mm256_cvtps_pd(x8664_32x4r.rsqrt(x_ps));

      // TODO: would an FMA version be faster?
      // Newton-Raphson iteration
      // q = 0.5 * x * (3 - x * res * res)
      var muls = base.mul(base.mul(x, res), res);
      res = base.mul(base.mul(half, res), base.sub(three, muls));

      return res;
    }

    inline proc type abs(x: vecType): vecType {
      var mask = base.splat(-0.0:laneType);
      var cast = doSimpleOp(base.mmPrefix+"_castsi256_", vecType, mask);
      return base.andNot(cast, x);
    }
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_8x32i_extension {
    type base;
    proc type vecType type do return vec8x32i;
    proc type laneType type do return int(8);
    proc type mmPrefix param : string do return "_mm256";

    inline proc type extract() {} // dummy for canResolve
    inline proc type extract(x: vecType, param idx: int): laneType do
      return generic256Extract(laneType, x, idx, x8664_8x16i);
    inline proc type insert() {} // dummy for canResolve
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType do
      return generic256Insert(x, y, idx, x8664_8x16i);

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
  record x8664_16x16i_extension {
    type base;
    proc type vecType type do return vec16x16i;
    proc type laneType type do return int(16);
    proc type mmPrefix param : string do return "_mm256";

    inline proc type extract() {} // dummy for canResolve
    inline proc type extract(x: vecType, param idx: int): laneType do
      return generic256Extract(laneType, x, idx, x8664_16x8i);
    inline proc type insert() {} // dummy for canResolve
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType do
      return generic256Insert(x, y, idx, x8664_16x8i);
  
    inline proc type mul(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'mul' on int(16) is implemented as scalar operations");
      // TODO: theres no mul_epi16 instruction, we can emulate with mullo_epi16
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

    inline proc type hadd(x: vecType, y: vecType): vecType do
      return doSimpleOp("hadd_256", x, y);
      
    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return base.add(base.mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return base.sub(base.mul(x, y), z);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_32x8i_extension {
    type base;
    proc type vecType type do return vec32x8i;
    proc type laneType type do return int(32);
    proc type mmPrefix param : string do return "_mm256";

    inline proc type extract() {} // dummy for canResolve
    inline proc type extract(x: vecType, param idx: int): laneType do
      return generic256Extract(laneType, x, idx, x8664_32x4i);
    inline proc type insert() {} // dummy for canResolve
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType do
      return generic256Insert(x, y, idx, x8664_32x4i);

    inline proc type mul(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'mul' on int(32) is implemented as scalar operations");
      // TODO: we could do somthing with mul_epi32 and mulhi_epi32
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) * base.extract(y, i), i);
      }
      return res;
    }
    inline proc type div(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'div' on int(32) is implemented as scalar operations");
      // TODO: theres no div_epi32 instruction,
      // but surely we can do better than this
      var res: vecType;
      for param i in 0..<base.numLanes {
        res = base.insert(res, base.extract(x, i) / base.extract(y, i), i);
      }
      return res;
    }

    inline proc type hadd(x: vecType, y: vecType): vecType do
      return doSimpleOp("hadd_256", x, y);

    inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType do
      return base.add(base.mul(x, y), z);
    inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType do
      return base.sub(base.mul(x, y), z);
  }

  @chplcheck.ignore("CamelCaseRecords")
  @lint.typeOnly
  record x8664_64x4i_extension {
    type base;
    proc type vecType type do return vec64x4i;
    proc type laneType type do return int(64);
    proc type mmPrefix param : string do return "_mm256";

    inline proc type extract() {} // dummy for canResolve
    inline proc type extract(x: vecType, param idx: int): laneType do
      return generic256Extract(laneType, x, idx, x8664_64x2i);
    inline proc type insert() {} // dummy for canResolve
    inline proc type insert(x: vecType, y: laneType, param idx: int): vecType do
      return generic256Insert(x, y, idx, x8664_64x2i);

    inline proc type splat(x: laneType): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_set1_epi64x(x: laneType): vecType;
      return _mm256_set1_epi64x(x);
    }
    inline proc type set(xs...): vecType {
      pragma "fn synchronization free"
      extern proc _mm256_setr_epi64x(args...): vecType;
      return _mm256_setr_epi64x((...xs));
    }

    inline proc type div(x: vecType, y: vecType): vecType {
      import CVI;
      if CVI.implementationWarnings then
        compilerWarning("'div' on int(64) is implemented as scalar operations");
      // TODO: theres no div_epi32 instruction,
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
