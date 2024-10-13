module Intrin {
  use CTypes only c_ptr, c_ptrConst;

  import ChplConfig;
  proc isX8664() param do return ChplConfig.CHPL_TARGET_ARCH == "x86_64";
  proc isArm64() param do return ChplConfig.CHPL_TARGET_ARCH == "arm64";

  proc use_x8664_128(type eltType, param numElts: int) param do
    return isX8664() && numBits(eltType) * numElts == 128;
  proc use_x8664_256(type eltType, param numElts: int) param do
    return isX8664() && numBits(eltType) * numElts == 256;
  proc use_arm64_128(type eltType, param numElts: int) param do
    return isArm64() && numBits(eltType) * numElts == 128;
  proc use_arm64_256(type eltType, param numElts: int) param do
    return isArm64() && numBits(eltType) * numElts == 256;

  proc vectorType(type eltType, param numElts: int) type do
    return implType(eltType, numElts).vecType;
  proc implType(type eltType, param numElts: int) type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return x8664_32x4f;
      else if eltType == real(64) then return x8664_64x2d;
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return x8664_32x8f;
      else if eltType == real(64) then return x8664_64x4d;
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return arm64_32x4f;
      else if eltType == real(64) then return arm64_64x2d;
      else if eltType == int(8)   then return arm64_8x16i;
      else if eltType == int(16)  then return arm64_16x8i;
      else if eltType == int(32)  then return arm64_32x4i;
      else if eltType == int(64)  then return arm64_64x2i;
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return arm64_32x8f;
      else if eltType == real(64) then return arm64_64x4d;
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }


  /*
    idx 0 is the least significant element
  */
  inline proc extract(type eltType, param numElts: int, x: vectorType(eltType, numElts), param idx: int): eltType do
    return implType(eltType, numElts).extract(x, idx);
  /*
    idx 0 is the least significant element
  */
  inline proc insert(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: eltType, param idx: int): x.type do
    return implType(eltType, numElts).insert(x, y, idx);
  inline proc splat(type eltType, param numElts: int, x: eltType): vectorType(eltType, numElts) do
    return implType(eltType, numElts).splat(x);

  /*
    values(0) is the least significant element
  */
  inline proc set(type eltType, param numElts: int, values: numElts*eltType): vectorType(eltType, numElts) do
    return implType(eltType, numElts).set((...values));
  inline proc loadAligned(type eltType, param numElts: int, ptr: c_ptrConst(eltType)): vectorType(eltType, numElts) do
    return implType(eltType, numElts).loada(ptr);
  inline proc loadUnaligned(type eltType, param numElts: int, ptr: c_ptrConst(eltType)): vectorType(eltType, numElts) do
    return implType(eltType, numElts).loadu(ptr);
  inline proc storeAligned(type eltType, param numElts: int, ptr: c_ptr(eltType), x: vectorType(eltType, numElts)) do
    implType(eltType, numElts).storea(ptr, x);
  inline proc storeUnaligned(type eltType, param numElts: int, ptr: c_ptr(eltType), x: vectorType(eltType, numElts)) do
    implType(eltType, numElts).storeu(ptr, x);

  inline proc swapPairs(type eltType, param numElts, x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).swapPairs(x);
  inline proc swapLowHigh(type eltType, param numElts, x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).swapLowHigh(x);
  inline proc reverse(type eltType, param numElts, x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).reverse(x);
  inline proc rotateLeft(type eltType, param numElts, x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).rotateLeft(x);
  inline proc rotateRight(type eltType, param numElts, x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).rotateRight(x);
  inline proc interleaveLower(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).interleaveLower(x, y);
  inline proc interleaveUpper(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).interleaveUpper(x, y);
  inline proc deinterleaveLower(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).deinterleaveLower(x, y);
  inline proc deinterleaveUpper(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).deinterleaveUpper(x, y);
  inline proc blendLowHigh(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).blendLowHigh(x, y);


  inline proc add(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).add(x, y);
  inline proc sub(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).sub(x, y);
  inline proc mul(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if eltType == int(64) then compilerError("mul not supported for int64");
    else                  return implType(eltType, numElts).mul(x, y);
  }
  // TODO: right now we emulate div on ints by converting to float and back
  //       is this a good idea? Should it be an error like sqrt/rsqrt on ints?
  inline proc div(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    compilerWarning("div on ints is emulated by converting to float and back");
    return implType(eltType, numElts).div(x, y);
  }

  /*
    Add pairs of adjacent elements

    x: [a, b, c, d]
    y: [e, f, g, h]

    returns: [a+b, e+f, c+d, g+h]
  */
  inline proc hadd(type eltType, param numElts: int,
                   x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).hadd(x, y);
  inline proc sqrt(type eltType, param numElts: int,
                   x: vectorType(eltType, numElts)): x.type {
    if isIntegralType(eltType) then
      compilerError("sqrt not supported for integral types");
    else
      return implType(eltType, numElts).sqrt(x);
  }
  inline proc rsqrt(type eltType, param numElts: int,
                    x: vectorType(eltType, numElts)): x.type {
    if isIntegralType(eltType) then
      compilerError("rsqrt not supported for integral types");
    else
      return implType(eltType, numElts).rsqrt(x);
  }

  /* Performs (x*y)+z */
  inline proc fmadd(type eltType, param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type, z: x.type): x.type {
    if eltType == int(64) then compilerError("fmadd not supported for int64");
    else                  return implType(eltType, numElts).fmadd(x, y, z);
  }

  /* Performs (x*y)-z */
  inline proc fmsub(type eltType, param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type, z: x.type): x.type {
    if eltType == int(64) then compilerError("fmsub not supported for int64");
    else                  return implType(eltType, numElts).fmsub(x, y, z);
  }
}
