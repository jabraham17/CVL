module Vector {
  use CTypes only c_ptr, c_ptrConst,
                  c_ptrTo, c_ptrToConst,
                  c_addrOf, c_addrOfConst, c_int;
  import Intrin;
  use VectorRef only vectorRef;

  proc numBits(type t) param: int where isSubtype(t, vector) do
    return numBits(t.eltType) * t.numElts;

  private proc isValidContainer(container: ?, type eltType) param: bool
  where isArray(container) {
    return container.rank == 1 &&
           container.isRectangular() &&
           container._value.isDefaultRectangular() &&
           container.eltType == eltType;
  }
  private proc isValidContainer(container: ?, type eltType) param: bool
  where isHomogeneousTuple(container) {
    return container(0).type == eltType;
  }
  private proc isValidContainer(container: ?, type eltType) param: bool
  where container.type == bytes {
    return eltType == int(8) || eltType == uint(8);
  }

  @chplcheck.ignore("UnusedFormal")
  private proc isValidContainer(container: ?, type eltType) param: bool {
    return false;
  }

  private proc isValidContainerForStore(
    container: ?, type eltType
  ) param: bool do
    return isValidContainer(container, eltType) && container.type != bytes;

  record vector: writeSerializable {
    type eltType;
    param numElts: int;
    var data: Intrin.vectorType(eltType, numElts);

    /* type init*/
    inline proc init(type eltType, param numElts: int) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = Intrin.splat(eltType, numElts, 0:eltType);
    }
    /* init to single value */
    inline proc init(type eltType, param numElts: int, value: eltType) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = Intrin.splat(eltType, numElts, value);
    }
    /* init to single value, infer type */
    inline proc init(param numElts: int, value: ?eltType) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = Intrin.splat(eltType, numElts, value);
    }

    //
    // init from other vector
    //
    inline proc init(type eltType,
                     param numElts: int,
                     value: vector(eltType, numElts)) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = value.data;
    }
    inline proc init=(value: vector(?)) {
      this.eltType = value.eltType;
      this.numElts = value.numElts;
      this.data = value.data;
    }
    inline operator=(ref lhs: vector(?), rhs: lhs.type) {
      lhs.data = rhs.data;
    }
    inline proc ref set(value: vector(eltType, numElts)) {
      this.data = value.data;
    }

    //
    // init from tuple
    //
    inline proc init(type eltType, param numElts: int, values)
      where isHomogeneousTupleType(values.type) &&
            isCoercible(values(0).type, eltType) &&
            numElts == values.size {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = Intrin.set(this.eltType, this.numElts, values);
    }
    inline proc init(values) where isHomogeneousTupleType(values.type) {
      this.eltType = values(0).type;
      this.numElts = values.size;
      this.data = Intrin.set(this.eltType, this.numElts, values);
    }
    inline proc init=(values) where isHomogeneousTupleType(values.type) {
      this.eltType = values(0).type;
      this.numElts = values.size;
      this.data = Intrin.set(this.eltType, this.numElts, values);
    }
    inline operator=(ref lhs, rhs)
    where isSubtype(lhs.type, vector) &&
          isHomogeneousTupleType(rhs.type) &&
          isCoercible(rhs(0).type, lhs.eltType) &&
          lhs.numElts == rhs.size {
      lhs.set(rhs);
    }
    inline operator:(x: ?tupType, type t: vector(?))
    where isHomogeneousTupleType(tupType) &&
          isCoercible(x(0).type, t.eltType) &&
          x.size == t.numElts {

      var result: t;
      result.set(x);
      return result;
    }

    //
    // init from scalar
    //
    inline operator:(x: ?eltType, type t: vector(?))
    where isCoercible(eltType, t.eltType) {
      var result: t;
      result.set(x);
      return result;
    }

    //
    // cast to tuple
    //
    inline operator:(x: vector(?eltType, ?numElts), type tupType)
    where isHomogeneousTupleType(tupType) &&
          isCoercible(eltType, tupType(0)) &&
          tupType.size == numElts {
      type resEltType = tupType(0);
      var result: tupType;
      for param i in 0..#numElts {
        result(i) = x[i]:resEltType;
      }
      return result;
    }

    inline proc toTuple(): numElts * eltType {
      type tupType = numElts * eltType;
      return this:tupType;
    }

    inline proc ref set(value)
    where isCoercible(value.type, eltType) do
      data = Intrin.splat(eltType, numElts, value:eltType);
    inline proc ref set(values)
    where isHomogeneousTupleType(values.type) &&
          isCoercible(values(0).type, eltType) &&
          values.size == numElts {
      var values_: numElts*eltType;
      for param i in 0..<numElts do
        values_[i] = values[i]:eltType;
      data = Intrin.set(eltType, numElts, values_);
    }
    inline proc ref set(param idx: integral, value)
      where isCoercible(value.type, eltType) do
      data = Intrin.insert(eltType, numElts, data, value:eltType, idx);

    inline proc this(param idx: integral): eltType do
      return Intrin.extract(eltType, numElts, data, idx);
    inline iter these(): eltType {
      for param i in 0..#numElts {
        yield this[i];
      }
    }

    @chplcheck.ignore("CamelCaseFunctions")
    @chpldoc.nodoc
    inline proc type _computeAddress(ref arr: [] eltType,
                                     idx: integral,
                                     param checkBounds = true): c_ptr(eltType)
    where isValidContainer(arr, eltType) {
      if checkBounds && boundsChecking {
        // reuse array slice bounds checking
        arr[idx.. by arr.domain.stride # numElts];
      }
      const ptr = c_addrOf(arr[idx]);
      return ptr;
    }
    @chplcheck.ignore("CamelCaseFunctions")
    @chpldoc.nodoc
    inline proc type _computeAddressConst(
      arr: [] eltType,
      idx: integral,
      param checkBounds = true
    ): c_ptrConst(eltType)
    where isValidContainer(arr, eltType) {
      if checkBounds && boundsChecking {
        // reuse array slice bounds checking
        arr[idx.. by arr.domain.stride # numElts];
      }
      const ptr = c_addrOfConst(arr[idx]);
      return ptr;
    }
    @chplcheck.ignore("CamelCaseFunctions")
    @chpldoc.nodoc
    inline proc type _computeAddress(ref tup,
                                     idx: integral,
                                     param checkBounds = true): c_ptr(eltType)
    where isTuple(tup) && isValidContainer(tup, eltType) {
      if checkBounds && boundsChecking {
        if idx+numElts-1 >= tup.size {
          halt("out of bounds address");
        }
      }
      const ptr = c_addrOf(tup(idx));
      return ptr;
    }
    @chplcheck.ignore("CamelCaseFunctions")
    @chpldoc.nodoc
    inline proc type _computeAddressConst(
      tup,
      idx: integral,
      param checkBounds = true
    ): c_ptrConst(eltType)
    where isTuple(tup) && isValidContainer(tup, eltType) {
      if checkBounds && boundsChecking {
        if idx+numElts-1 >= tup.size {
          halt("out of bounds address");
        }
      }
      const ptr = c_addrOfConst(tup(idx));
      return ptr;
    }

    @chplcheck.ignore("CamelCaseFunctions")
    @chpldoc.nodoc
    inline proc type _computeAddress(ref bytes_: bytes,
                                     idx: integral,
                                     param checkBounds = true): c_ptr(eltType)
    where isValidContainer(bytes_, eltType) {
      if checkBounds && boundsChecking {
        if idx+numElts-1 >= bytes_.numBytes {
          halt("out of bounds address");
        }
      }
      const ptr = c_ptrTo(bytes_) + idx;
      return ptr:c_ptr(eltType);
    }
    @chplcheck.ignore("CamelCaseFunctions")
    @chpldoc.nodoc
    inline proc type _computeAddressConst(
      const ref bytes_: bytes,
      idx: integral,
      param checkBounds = true
    ): c_ptrConst(eltType)
    where isValidContainer(bytes_, eltType) {
      if checkBounds && boundsChecking {
        if idx+numElts-1 >= bytes_.numBytes {
          halt("out of bounds address");
        }
      }
      const ptr = c_ptrToConst(bytes_) + idx;
      return ptr:c_ptrConst(eltType);
    }



    inline proc ref load(ptr: c_ptrConst(eltType),
                         idx: integral = 0,
                         param aligned: bool = false) {
      var ptr_ = ptr + idx;
      if aligned then
        data = Intrin.loadAligned(eltType, numElts, ptr_);
      else
        data = Intrin.loadUnaligned(eltType, numElts, ptr_);
    }
    inline proc ref load(container: ?,
                         idx: integral = 0,
                         param aligned: bool = false)
    where isValidContainer(container, eltType) {
      const ptr = this.type._computeAddressConst(container, idx);
      load(ptr, idx=0, aligned=aligned);
    }


    inline proc store(ptr: c_ptr(eltType),
                      idx: integral = 0,
                      param aligned: bool = false) {
      var ptr_ = ptr + idx;
      if aligned then
        Intrin.storeAligned(eltType, numElts, ptr_, data);
      else
        Intrin.storeUnaligned(eltType, numElts, ptr_, data);
    }
    inline proc store(ref container: ?,
                      idx: integral = 0,
                      param aligned: bool = false)
    where isValidContainerForStore(container, eltType) do
      store(this.type._computeAddress(container, idx), idx=0, aligned=aligned);

    inline proc type load(container: ?,
                          idx: integral = 0,
                          param aligned: bool = false): this {
      var result: this;
      result.load(container, idx=idx, aligned=aligned);
      return result;
    }


    @chpldoc.nodoc
    proc type isValidLoadMask(type maskType,
                              param onlyInts: bool = true) param : bool {
      return isSubtype(maskType, vector) &&
             numBits(maskType) == numBits(this) &&
             (!onlyInts || isIntegralType(maskType.eltType));
    }
    /* loadMasked is not bounds checked */
    inline proc type loadMasked(mask: vector(?),
                                container: ?,
                                idx: integral = 0): this {
      var result: this;
      result.loadMasked(mask, container, idx=idx);
      return result;
    }
    /* loadMasked is not bounds checked */
    inline proc ref loadMasked(mask: vector(?),
                               ptr: c_ptrConst(eltType),
                               idx: integral = 0)
    where this.type.isValidLoadMask(mask.type) {
      var ptr_ = ptr + idx;
      data = Intrin.loadMasked(eltType, numElts, ptr_, mask.data);
    }
    /* loadMasked is not bounds checked */
    inline proc ref loadMasked(mask: vector(?),
                               container: ?,
                               idx: integral = 0)
    where this.type.isValidLoadMask(mask.type) &&
          isValidContainer(container, eltType) {
      const ptr =
        this.type._computeAddressConst(container, idx, checkBounds=false);
      loadMasked(mask, ptr, idx=0);
    }

    // TODO: store mask

    // TODO: for simplicity, gather requires an index vector of type int(32)
    proc type indexVectorType type {
      type indexType = int(32);
      if numBits(this) == 256 {
        return vector(indexType, numBits(this)/numBits(eltType));
      } else if numBits(this) == 128 {
        return vector(indexType, 4);
      } else {
        compilerError("unknown vector type for indexVectorType: " +
                      this:string);
      }
    }

    /* gather is not bounds checked */
    inline proc type gather(
      container: ?,
      startIdx: integral,
      indexVector: this.indexVectorType,
      param scale: int = 0,
      mask: ? = none
    ): this {
      var result = new this();
      result.gather(container, startIdx, indexVector, scale=scale, mask=mask);
      return result;
    }

    /* gather is not bounds checked */
    inline proc ref gather(
      ptr: c_ptrConst(eltType),
      startIdx: integral,
      indexVector: this.type.indexVectorType,
      param scale: int = 0,
      mask: ? = none
    ) where mask.type == nothing ||
            this.type.isValidLoadMask(mask.type, onlyInts=false) {
      var ptr_ = ptr + startIdx;
      if mask.type == nothing {
        data = Intrin.gather(eltType, numElts, ptr_,
                             indexVector.eltType, indexVector.data, scale);
      } else {
        data = Intrin.gatherMasked(eltType, numElts, ptr_,
                                   indexVector.eltType, indexVector.data,
                                   scale, mask.data, this.data);
      }
    }
    /* gather is not bounds checked */
    inline proc ref gather(
      arr: [] eltType,
      startIdx: integral,
      indexVector: this.type.indexVectorType,
      param scale: int = 0,
      mask: ? = none
    ) where (mask.type == nothing ||
             this.type.isValidLoadMask(mask.type, onlyInts=false)) &&
            isValidContainer(arr, eltType) {
      const ptr =
        this.type._computeAddressConst(arr, startIdx, checkBounds=false);
      gather(ptr, 0, indexVector, scale=scale, mask=mask);
    }

    /* gather is not bounds checked */
    inline proc ref gather(
      tup,
      startIdx: integral,
      indexVector: this.type.indexVectorType,
      param scale: int = 0,
      mask: ? = none
    ) where (mask.type == nothing ||
             this.type.isValidLoadMask(mask.type, onlyInts=false)) &&
            isValidContainer(tup, eltType) &&
            isHomogeneousTuple(tup) {
      const ptr =
        this.type._computeAddressConst(tup, startIdx, checkBounds=false);
      gather(ptr, 0, indexVector, scale=scale, mask=mask);
    }



    inline proc transmute(type t): t where isSubtype(t, vector) &&
                                           numBits(t) == numBits(this.type) {
      var result: t;
      result.data = Intrin.reinterpretCast(eltType, numElts,
                                          t.eltType, t.numElts, this.data);
      return result;
    }
    inline proc transmute(type t): t where !isSubtype(t, vector) {
      compilerError("cannot transmute to non-vector type: " + t:string);
    }
    inline proc transmute(type t): t where isSubtype(t, vector) &&
                                      numBits(t) != numBits(this.type) {
      compilerError("cannot transmute vector of length " +
                    numBits(this) + " to vector of length " + numBits(t));
    }



    // TODO: transmute (bitcast)
    // TODO: typecast



    inline proc type indices(
      rng: range(?)
    ): range(strides=strideKind.positive) do
      return rng by numElts;
    inline proc type indices(dom: domain(?)): domain(?) do
      return dom by numElts;
    inline proc type indices(container: ?): range(strides=strideKind.positive)
    where isHomogeneousTuple(container) do
      return 0..#container.size by numElts;
    inline proc type indices(container: ?): domain(?)
    where isArray(container) do
      return container.domain by numElts;

    // TODO: how can I avoid the extra load per loop of the array metadata?

    inline iter type vectors(container: ?, param aligned: bool = false): this
      where isValidContainer(container, eltType) {
      for i in indices(container) {
        yield this.load(container, i, aligned=aligned);
      }
    }
    inline iter type vectors(param tag: iterKind,
                             container: ?,
                             param aligned: bool = false): this
    where tag == iterKind.standalone && isValidContainer(container, eltType) {
      for i in indices(container).these(tag=tag) {
        yield this.load(container, i, aligned=aligned);
      }
    }
    @chplcheck.ignore("UnusedFormal")
    inline iter type vectors(param tag: iterKind,
                             container: ?,
                             param aligned: bool = false): this
    where tag == iterKind.leader && isValidContainer(container, eltType) {
      for followThis in indices(container).these(tag=tag) {
        yield followThis;
      }
    }
    inline iter type vectors(param tag: iterKind,
                             followThis,
                             container: ?,
                             param aligned: bool = false): this
    where tag == iterKind.follower && isValidContainer(container, eltType) {
      for i in indices(container).these(tag=tag, followThis=followThis) {
        yield this.load(container, i, aligned=aligned);
      }
    }

    inline iter type vectorsRef(ref container: ?,
                                param aligned: bool = false) ref : this
    where isValidContainer(container, eltType) {
      for i in indices(container) {
        const addr = this._computeAddress(container, i);
        var vr = new vectorRef(this, addr, aligned=aligned);
        yield vr;
      }
    }
    inline iter type vectorsRef(param tag: iterKind,
                                ref container: ?,
                                param aligned: bool = false) ref : this
    where tag == iterKind.standalone && isValidContainer(container, eltType) {
      for i in indices(container).these(tag=tag) {
        const addr = this._computeAddress(container, i);
        var vr = new vectorRef(this, addr, aligned=aligned);
        yield vr;
      }
    }
    @chplcheck.ignore("UnusedFormal")
    inline iter type vectorsRef(param tag: iterKind,
                                ref container: ?,
                                param aligned: bool = false) ref : this
      where tag == iterKind.leader && isValidContainer(container, eltType) {
      for followThis in indices(container).these(tag=tag) {
        yield followThis;
      }
    }
    inline iter type vectorsRef(param tag: iterKind,
                                followThis,
                                ref container: ?,
                                param aligned: bool = false) ref : this
    where tag == iterKind.follower && isValidContainer(container, eltType) {
      for i in indices(container).these(tag=tag, followThis=followThis) {
        const addr = this._computeAddress(container, i);
        var vr = new vectorRef(this, addr, aligned=aligned);
        yield vr;
      }
    }



    // TODO: is it really worth having this?
    inline iter type vectorsJagged(arr: ?,
                                   pad: eltType = 0,
                                   param aligned: bool = false): this {
      // TODO: is this really the most efficient way to do this?
      // this should iterate over a range, and pad the extra with 'pad'
      // so that the last iteration is a full vector
      for i in arr.domain by numElts {
        if i+numElts <= arr.domain.high then
          yield this.load(arr, i, aligned=aligned);
        else {
          var tup: numElts*eltType;
          for param j in 0..#numElts do tup(j) = pad;
          for j in 0..#(arr.domain.high-i+1) do tup(j) = arr[i+j];
          yield this.load(tup, aligned=aligned);
        }
      }
    }


    @chplcheck.ignore("UnusedFormal")
    proc serialize(writer, ref serializer) throws {
      var s: string;
      var sep = "";
      for param i in 0..#numElts {
        writer.write(sep, this[i]);
        sep = ", ";
      }
      return s;
    }
  }


  inline proc swapPairs(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.swapPairs(eltType, numElts, x.data);
    return result;
  }
  inline proc swapLowHigh(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.swapLowHigh(eltType, numElts, x.data);
    return result;
  }
  inline proc reverse(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.reverse(eltType, numElts, x.data);
    return result;
  }
  inline proc rotateLeft(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.rotateLeft(eltType, numElts, x.data);
    return result;
  }
  inline proc rotateRight(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.rotateRight(eltType, numElts, x.data);
    return result;
  }
  inline proc interleaveLower(x: vector(?eltType, ?numElts),
                              y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.interleaveLower(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc interleaveUpper(x: vector(?eltType, ?numElts),
                              y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.interleaveUpper(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc deinterleaveLower(x: vector(?eltType, ?numElts),
                                y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.deinterleaveLower(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc deinterleaveUpper(x: vector(?eltType, ?numElts),
                                y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.deinterleaveUpper(eltType, numElts, x.data, y.data);
    return result;
  }

  /*
    pairwise add adjacent elements

    x: [a, b, c, d]
    y: [e, f, g, h]

    returns: [a+b, e+f, c+d, g+h]
  */
  inline proc pairwiseAdd(x: vector(?eltType, ?numElts), y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.hadd(eltType, numElts, x.data, y.data);
    return result;
  }

  /*
    takes the low half of x and the high half of y
  */
  inline proc blendLowHigh(x: vector(?eltType, ?numElts), y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.blendLowHigh(eltType, numElts, x.data, y.data);
    return result;
  }


  inline proc vector.isZero(): bool {
    return Intrin.isAllZeros(eltType, numElts, this.data);
  }
  inline proc vector.moveMask(): c_int {
    import CVL;
    if CVL.implementationWarnings then
      compilerWarning("moveMask is not implemented properly yet");
    return Intrin.moveMask(eltType, numElts, this.data);
  }
  inline proc type vector.ones(): this {
    var result: this;
    result.data = Intrin.allOnes(eltType, numElts);
    return result;
  }
  inline proc type vector.zeros(): this {
    var result: this;
    result.data = Intrin.allZeros(eltType, numElts);
    return result;
  }


  /*
    Shift each lane left by the given amount, shifting in zeros.
  */
  inline proc vector.shiftLeft(param amount: int): this.type
  where isIntegralType(eltType) {
    var result: this.type;
    result.data = Intrin.shiftLeftImm(eltType, numElts, this.data, amount);
    return result;
  }
  inline proc vector.shiftLeft(amount: this.type): this.type
  where isIntegralType(eltType) {
    var result: this.type;
    result.data = Intrin.shiftLeftVec(eltType, numElts, this.data, amount);
    return result;
  }


  /*
    Shift each lane right by the given amount, shifting in zeros.
  */
  inline proc vector.shiftRight(param amount: int): this.type
  where isIntegralType(eltType) {
    var result: this.type;
    result.data = Intrin.shiftRightImm(eltType, numElts, this.data, amount);
    return result;
  }
  inline proc vector.shiftRight(amount: this.type): this.type
  where isIntegralType(eltType) {
    var result: this.type;
    result.data = Intrin.shiftRightVec(eltType, numElts, this.data, amount);
    return result;
  }
  /*
    Shift each lane right by the given amount, shifting in sign bits.
  */
  inline proc vector.shiftRightArithmetic(param amount: int): this.type
  where isSignedType(eltType) {
    var result: this.type;
    result.data = Intrin.shiftRightArithmeticImm(eltType, numElts, this.data, amount);
    return result;
  }
  inline proc vector.shiftRightArithmetic(amount: this.type): this.type
  where isSignedType(eltType) {
    var result: this.type;
    result.data = Intrin.shiftRightArithmeticVec(eltType, numElts, this.data, amount);
    return result;
  }



  inline proc sqrt(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.sqrt(eltType, numElts, x.data);
    return result;
  }
  inline proc rsqrt(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.rsqrt(eltType, numElts, x.data);
    return result;
  }

  inline proc fma(x: vector(?eltType, ?numElts),
                    y: x.type,
                    z: x.type): x.type {
    var result: x.type;
    result.data = Intrin.fmadd(eltType, numElts, x.data, y.data, z.data);
    return result;
  }
  inline proc fms(x: vector(?eltType, ?numElts),
                    y: x.type,
                    z: x.type): x.type {
    var result: x.type;
    result.data = Intrin.fmsub(eltType, numElts, x.data, y.data, z.data);
    return result;
  }

  inline proc bitSelect(mask: vector(?),
                        x: vector(?eltType, ?numElts),
                        y: x.type): x.type
  where numBits(mask.type) == numBits(x.type) {
    var result: x.type;
    result.data = Intrin.bitSelect(eltType, numElts, mask.data, x.data, y.data);
    return result;
  }

  inline proc andNot(x: vector(?eltType, ?numElts), y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.andNot(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc andNot(x: vector(?eltType, ?numElts),
                     y: ?scalarType): x.type
  where isCoercible(scalarType, eltType) {
    var result: x.type;
    result.data = Intrin.andNot(eltType, numElts, x.data,
                                Intrin.splat(eltType, numElts, y));
    return result;
  }
  inline proc andNot(x: ?scalarType,
                     y: vector(?eltType, ?numElts)): y.type
  where isCoercible(scalarType, eltType) {
    var result: y.type;
    result.data = Intrin.andNot(eltType, numElts,
                                Intrin.splat(eltType, numElts, x), y.data);
    return result;
  }

  inline proc min(x: vector(?eltType, ?numElts),
                  y: x.type): x.type do {
    var result: x.type;
    result.data = Intrin.min(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc max(x: vector(?eltType, ?numElts),
                  y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.max(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc abs(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.abs(eltType, numElts, x.data);
    return result;
  }

  inline proc sin(x: vector(?eltType, ?numElts)): x.type {
    if !isRealType(eltType) then
      compilerError(
        "sin is only defined for real types, not " + eltType:string);

    import SLEEF.sleef;
    var result: x.type;
    result.data = sleef.sin(eltType, numElts, x.data);
    return result;
  }

  inline proc cos(x: vector(?eltType, ?numElts)): x.type {
    if !isRealType(eltType) then
      compilerError(
        "cos is only defined for real types, not " + eltType:string);

    import SLEEF.sleef;
    var result: x.type;
    result.data = sleef.cos(eltType, numElts, x.data);
    return result;
  }

  inline proc tan(x: vector(?eltType, ?numElts)): x.type {
    if !isRealType(eltType) then
      compilerError(
        "tan is only defined for real types, not " + eltType:string);

    import SLEEF.sleef;
    var result: x.type;
    result.data = sleef.tan(eltType, numElts, x.data);
    return result;
  }

  inline proc asin(x: vector(?eltType, ?numElts)): x.type {
    if !isRealType(eltType) then
      compilerError(
        "asin is only defined for real types, not " + eltType:string);

    import SLEEF.sleef;
    var result: x.type;
    result.data = sleef.asin(eltType, numElts, x.data);
    return result;
  }

  inline proc acos(x: vector(?eltType, ?numElts)): x.type {
    if !isRealType(eltType) then
      compilerError(
        "acos is only defined for real types, not " + eltType:string);

    import SLEEF.sleef;
    var result: x.type;
    result.data = sleef.acos(eltType, numElts, x.data);
    return result;
  }

  inline proc atan(x: vector(?eltType, ?numElts)): x.type {
    if !isRealType(eltType) then
      compilerError(
        "atan is only defined for real types, not " + eltType:string);

    import SLEEF.sleef;
    var result: x.type;
    result.data = sleef.atan(eltType, numElts, x.data);
    return result;
  }

  /*
    === START OPERATORS ===

    V + V  ;  V += V  ;  V + S  ;  V += S  ;  S + V
    V - V  ;  V -= V  ;  V - S  ;  V -= S  ;  S - V
    V * V  ;  V *= V  ;  V * S  ;  V *= S  ;  S * V
    V / V  ;  V /= V  ;  V / S  ;  V /= S  ;  S / V
    NEG V

    V & V  ;  V &= V  ;  V & S  ;  V &= S  ;  S & V
    V | V  ;  V |= V  ;  V | S  ; V |= S  ;  S | V
    V ^ V  ;  V ^= V  ;  V ^ S  ;  V ^= S  ;  S ^ V
    ~ V

    V == V  ;  V == S  ;  S == V
    V != V  ;  V != S  ;  S != V
    V < V  ;  V < S  ;  S < V
    V <= V  ;  V <= S  ;  S <= V
    V > V  ;  V > S  ;  S > V
    V >= V  ;  V >= S  ;  S >= V

    === END OPERATORS ===
  */
  include module Operators;
  public use Operators;

}
