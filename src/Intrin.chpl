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

  proc vectorType(type eltType, param numElts: int) type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(64) then return vec128d;
                             else return vec128;

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(64) then return vec256d;
                             else return vec256;

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return vec32x4f;
      else if eltType == real(64) then return vec64x2d;
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return vec32x8f;
      else if eltType == real(64) then return vec64x4d;
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  /*
    idx 0 is the least significant element
  */
  inline proc extract(type eltType, param numElts: int, x: vectorType(eltType, numElts), param idx: int): eltType {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return extract32x4f(x, idx);
      else if eltType == real(64) then return extract64x2d(x, idx);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return extract32x8f(x, idx);
      else if eltType == real(64) then return extract64x4d(x, idx);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return extract32x4f(x, idx);
      else if eltType == real(64) then return extract64x2d(x, idx);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return extract32x8f(x, idx);
      else if eltType == real(64) then return extract64x4d(x, idx);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  /*
    idx 0 is the least significant element
  */
  inline proc insert(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: eltType, param idx: int): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return insert32x4f(x, y, idx);
      else if eltType == real(64) then return insert64x2d(x, y, idx);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return insert32x8f(x, y, idx);
      else if eltType == real(64) then return insert64x4d(x, y, idx);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return insert32x4f(x, y, idx);
      else if eltType == real(64) then return insert64x2d(x, y, idx);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return insert32x8f(x, y, idx);
      else if eltType == real(64) then return insert64x4d(x, y, idx);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc splat(type eltType, param numElts: int, x: eltType): vectorType(eltType, numElts) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return splat32x4f(x);
      else if eltType == real(64) then return splat64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return splat32x8f(x);
      else if eltType == real(64) then return splat64x4d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return splat32x4f(x);
      else if eltType == real(64) then return splat64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return splat32x8f(x);
      else if eltType == real(64) then return splat64x4d(x);

    } else compilerError("Unsupported vector type");
  }

  /*
    values(0) is the least significant element
  */
  inline proc set(type eltType, param numElts: int, values: numElts*eltType): vectorType(eltType, numElts) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return set32x4f((...values));
      else if eltType == real(64) then return set64x2d((...values));
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return set32x8f((...values));
      else if eltType == real(64) then return set64x4d((...values));
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return set32x4f((...values));
      else if eltType == real(64) then return set64x2d((...values));
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return set32x8f((...values));
      else if eltType == real(64) then return set64x4d((...values));
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc loadAligned(type eltType, param numElts: int, ptr: c_ptrConst(eltType)): vectorType(eltType, numElts) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return loada32x4f(ptr);
      else if eltType == real(64) then return loada64x2d(ptr);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return loada32x8f(ptr);
      else if eltType == real(64) then return loada64x4d(ptr);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return load32x4f(ptr);
      else if eltType == real(64) then return load64x2d(ptr);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return load32x8f(ptr);
      else if eltType == real(64) then return load64x4d(ptr);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc loadUnaligned(type eltType, param numElts: int, ptr: c_ptrConst(eltType)): vectorType(eltType, numElts) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return loadu32x4f(ptr);
      else if eltType == real(64) then return loadu64x2d(ptr);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return loadu32x8f(ptr);
      else if eltType == real(64) then return loadu64x4d(ptr);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return load32x4f(ptr);
      else if eltType == real(64) then return load64x2d(ptr);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return load32x8f(ptr);
      else if eltType == real(64) then return load64x4d(ptr);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc storeAligned(type eltType, param numElts: int, ptr: c_ptr(eltType), x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then storea32x4f(ptr, x);
      else if eltType == real(64) then storea64x2d(ptr, x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then storea32x8f(ptr, x);
      else if eltType == real(64) then storea64x4d(ptr, x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then store32x4f(ptr, x);
      else if eltType == real(64) then store64x2d(ptr, x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then store32x8f(ptr, x);
      else if eltType == real(64) then store64x4d(ptr, x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc storeUnaligned(type eltType, param numElts: int, ptr: c_ptr(eltType), x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then storeu32x4f(ptr, x);
      else if eltType == real(64) then storeu64x2d(ptr, x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then storeu32x8f(ptr, x);
      else if eltType == real(64) then storeu64x4d(ptr, x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then store32x4f(ptr, x);
      else if eltType == real(64) then store64x2d(ptr, x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then store32x8f(ptr, x);
      else if eltType == real(64) then store64x4d(ptr, x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }

  inline proc swapPairs(type eltType, param numElts, x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return swapPairs32x4f(x);
      else if eltType == real(64) then return swapPairs64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return swapPairs32x4f(x);
      else if eltType == real(64) then return swapPairs64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return swapPairs32x8f(x);
      else if eltType == real(64) then return swapPairs64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc swapLowHigh(type eltType, param numElts, x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return swapLowHigh32x4f(x);
      else if eltType == real(64) then return swapLowHigh64x2d(x);
      else compilerError("Unsupported vector type");
    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return swapLowHigh32x4f(x);
      else if eltType == real(64) then return swapLowHigh64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return swapLowHigh32x8f(x);
      else if eltType == real(64) then return swapLowHigh64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc reverse(type eltType, param numElts, x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return reverse32x4f(x);
      else if eltType == real(64) then return reverse64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return reverse32x4f(x);
      else if eltType == real(64) then return reverse64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return reverse32x8f(x);
      else if eltType == real(64) then return reverse64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc rotateLeft(type eltType, param numElts, x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return rotateLeft32x4f(x);
      else if eltType == real(64) then return rotateLeft64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return rotateLeft32x4f(x);
      else if eltType == real(64) then return rotateLeft64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return rotateLeft32x8f(x);
      else if eltType == real(64) then return rotateLeft64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc rotateRight(type eltType, param numElts, x: vectorType(eltType, numElts)) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return rotateRight32x4f(x);
      else if eltType == real(64) then return rotateRight64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return rotateRight32x4f(x);
      else if eltType == real(64) then return rotateRight64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return rotateRight32x8f(x);
      else if eltType == real(64) then return rotateRight64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc interleaveLower(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return interleaveLower32x4f(x, y);
      else if eltType == real(64) then return interleaveLower64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return interleaveLower32x4f(x, y);
      else if eltType == real(64) then return interleaveLower64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return interleaveLower32x8f(x, y);
      else if eltType == real(64) then return interleaveLower64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc interleaveUpper(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return interleaveUpper32x4f(x, y);
      else if eltType == real(64) then return interleaveUpper64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return interleaveUpper32x4f(x, y);
      else if eltType == real(64) then return interleaveUpper64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return interleaveUpper32x8f(x, y);
      else if eltType == real(64) then return interleaveUpper64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc deinterleaveLower(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return deinterleaveLower32x4f(x, y);
      else if eltType == real(64) then return deinterleaveLower64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return deinterleaveLower32x4f(x, y);
      else if eltType == real(64) then return deinterleaveLower64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return deinterleaveLower32x8f(x, y);
      else if eltType == real(64) then return deinterleaveLower64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc deinterleaveUpper(type eltType, param numElts, x: vectorType(eltType, numElts), y: x.type) {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return deinterleaveUpper32x4f(x, y);
      else if eltType == real(64) then return deinterleaveUpper64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return deinterleaveUpper32x4f(x, y);
      else if eltType == real(64) then return deinterleaveUpper64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return deinterleaveUpper32x8f(x, y);
      else if eltType == real(64) then return deinterleaveUpper64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc blendLowHigh(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return blendLowHigh32x4f(x, y);
      else if eltType == real(64) then return blendLowHigh64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return blendLowHigh32x4f(x, y);
      else if eltType == real(64) then return blendLowHigh64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return blendLowHigh32x8f(x, y);
      else if eltType == real(64) then return blendLowHigh64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }


  inline proc add(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return add32x4f(x, y);
      else if eltType == real(64) then return add64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return add32x8f(x, y);
      else if eltType == real(64) then return add64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return add32x4f(x, y);
      else if eltType == real(64) then return add64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return add32x8f(x, y);
      else if eltType == real(64) then return add64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc sub(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return sub32x4f(x, y);
      else if eltType == real(64) then return sub64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return sub32x8f(x, y);
      else if eltType == real(64) then return sub64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return sub32x4f(x, y);
      else if eltType == real(64) then return sub64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return sub32x8f(x, y);
      else if eltType == real(64) then return sub64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc mul(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return mul32x4f(x, y);
      else if eltType == real(64) then return mul64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return mul32x8f(x, y);
      else if eltType == real(64) then return mul64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return mul32x4f(x, y);
      else if eltType == real(64) then return mul64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return mul32x8f(x, y);
      else if eltType == real(64) then return mul64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc div(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return div32x4f(x, y);
      else if eltType == real(64) then return div64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return div32x8f(x, y);
      else if eltType == real(64) then return div64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return div32x4f(x, y);
      else if eltType == real(64) then return div64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return div32x8f(x, y);
      else if eltType == real(64) then return div64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }

  // TODO: revist hadd semantics, x86 is all over the place
  /*
    Add pairs of adjacent elements

    x: [a, b, c, d]
    y: [e, f, g, h]

    returns: [a+b, e+f, c+d, g+h]
  */
  inline proc hadd(type eltType, param numElts: int, x: vectorType(eltType, numElts), y: x.type): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return hadd32x4f(x, y);
      else if eltType == real(64) then return hadd64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return hadd32x8f(x, y);
      else if eltType == real(64) then return hadd64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return hadd32x4f(x, y);
      else if eltType == real(64) then return hadd64x2d(x, y);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return hadd32x8f(x, y);
      else if eltType == real(64) then return hadd64x4d(x, y);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc sqrt(type eltType, param numElts: int, x: vectorType(eltType, numElts)): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return sqrt32x4f(x);
      else if eltType == real(64) then return sqrt64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return sqrt32x8f(x);
      else if eltType == real(64) then return sqrt64x4d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return sqrt32x4f(x);
      else if eltType == real(64) then return sqrt64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return sqrt32x8f(x);
      else if eltType == real(64) then return sqrt64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }
  inline proc rsqrt(type eltType, param numElts: int, x: vectorType(eltType, numElts)): x.type {
    if use_x8664_128(eltType, numElts) {
      use IntrinX86_128;
      if eltType == real(32)      then return rsqrt32x4f(x);
      else if eltType == real(64) then return rsqrt64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_x8664_256(eltType, numElts) {
      use IntrinX86_256;
      if eltType == real(32)      then return rsqrt32x8f(x);
      else if eltType == real(64) then return rsqrt64x4d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_128(eltType, numElts) {
      use IntrinArm64_128;
      if eltType == real(32)      then return rsqrt32x4f(x);
      else if eltType == real(64) then return rsqrt64x2d(x);
      else compilerError("Unsupported vector type");

    } else if use_arm64_256(eltType, numElts) {
      use IntrinArm64_256;
      if eltType == real(32)      then return rsqrt32x8f(x);
      else if eltType == real(64) then return rsqrt64x4d(x);
      else compilerError("Unsupported vector type");

    } else compilerError("Unsupported vector type");
  }

}
