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
    // require "wrapper-x86-256.c";
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

  // @chplcheck.ignore("UnusedFormal")
  // inline operator:(x: vec256d, type t: vec256) {
  //   pragma "fn synchronization free"
  //   extern proc _mm256_castpd_ps(x: vec256d): vec256;
  //   return _mm256_castpd_ps(x);
  // }
  // @chplcheck.ignore("UnusedFormal")
  // inline operator:(x: vec256, type t: vec256d) {
  //   pragma "fn synchronization free"
  //   extern proc _mm256_castps_pd(x: vec256): vec256d;
  //   return _mm256_castps_pd(x);
  // }

  // @chplcheck.ignore("CamelCaseRecords")
  // @lint.typeOnly
  // record x8664_32x8r {
  //   proc type vecType type do return vec256;
  //   proc type laneType type do return real(32);

  //   inline proc type extract(x: vecType, param idx: int): laneType {
  //     pragma "fn synchronization free"
  //     extern proc extract128x2f0(x: vecType): vec128;
  //     pragma "fn synchronization free"
  //     extern proc extract128x2f1(x: vecType): vec128;

  //     if idx == 0      then return x8664_32x4r.extract(extract128x2f0(x), 0);
  //     else if idx == 1 then return x8664_32x4r.extract(extract128x2f0(x), 1);
  //     else if idx == 2 then return x8664_32x4r.extract(extract128x2f0(x), 2);
  //     else if idx == 3 then return x8664_32x4r.extract(extract128x2f0(x), 3);
  //     else if idx == 4 then return x8664_32x4r.extract(extract128x2f1(x), 0);
  //     else if idx == 5 then return x8664_32x4r.extract(extract128x2f1(x), 1);
  //     else if idx == 6 then return x8664_32x4r.extract(extract128x2f1(x), 2);
  //     else if idx == 7 then return x8664_32x4r.extract(extract128x2f1(x), 3);
  //     else compilerError("invalid index");
  //   }
  //   inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
  //     pragma "fn synchronization free"
  //     extern proc insert128x2f0(x: vecType, y: vec128): vecType;
  //     pragma "fn synchronization free"
  //     extern proc insert128x2f1(x: vecType, y: vec128): vecType;
  //     pragma "fn synchronization free"
  //     extern proc extract128x2f0(x: vecType): vec128;
  //     pragma "fn synchronization free"
  //     extern proc extract128x2f1(x: vecType): vec128;

  //     if idx == 0      then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 0));
  //     else if idx == 1 then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 1));
  //     else if idx == 2 then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 2));
  //     else if idx == 3 then return insert128x2f0(x, x8664_32x4r.insert(extract128x2f0(x), y, 3));
  //     else if idx == 4 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 0));
  //     else if idx == 5 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 1));
  //     else if idx == 6 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 2));
  //     else if idx == 7 then return insert128x2f1(x, x8664_32x4r.insert(extract128x2f1(x), y, 3));
  //     else compilerError("invalid index");
  //   }

  //   inline proc type splat(x: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_set1_ps(x: laneType): vecType;
  //     return _mm256_set1_ps(x);
  //   }
  //   inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_setr_ps(x: laneType, y: laneType, z: laneType, w: laneType, a: laneType, b: laneType, c: laneType, d: laneType): vecType;
  //     return _mm256_setr_ps(x, y, z, w, a, b, c, d);
  //   }
  //   inline proc type loada(x: c_ptrConst(real(32))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_load_ps(x: c_ptrConst(real(32))): vecType;
  //     return _mm256_load_ps(x);
  //   }
  //   inline proc type storea(x: c_ptr(real(32)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_store_ps(x: c_ptr(real(32)), y: vecType): void;
  //     _mm256_store_ps(x, y);
  //   }
  //   inline proc type loadu(x: c_ptrConst(real(32))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_loadu_ps(x: c_ptrConst(real(32))): vecType;
  //     return _mm256_loadu_ps(x);
  //   }
  //   inline proc type storeu(x: c_ptr(real(32)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_storeu_ps(x: c_ptr(real(32)), y: vecType): void;
  //     _mm256_storeu_ps(x, y);
  //   }

  //   inline proc type swapPairs(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapPairs32x8r(x: vecType): vecType;
  //     return swapPairs32x8r(x);
  //   }
  //   inline proc type swapLowHigh(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapLowHigh32x8r(x: vecType): vecType;
  //     return swapLowHigh32x8r(x);
  //   }
  //   inline proc type reverse(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc reverse32x8r(x: vecType): vecType;
  //     return reverse32x8r(x);
  //   }
  //   inline proc type rotateLeft(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc rotateLeft32x8r(x: vecType): vecType;
  //     return rotateLeft32x8r(x);
  //   }
  //   inline proc type rotateRight(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc rotateRight32x8r(x: vecType): vecType;
  //     return rotateRight32x8r(x);
  //   }
  //   inline proc type interleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc interleaveLower32x8r(x: vecType, y: vecType): vecType;
  //     return interleaveLower32x8r(x, y);
  //   }
  //   inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc interleaveUpper32x8r(x: vecType, y: vecType): vecType;
  //     return interleaveUpper32x8r(x, y);
  //   }
  //   inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc deinterleaveLower32x8r(x: vecType, y: vecType): vecType;
  //     return deinterleaveLower32x8r(x, y);
  //   }
  //   inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc deinterleaveUpper32x8r(x: vecType, y: vecType): vecType;
  //     return deinterleaveUpper32x8r(x, y);
  //   }
  //   inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc blendLowHigh32x8r(x: vecType, y: vecType): vecType;
  //     return blendLowHigh32x8r(x, y);
  //   }

  //   inline proc type add(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_add_ps(x: vecType, y: vecType): vecType;
  //     return _mm256_add_ps(x, y);
  //   }
  //   inline proc type sub(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_sub_ps(x: vecType, y: vecType): vecType;
  //     return _mm256_sub_ps(x, y);
  //   }
  //   inline proc type mul(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_mul_ps(x: vecType, y: vecType): vecType;
  //     return _mm256_mul_ps(x, y);
  //   }
  //   inline proc type div(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_div_ps(x: vecType, y: vecType): vecType;
  //     return _mm256_div_ps(x, y);
  //   }
  //   inline proc type hadd(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc hadd32x8r(x: vecType, y: vecType): vecType;
  //     return hadd32x8r(x, y);
  //   }

  //   inline proc type sqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_sqrt_ps(x: vecType): vecType;
  //     return _mm256_sqrt_ps(x);
  //   }
  //   inline proc type rsqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_rsqrt_ps(x: vecType): vecType;
  //     return _mm256_rsqrt_ps(x);
  //   }
  //   inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_fmadd_ps(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm256_fmadd_ps(x, y, z);
  //   }
  //   inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_fmsub_ps(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm256_fmsub_ps(x, y, z);
  //   }
  // }

  // @chplcheck.ignore("CamelCaseRecords")
  // @lint.typeOnly
  // record x8664_64x4r {
  //   proc type vecType type do return vec256d;
  //   proc type laneType type do return real(64);

  //   inline proc type extract(x: vecType, param idx: int): laneType {
  //     pragma "fn synchronization free"
  //     extern proc extract128x2d0(x: vecType): vec128d;
  //     pragma "fn synchronization free"
  //     extern proc extract128x2d1(x: vecType): vec128d;

  //     if idx == 0      then return x8664_64x2r.extract(extract128x2d0(x), 0);
  //     else if idx == 1 then return x8664_64x2r.extract(extract128x2d0(x), 1);
  //     else if idx == 2 then return x8664_64x2r.extract(extract128x2d1(x), 0);
  //     else if idx == 3 then return x8664_64x2r.extract(extract128x2d1(x), 1);
  //     else compilerError("invalid index");
  //   }
  //   inline proc type insert(x: vecType, y: laneType, param idx: int): vecType {
  //     pragma "fn synchronization free"
  //     extern proc insert128x2d0(x: vecType, y: vec128d): vecType;
  //     pragma "fn synchronization free"
  //     extern proc insert128x2d1(x: vecType, y: vec128d): vecType;
  //     pragma "fn synchronization free"
  //     extern proc extract128x2d0(x: vecType): vec128d;
  //     pragma "fn synchronization free"
  //     extern proc extract128x2d1(x: vecType): vec128d;

  //     if idx == 0      then return insert128x2d0(x, x8664_64x2r.insert(extract128x2d0(x), y, 0));
  //     else if idx == 1 then return insert128x2d0(x, x8664_64x2r.insert(extract128x2d0(x), y, 1));
  //     else if idx == 2 then return insert128x2d1(x, x8664_64x2r.insert(extract128x2d1(x), y, 0));
  //     else if idx == 3 then return insert128x2d1(x, x8664_64x2r.insert(extract128x2d1(x), y, 1));
  //     else compilerError("invalid index");
  //   }

  //   inline proc type splat(x: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_set1_pd(x: laneType): vecType;
  //     return _mm256_set1_pd(x);
  //   }
  //   inline proc type set(x: laneType, y: laneType, z: laneType, w: laneType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_setr_pd(x: laneType, y: laneType, z: laneType, w: laneType): vecType;
  //     return _mm256_setr_pd(x, y, z, w);
  //   }
  //   inline proc type loada(x: c_ptrConst(real(64))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_load_pd(x: c_ptrConst(real(64))): vecType;
  //     return _mm256_load_pd(x);
  //   }
  //   inline proc type storea(x: c_ptr(real(64)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_store_pd(x: c_ptr(real(64)), y: vecType): void;
  //     _mm256_store_pd(x, y);
  //   }
  //   inline proc type loadu(x: c_ptrConst(real(64))): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_loadu_pd(x: c_ptrConst(real(64))): vecType;
  //     return _mm256_loadu_pd(x);
  //   }
  //   inline proc type storeu(x: c_ptr(real(64)), y: vecType): void {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_storeu_pd(x: c_ptr(real(64)), y: vecType): void;
  //     _mm256_storeu_pd(x, y);
  //   }

  //   inline proc type swapPairs(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapPairs64x4r(x: vecType): vecType;
  //     return swapPairs64x4r(x);
  //   }
  //   inline proc type swapLowHigh(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc swapLowHigh64x4r(x: vecType): vecType;
  //     return swapLowHigh64x4r(x);
  //   }
  //   inline proc type reverse(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc reverse64x4r(x: vecType): vecType;
  //     return reverse64x4r(x);
  //   }
  //   inline proc type rotateLeft(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc rotateLeft64x4r(x: vecType): vecType;
  //     return rotateLeft64x4r(x);
  //   }
  //   inline proc type rotateRight(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc rotateRight64x4r(x: vecType): vecType;
  //     return rotateRight64x4r(x);
  //   }
  //   inline proc type interleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc interleaveLower64x4r(x: vecType, y: vecType): vecType;
  //     return interleaveLower64x4r(x, y);
  //   }
  //   inline proc type interleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc interleaveUpper64x4r(x: vecType, y: vecType): vecType;
  //     return interleaveUpper64x4r(x, y);
  //   }
  //   inline proc type deinterleaveLower(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc deinterleaveLower64x4r(x: vecType, y: vecType): vecType;
  //     return deinterleaveLower64x4r(x, y);
  //   }
  //   inline proc type deinterleaveUpper(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc deinterleaveUpper64x4r(x: vecType, y: vecType): vecType;
  //     return deinterleaveUpper64x4r(x, y);
  //   }
  //   inline proc type blendLowHigh(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc blendLowHigh64x4r(x: vecType, y: vecType): vecType;
  //     return blendLowHigh64x4r(x, y);
  //   }

  //   inline proc type add(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_add_pd(x: vecType, y: vecType): vecType;
  //     return _mm256_add_pd(x, y);
  //   }
  //   inline proc type sub(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_sub_pd(x: vecType, y: vecType): vecType;
  //     return _mm256_sub_pd(x, y);
  //   }
  //   inline proc type mul(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_mul_pd(x: vecType, y: vecType): vecType;
  //     return _mm256_mul_pd(x, y);
  //   }
  //   inline proc type div(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_div_pd(x: vecType, y: vecType): vecType;
  //     return _mm256_div_pd(x, y);
  //   }
  //   inline proc type hadd(x: vecType, y: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_hadd_pd(x: vecType, y: vecType): vecType;
  //     return _mm256_hadd_pd(x, y);
  //   }

  //   inline proc type sqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_sqrt_pd(x: vecType): vecType;
  //     return _mm256_sqrt_pd(x);
  //   }
  //   inline proc type rsqrt(x: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_cvtpd_ps(x: vecType): x8664_32x4r.vecType;
  //     pragma "fn synchronization free"
  //     extern proc _mm256_cvtps_pd(x: x8664_32x4r.vecType): vecType;

  //     var three = this.splat(3.0);
  //     var half = this.splat(0.5);

  //     var x_ps = _mm256_cvtpd_ps(x);
  //     // do rsqrt at 32-bit precision
  //     var res = _mm256_cvtps_pd(x8664_32x4r.rsqrt(x_ps));

  //     // TODO: would an FMA version be faster?
  //     // Newton-Raphson iteration
  //     // q = 0.5 * x * (3 - x * res * res)
  //     var muls = this.mul(this.mul(x, res), res);
  //     res = this.mul(this.mul(half, res), this.sub(three, muls));

  //     return res;
  //   }
  //   inline proc type fmadd(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_fmadd_pd(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm256_fmadd_pd(x, y, z);
  //   }
  //   inline proc type fmsub(x: vecType, y: vecType, z: vecType): vecType {
  //     pragma "fn synchronization free"
  //     extern proc _mm256_fmsub_pd(x: vecType, y: vecType, z: vecType): vecType;
  //     return _mm256_fmsub_pd(x, y, z);
  //   }
  // }



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
  }



}
