module SIMD {
  use Types;
  use IO;
  use CTypes;
  import Intrin;

  record vector: writeSerializable {
    type eltType;
    param numElts: int;
    var data: Intrin.vectorType(eltType, numElts);

    /* type init*/
    proc init(type eltType, param numElts: int) {
      this.eltType = eltType;
    this.numElts = numElts;
      this.data = Intrin.splat(eltType, numElts, 0:eltType);
    }
    /* init to single value */
    proc init(type eltType, param numElts: int, value: eltType) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = Intrin.splat(eltType, numElts, value);
    }
    /* init to single value, infer type */
    proc init(param numElts: int, value: ?eltType) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = Intrin.splat(eltType, numElts, value);
    }

    //
    // init from other vector
    //
    proc init(type eltType, param numElts: int, value: vector(eltType, numElts)) {
      this.eltType = eltType;
      this.numElts = numElts;
      this.data = value.data;
    }
    proc init=(value: ?t) where isSubtype(t, vector) {
      this.eltType = value.eltType;
      this.numElts = value.numElts;
      this.data = value.data;
    }
    inline operator=(ref lhs: ?t, rhs: t) where isSubtype(t, vector) {
      lhs.data = rhs.data;
    }

    //
    // init from tuple
    //
    proc init(values) where isHomogeneousTupleType(values.type) {
      this.eltType = values(0).type;
      this.numElts = values.size;
      this.data = Intrin.set(this.eltType, this.numElts, values);
    }
    proc init=(values) where isHomogeneousTupleType(values.type) {
      this.eltType = values(0).type;
      this.numElts = values.size;
      this.data = Intrin.set(this.eltType, this.numElts, values);
    }
    inline operator=(ref lhs, rhs) where isSubtype(lhs.type, vector) &&
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
    inline operator:(x: ?t, type tupType)
      where isSubtype(t, vector) &&
            isHomogeneousTupleType(tupType) &&
            isCoercible(t.eltType, tupType(0)) &&
            tupType.size == t.numElts {
      type resEltType = tupType(0);
      var result: tupType;
      for param i in 0..#t.numElts {
        result(i) = x[i]:resEltType;
      }
      return result;
    }

    /* VECTOR + VECTOR */
    inline operator+(x: ?t, y: t) where isSubtype(t, vector) {
      var result: t;
      result.data = Intrin.add(t.eltType, t.numElts, x.data, y.data);
      return result;
    }
    inline operator+=(ref x: ?t, y: t) where isSubtype(t, vector) do
      x.data = Intrin.add(t.eltType, t.numElts, x.data, y.data);

    /* VECTOR + SCALAR */
    inline operator+(x: vector(?eltType, ?numElts), y: eltType) {
      var result: x.type;
      result.data = Intrin.add(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator+=(ref x: vector(?eltType, ?numElts), y: eltType) do
      x.data = Intrin.add(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR + VECTOR */
    inline operator+(x: ?eltType, y: vector(eltType, ?numElts)) {
      var result: y.type;
      result.data = Intrin.add(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR - VECTOR */
    inline operator-(x: ?t, y: t) where isSubtype(t, vector) {
      var result: t;
      result.data = Intrin.sub(t.eltType, t.numElts, x.data, y.data);
      return result;
    }
    inline operator-=(ref x: ?t, y: t) where isSubtype(t, vector) do
      x.data = Intrin.sub(t.eltType, t.numElts, x.data, y.data);

    /* VECTOR - SCALAR */
    inline operator-(x: vector(?eltType, ?numElts), y: eltType) {
      var result: x.type;
      result.data = Intrin.sub(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator-=(ref x: vector(?eltType, ?numElts), y: eltType) do
      x.data = Intrin.sub(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR - VECTOR */
    inline operator-(x: ?eltType, y: vector(eltType, ?numElts)) {
      var result: y.type;
      result.data = Intrin.sub(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR * VECTOR */
    inline operator*(x: ?t, y: t) where isSubtype(t, vector) {
      var result: t;
      result.data = Intrin.mul(t.eltType, t.numElts, x.data, y.data);
      return result;
    }
    inline operator*=(ref x: ?t, y: t) where isSubtype(t, vector) do
      x.data = Intrin.mul(t.eltType, t.numElts, x.data, y.data);

    /* VECTOR * SCALAR */
    inline operator*(x: vector(?eltType, ?numElts), y: eltType) {
      var result: x.type;
      result.data = Intrin.mul(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator*=(ref x: vector(?eltType, ?numElts), y: eltType) do
      x.data = Intrin.mul(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR * VECTOR */
    inline operator*(x: ?eltType, y: vector(eltType, ?numElts)) {
      var result: y.type;
      result.data = Intrin.mul(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR / VECTOR */
    inline operator/(x: ?t, y: t) where isSubtype(t, vector) {
      var result: t;
      result.data = Intrin.div(t.eltType, t.numElts, x.data, y.data);
      return result;
    }
    inline operator/=(ref x: ?t, y: t) where isSubtype(t, vector) do
      x.data = Intrin.div(t.eltType, t.numElts, x.data, y.data);

    /* VECTOR / SCALAR */
    inline operator/(x: vector(?eltType, ?numElts), y: eltType) {
      var result: x.type;
      result.data = Intrin.div(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator/=(ref x: vector(?eltType, ?numElts), y: eltType) do
      x.data = Intrin.div(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR / VECTOR */
    inline operator/(x: ?eltType, y: vector(eltType, ?numElts)) {
      var result: y.type;
      result.data = Intrin.div(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    inline proc ref set(value) where isCoercible(value.type, eltType) {
      data = Intrin.splat(eltType, numElts, value:eltType);
    }
    inline proc ref set(values) where isHomogeneousTupleType(values.type) &&
                                      isCoercible(values(0).type, eltType) &&
                                      values.size == numElts {
      var values_: numElts*eltType;
      for param i in 0..<numElts do
        values_[i] = values[i]:eltType;
      data = Intrin.set(eltType, numElts, values_);
    }
    inline proc ref set(values...) {
      set(values);
    }
    inline proc ref set(param idx: int, value)
      where isCoercible(value.type, eltType) {
      data = Intrin.insert(eltType, numElts, data, value:eltType, idx);
    }

    inline proc this(param idx: int) do
      return Intrin.extract(eltType, numElts, data, idx);
    iter these() {
      for param i in 0..#numElts {
        yield this[i];
      }
    }

    inline proc ref load(ptr: c_ptrConst(eltType),
                         idx: int = 0,
                         param aligned: bool = false) {
      var ptr_ = ptr + idx;
      if aligned then
        data = Intrin.loadAligned(eltType, numElts, ptr_);
      else
        data = Intrin.loadUnaligned(eltType, numElts, ptr_);
    }
    inline proc ref load(arr: [] eltType,
                         idx: int = 0,
                         param aligned: bool = false)
      where arr.rank == 1 && arr.isRectangular() && arr._value.isDefaultRectangular() {
      const ptr = c_addrOfConst(arr[idx]);
      load(ptr, idx=0, aligned=aligned);
    }
    inline proc ref load(tup, idx: int = 0, param aligned: bool = false)
      where isHomogeneousTuple(tup) && tup(0).type == eltType {
      var ptr_ = c_addrOfConst(tup(idx));
      if aligned then
        data = Intrin.loadAligned(eltType, numElts, ptr_);
      else
        data = Intrin.loadUnaligned(eltType, numElts, ptr_);
    }
    inline proc store(ptr: c_ptr(eltType),
                      idx: int = 0,
                      param aligned: bool = false) {
      var ptr_ = ptr + idx;
      if aligned then
        Intrin.storeAligned(eltType, numElts, ptr_, data);
      else
        Intrin.storeUnaligned(eltType, numElts, ptr_, data);
    }
    inline proc ref store(ref arr: [] eltType,
                          idx: int = 0,
                          param aligned: bool = false)
      where arr.rank == 1 && arr.isRectangular() && arr._value.isDefaultRectangular() {
      var ptr = c_addrOf(arr[idx]);
      store(ptr, idx=0, aligned=aligned);
    }
    inline proc store(ref tup, idx: int = 0, param aligned: bool = false)
      where isHomogeneousTuple(tup) && tup(0).type == eltType {
      var ptr_ = c_addrOf(tup(idx));
      if aligned then
        Intrin.storeAligned(eltType, numElts, ptr_, this.data);
      else
        Intrin.storeUnaligned(eltType, numElts, ptr_, this.data);
    }
    inline proc type load(container,
                          idx: int = 0,
                          param aligned: bool = false): this {
      var result: this;
      result.load(container, idx=idx, aligned=aligned);
      return result;
    }

    // compares?
    // bitmath?


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
  inline proc interleaveLower(x: vector(?eltType, ?numElts), y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.interleaveLower(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc interleaveUpper(x: vector(?eltType, ?numElts), y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.interleaveUpper(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc deinterleaveLower(x: vector(?eltType, ?numElts), y: x.type): x.type {
    var result: x.type;
    result.data = Intrin.deinterleaveLower(eltType, numElts, x.data, y.data);
    return result;
  }
  inline proc deinterleaveUpper(x: vector(?eltType, ?numElts), y: x.type): x.type {
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


  proc sqrt(x: vector(?eltType, ?numElts)): x.type {
    var result: x.type;
    result.data = Intrin.sqrt(eltType, numElts, x.data);
    return result;
  }
  proc rsqrt(x: vector(?eltType, ?numElts)): x.type {
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

}
