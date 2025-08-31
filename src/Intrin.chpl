module Intrin {
  use CTypes only c_ptr, c_ptrConst, c_int;
  use Arch only isX8664, isArm64;

  proc vectorType(type eltType, param numElts: int) type do
    return implType(eltType, numElts).vecType;
  proc implType(type eltType, param numElts: int) type {
    if isX8664() && numBits(eltType) * numElts == 128 {
      use IntrinX86_128;
      if eltType == real(32)      then return x8664_32x4r;
      else if eltType == real(64) then return x8664_64x2r;
      else if eltType == int(8)   then return x8664_8x16i;
      else if eltType == int(16)  then return x8664_16x8i;
      else if eltType == int(32)  then return x8664_32x4i;
      else if eltType == int(64)  then return x8664_64x2i;
      else compilerError("Unsupported vector type");

    } else if isX8664() && numBits(eltType) * numElts == 256 {
      use IntrinX86_256;
      if eltType == real(32)      then return x8664_32x8r;
      else if eltType == real(64) then return x8664_64x4r;
      else if eltType == int(8)   then return x8664_8x32i;
      else if eltType == int(16)  then return x8664_16x16i;
      else if eltType == int(32)  then return x8664_32x8i;
      else if eltType == int(64)  then return x8664_64x4i;
      else compilerError("Unsupported vector type");

    } else if isArm64() && numBits(eltType) * numElts == 128 {
      use IntrinArm64_128;
      if eltType == real(32)      then return arm64_32x4r;
      else if eltType == real(64) then return arm64_64x2r;
      else if eltType == int(8)   then return arm64_8x16i;
      else if eltType == int(16)  then return arm64_16x8i;
      else if eltType == int(32)  then return arm64_32x4i;
      else if eltType == int(64)  then return arm64_64x2i;
      else compilerError("Unsupported vector type");

    } else if isArm64() && numBits(eltType) * numElts == 256 {
      use IntrinArm64_256;
      if eltType == real(32)      then return arm64_32x8r;
      else if eltType == real(64) then return arm64_64x4r;
      else if eltType == int(8)   then return arm64_8x32i;
      else if eltType == int(16)  then return arm64_16x16i;
      else if eltType == int(32)  then return arm64_32x8i;
      else if eltType == int(64)  then return arm64_64x4i;
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }


  /*
    idx 0 is the least significant element
  */
  inline proc extract(type eltType,
                      param numElts: int,
                      x: vectorType(eltType, numElts),
                      param idx: int): eltType do
    return implType(eltType, numElts).extract(x, idx);
  /*
    idx 0 is the least significant element
  */
  inline proc insert(type eltType,
                     param numElts: int,
                     x: vectorType(eltType, numElts),
                     y: eltType,
                     param idx: int): x.type do
    return implType(eltType, numElts).insert(x, y, idx);
  inline proc splat(type eltType,
                    param numElts: int,
                    x: eltType): vectorType(eltType, numElts) do
    return implType(eltType, numElts).splat(x);

  /*
    values(0) is the least significant element
  */
  inline proc set(type eltType,
                  param numElts: int,
                  values: numElts*eltType): vectorType(eltType, numElts) do
    return implType(eltType, numElts).set((...values));
  inline proc loadAligned(
    type eltType,
    param numElts: int,
    ptr: c_ptrConst(eltType)
  ): vectorType(eltType, numElts) do
    return implType(eltType, numElts).loada(ptr);
  inline proc loadUnaligned(
    type eltType,
    param numElts: int,
    ptr: c_ptrConst(eltType)
  ): vectorType(eltType, numElts) do
    return implType(eltType, numElts).loadu(ptr);
  inline proc storeAligned(type eltType,
                           param numElts: int,
                           ptr: c_ptr(eltType),
                           x: vectorType(eltType, numElts)) do
    implType(eltType, numElts).storea(ptr, x);
  inline proc storeUnaligned(type eltType,
                             param numElts: int,
                             ptr: c_ptr(eltType),
                             x: vectorType(eltType, numElts)) do
    implType(eltType, numElts).storeu(ptr, x);

  /*
    Load with a mask
    masked out elements are zeroed out
    only the most significant bit in each vector lane is considered for the mask
  */
  inline proc loadMasked(type eltType,
                           param numElts: int,
                           ptr: c_ptrConst(eltType),
                           mask: ?): vectorType(eltType, numElts) do
    return implType(eltType, numElts).loadMasked(ptr, mask);

  inline proc gather(
    type eltType,
    param numElts: int,
    ptr: c_ptrConst(eltType),
    type indexType,
    indices: ?,
    param scale: int
  ): vectorType(eltType, numElts
  ) do
    return implType(eltType, numElts).gather(ptr, indexType, indices, scale);

   // TODO: this assumes i32 indices!!!!
  inline proc gatherMasked(
    type eltType,
    param numElts: int,
    ptr: c_ptrConst(eltType),
    type indexType,
    indices: ?,
    param scale: int,
    mask: ?,
    src: vectorType(eltType, numElts)
  ): vectorType(eltType, numElts) do
    return implType(eltType, numElts)
            .gatherMasked(ptr, indexType, indices, scale, mask, src);

  inline proc swapPairs(type eltType,
                        param numElts: int,
                        x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).swapPairs(x);
  inline proc swapLowHigh(type eltType,
                          param numElts: int,
                          x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).swapLowHigh(x);
  inline proc reverse(type eltType,
                      param numElts: int,
                      x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).reverse(x);
  inline proc rotateLeft(type eltType,
                         param numElts: int,
                         x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).rotateLeft(x);
  inline proc rotateRight(type eltType,
                          param numElts: int,
                          x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).rotateRight(x);
  inline proc interleaveLower(type eltType,
                              param numElts: int,
                              x: vectorType(eltType, numElts),
                              y: x.type): x.type do
    return implType(eltType, numElts).interleaveLower(x, y);
  inline proc interleaveUpper(type eltType,
                              param numElts: int,
                              x: vectorType(eltType, numElts),
                              y: x.type): x.type do
    return implType(eltType, numElts).interleaveUpper(x, y);
  inline proc deinterleaveLower(type eltType,
                                param numElts: int,
                                x: vectorType(eltType, numElts),
                                y: x.type): x.type do
    return implType(eltType, numElts).deinterleaveLower(x, y);
  inline proc deinterleaveUpper(type eltType,
                                param numElts: int,
                                x: vectorType(eltType, numElts),
                                y: x.type): x.type do
    return implType(eltType, numElts).deinterleaveUpper(x, y);
  inline proc blendLowHigh(type eltType,
                           param numElts: int,
                           x: vectorType(eltType, numElts),
                           y: x.type): x.type do
    return implType(eltType, numElts).blendLowHigh(x, y);


  inline proc add(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts),
                  y: x.type): x.type do
    return implType(eltType, numElts).add(x, y);
  inline proc sub(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts),
                  y: x.type): x.type do
    return implType(eltType, numElts).sub(x, y);
  inline proc mul(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts),
                  y: x.type): x.type {
    if eltType == int(64) then compilerError("mul not supported for int64");
    else                  return implType(eltType, numElts).mul(x, y);
  }
  // TODO: right now we emulate div on ints by converting to float and back
  //       is this a good idea? Should it be an error like sqrt/rsqrt on ints?
  inline proc div(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts),
                  y: x.type): x.type {
    import CVL;
    if isIntegralType(eltType) then
      if CVL.implementationWarnings then
        compilerWarning(
          "div on ints is emulated by converting to float and back"
        );
    return implType(eltType, numElts).div(x, y);
  }
  inline proc neg(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).neg(x);


  inline proc and(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts),
                  y: x.type): x.type do
    return implType(eltType, numElts).and(x, y);
  inline proc or(type eltType,
                 param numElts: int,
                 x: vectorType(eltType, numElts),
                 y: x.type): x.type do
    return implType(eltType, numElts).or(x, y);
  inline proc xor(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts),
                  y: x.type): x.type do
    return implType(eltType, numElts).xor(x, y);
  inline proc not(type eltType,
                  param numElts: int,
                  x: vectorType(eltType, numElts)):
                  x.type do
    return implType(eltType, numElts).not(x);
  
  /* ``(~x) & y`` */
  inline proc andNot(type eltType,
                     param numElts: int,
                     x: vectorType(eltType, numElts),
                     y: x.type): x.type do
    return implType(eltType, numElts).andNot(x, y);

  inline proc cmpEq(type eltType,
                    param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type): x.type do
    return implType(eltType, numElts).cmpEq(x, y);
  inline proc cmpNe(type eltType,
                    param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type): x.type do
    return implType(eltType, numElts).cmpNe(x, y);
  inline proc cmpLt(type eltType,
                    param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type): x.type do
    return implType(eltType, numElts).cmpLt(x, y);
  inline proc cmpLe(type eltType,
                    param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type): x.type do
    return implType(eltType, numElts).cmpLe(x, y);
  inline proc cmpGt(type eltType,
                    param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type): x.type do
    return implType(eltType, numElts).cmpGt(x, y);
  inline proc cmpGe(type eltType,
                    param numElts: int,
                    x: vectorType(eltType, numElts),
                    y: x.type): x.type do
    return implType(eltType, numElts).cmpGe(x, y);
  inline proc bitSelect(type eltType,
                        param numElts: int,
                        mask: ?,
                        x: vectorType(eltType, numElts),
                        y: x.type): x.type {
    return implType(eltType, numElts).bitSelect(mask, x, y);
  }
  inline proc isAllZeros(type eltType,
                         param numElts: int,
                         x: vectorType(eltType, numElts)): bool do
    return implType(eltType, numElts).isAllZeros(x);

  inline proc allOnes(type eltType,
                      param numElts: int): vectorType(eltType, numElts) do
    return implType(eltType, numElts).allOnes();
  inline proc allZeros(type eltType,
                       param numElts: int): vectorType(eltType, numElts) do
    return implType(eltType, numElts).allZeros();
  inline proc moveMask(type eltType,
                       param numElts: int,
                       x: vectorType(eltType, numElts)): c_int do
    return implType(eltType, numElts).moveMask(x);

  inline proc reinterpretCast(
    type fromEltType,
    param fromNumElts: int,
    type toEltType,
    param toNumElts: int,
    x: vectorType(fromEltType, fromNumElts)
  ): vectorType(toEltType, toNumElts) {
    if fromEltType == toEltType &&
       fromNumElts == toNumElts then
      return x; // no-op
    else
      return implType(fromEltType, fromNumElts)
        .reinterpretCast(vectorType(toEltType, toNumElts), x);
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

  inline proc min(type eltType, param numElts: int,
                  x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).min(x, y);
  inline proc max(type eltType, param numElts: int,
                  x: vectorType(eltType, numElts), y: x.type): x.type do
    return implType(eltType, numElts).max(x, y);
  inline proc abs(type eltType, param numElts: int,
                  x: vectorType(eltType, numElts)): x.type do
    return implType(eltType, numElts).abs(x);
}
