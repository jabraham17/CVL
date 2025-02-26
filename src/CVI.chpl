module CVI {
  config param implementationWarnings = true;
  use CTypes only c_ptr, c_ptrConst,
                  c_ptrTo, c_ptrToConst,
                  c_addrOf, c_addrOfConst;
  import Intrin;

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
  @chplcheck.ignore("UnusedFormal")
  private proc isValidContainer(container: ?, type eltType) param: bool {
    return false;
  }

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

    /* VECTOR + VECTOR */
    inline operator+(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.add(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator+=(ref x: vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.add(eltType, numElts, x.data, y.data);

    /* VECTOR + SCALAR */
    inline operator+(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
      where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.add(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator+=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
      where isCoercible(scalarType, eltType) do
      x.data = Intrin.add(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR + VECTOR */
    inline operator+(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.add(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR - VECTOR */
    inline operator-(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.sub(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator-=(ref x: vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.sub(eltType, numElts, x.data, y.data);

    /* VECTOR - SCALAR */
    inline operator-(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.sub(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator-=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
    where isCoercible(scalarType, eltType) do
      x.data = Intrin.sub(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR - VECTOR */
    inline operator-(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.sub(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    inline operator-(x: vector(?eltType, ?numElts)): x.type {
      var result: x.type;
      result.data = Intrin.neg(eltType, numElts, x.data);
      return result;
    }

    /* VECTOR * VECTOR */
    inline operator*(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.mul(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator*=(ref x:vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.mul(eltType, numElts, x.data, y.data);

    /* VECTOR * SCALAR */
    inline operator*(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.mul(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator*=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
    where isCoercible(scalarType, eltType) do
      x.data = Intrin.mul(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR * VECTOR */
    inline operator*(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.mul(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR / VECTOR */
    inline operator/(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.div(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator/=(ref x: vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.div(eltType, numElts, x.data, y.data);

    /* VECTOR / SCALAR */
    inline operator/(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.div(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator/=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
    where isCoercible(scalarType, eltType) do
      x.data = Intrin.div(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));

    /* SCALAR / VECTOR */
    inline operator/(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.div(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }


    /* VECTOR & VECTOR */
    inline operator&(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.and(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator&=(ref x: vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.and(eltType, numElts, x.data, y.data);
    /* VECTOR & SCALAR */
    inline operator&(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.and(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator&=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
    where isCoercible(scalarType, eltType) do
      x.data = Intrin.and(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
    /* SCALAR & VECTOR */
    inline operator&(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.and(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR | VECTOR */
    inline operator|(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.or(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator|=(ref x: vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.or(eltType, numElts, x.data, y.data);
    /* VECTOR | SCALAR */
    inline operator|(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.or(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator|=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
    where isCoercible(scalarType, eltType) do
      x.data = Intrin.or(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
    /* SCALAR | VECTOR */
    inline operator|(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.or(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* VECTOR ^ VECTOR */
    inline operator^(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.xor(eltType, numElts, x.data, y.data);
      return result;
    }
    inline operator^=(ref x: vector(?eltType, ?numElts), y: x.type) do
      x.data = Intrin.xor(eltType, numElts, x.data, y.data);
    /* VECTOR ^ SCALAR */
    inline operator^(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      var result: x.type;
      result.data = Intrin.xor(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
      return result;
    }
    inline operator^=(ref x: vector(?eltType, ?numElts), y: ?scalarType)
    where isCoercible(scalarType, eltType) do
      x.data = Intrin.xor(eltType, numElts, x.data,
                      Intrin.splat(eltType, numElts, y));
    /* SCALAR ^ VECTOR */
    inline operator^(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
    where isCoercible(scalarType, eltType) {
      var result: y.type;
      result.data = Intrin.xor(eltType, numElts,
                      Intrin.splat(eltType, numElts, x), y.data);
      return result;
    }

    /* ~VECTOR */
    inline operator~(x: vector(?eltType, ?numElts)): x.type {
      var result: x.type;
      result.data = Intrin.not(eltType, numElts, x.data);
      return result;
    }

    // TODO shifts


    /* VECTOR == VECTOR */
    inline operator==(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.cmpEq(eltType, numElts, x.data, y.data);
      return result;
    }
    /* VECTOR == SCALAR */
    inline operator==(x: vector(?eltType, ?), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      return x == (y:x.type);
    }
    /* SCALAR == VECTOR */
    inline operator==(x: ?scalarType, y: vector(?eltType, ?)): y.type
    where isCoercible(scalarType, eltType) {
      return (x:y.type) == y;
    }
    /* VECTOR != VECTOR */
    inline operator!=(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.cmpNe(eltType, numElts, x.data, y.data);
      return result;
    }
    /* VECTOR != SCALAR */
    inline operator!=(x: vector(?eltType, ?), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      return x != (y:x.type);
    }
    /* SCALAR != VECTOR */
    inline operator!=(x: ?scalarType, y: vector(?eltType, ?)): y.type
    where isCoercible(scalarType, eltType) {
      return (x:y.type) != y;
    }
    /* VECTOR < VECTOR */
    inline operator<(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.cmpLt(eltType, numElts, x.data, y.data);
      return result;
    }
    /* VECTOR < SCALAR */
    inline operator<(x: vector(?eltType, ?), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      return x < (y:x.type);
    }
    /* SCALAR < VECTOR */
    inline operator<(x: ?scalarType, y: vector(?eltType, ?)): y.type
    where isCoercible(scalarType, eltType) {
      return (x:y.type) < y;
    }
    /* VECTOR <= VECTOR */
    inline operator<=(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.cmpLe(eltType, numElts, x.data, y.data);
      return result;
    }
    /* VECTOR <= SCALAR */
    inline operator<=(x: vector(?eltType, ?), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      return x <= (y:x.type);
    }
    /* SCALAR <= VECTOR */
    inline operator<=(x: ?scalarType, y: vector(?eltType, ?)): y.type
    where isCoercible(scalarType, eltType) {
      return (x:y.type) <= y;
    }
    /* VECTOR > VECTOR */
    inline operator>(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.cmpGt(eltType, numElts, x.data, y.data);
      return result;
    }
    /* VECTOR > SCALAR */
    inline operator>(x: vector(?eltType, ?), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      return x > (y:x.type);
    }
    /* SCALAR > VECTOR */
    inline operator>(x: ?scalarType, y: vector(?eltType, ?)): y.type
    where isCoercible(scalarType, eltType) {
      return (x:y.type) > y;
    }
    /* VECTOR >= VECTOR */
    inline operator>=(x: vector(?eltType, ?numElts), y: x.type): x.type {
      var result: x.type;
      result.data = Intrin.cmpGe(eltType, numElts, x.data, y.data);
      return result;
    }
    /* VECTOR >= SCALAR */
    inline operator>=(x: vector(?eltType, ?), y: ?scalarType): x.type
    where isCoercible(scalarType, eltType) {
      return x >= (y:x.type);
    }
    /* SCALAR >= VECTOR */
    inline operator>=(x: ?scalarType, y: vector(?eltType, ?)): y.type
    where isCoercible(scalarType, eltType) {
      return (x:y.type) >= y;
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
    where isValidContainer(tup, eltType) {
      if checkBounds && boundsChecking {
        if idx+numElts-1 >= tup.size {
          halt("out of bounds load");
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
    where isValidContainer(tup, eltType) {
      if checkBounds && boundsChecking {
        if idx+numElts-1 >= tup.size {
          halt("out of bounds load");
        }
      }
      const ptr = c_addrOfConst(tup(idx));
      return ptr;
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
    inline proc ref load(arr: [] eltType,
                         idx: integral = 0,
                         param aligned: bool = false)
    where isValidContainer(arr, eltType) do
      load(this.type._computeAddressConst(arr, idx), idx=0, aligned=aligned);

    inline proc ref load(tup, idx: integral = 0, param aligned: bool = false)
    where isValidContainer(tup, eltType) && isHomogeneousTuple(tup) do
      load(this.type._computeAddressConst(tup, idx), idx=0, aligned=aligned);

    inline proc store(ptr: c_ptr(eltType),
                      idx: integral = 0,
                      param aligned: bool = false) {
      var ptr_ = ptr + idx;
      if aligned then
        Intrin.storeAligned(eltType, numElts, ptr_, data);
      else
        Intrin.storeUnaligned(eltType, numElts, ptr_, data);
    }
    inline proc store(ref arr: [] eltType,
                          idx: integral = 0,
                          param aligned: bool = false)
    where isValidContainer(arr, eltType) do
      store(this.type._computeAddress(arr, idx), idx=0, aligned=aligned);

    inline proc store(ref tup, idx: integral = 0, param aligned: bool = false)
    where isValidContainer(tup, eltType) && isHomogeneousTuple(tup) {
      if boundsChecking {
        if idx+numElts-1 >= tup.size {
          halt("out of bounds store");
        }
      }
      store(this.type._computeAddress(tup, idx), idx=0, aligned=aligned);
    }
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
                                 arr: [] eltType,
                                 idx: integral = 0)
    where this.type.isValidLoadMask(mask.type) &&
          isValidContainer(arr, eltType)
      do loadMasked(mask,
          this.type._computeAddressConst(arr, idx, checkBounds=false), idx=0);
    /* loadMasked is not bounds checked */
    inline proc ref loadMasked(mask: vector(?),
                                 tup,
                                 idx: integral = 0)
    where this.type.isValidLoadMask(mask.type) &&
          isValidContainer(tup, eltType) &&
          isHomogeneousTuple(tup)
      do loadMasked(mask,
          this.type._computeAddressConst(tup, idx, checkBounds=false), idx=0);

    // TODO: store mask

    // TODO: for simplicity, gather requires an index vector of type int(32)
    @chpldoc.nodoc
    proc type indexVectorType type {
      type idxEltType = int(32);
      return vector(idxEltType, ?);
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





    // TODO: transmute (bitcast)
    // TODO: typecast



    inline proc type indices(rng: range(?)): range(?) do
      return rng by numElts;
    inline proc type indices(dom: domain(?)): domain(?) do
      return dom by numElts;
    inline proc type indices(container: ?): range(?)
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
        writeln("i: ", i);
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

  /* a transparent record that iterators can yield,
     takes in modifications to the yielded vector and then writes them back out
     to the raw address when this goes out of scope*/
  record vectorRef: writeSerializable {
    type vectorType;
    param aligned: bool;
    var vec: vectorType;
    var address: c_ptr(vectorType.eltType);
    forwarding vec;

    inline proc init(type vectorType, param aligned: bool = false) {
      this.vectorType = vectorType;
      this.aligned = aligned;
    }
    inline proc init(vec: ?vecType,
                     address: c_ptr(vecType.eltType),
                     param aligned: bool = false) {
      this.vectorType = vecType;
      this.aligned = aligned;
      this.vec = vec;
      this.address = address;
    }
    inline proc init(type vectorType,
                     address: c_ptr(vectorType.eltType),
                     param aligned: bool = false) {
      this.vectorType = vectorType;
      this.vec = vectorType.load(address, 0, aligned=aligned);
      this.address = address;
    }
    inline proc deinit() {
      this.commitChanges();
    }
    inline proc commitChanges() {
      this.vec.store(this.address, 0, aligned=this.aligned);
    }

    @chplcheck.ignore("UnusedFormal")
    proc serialize(writer, ref serializer) throws {
      writer.write(vec);
    }

    // TODO: handle the free functions like min and max

    // TODO: handle all the rest of the operators

    //
    // Forwarding doesn't work for operators, so we need to manually implement
    //
    inline operator+(lhs: ?lhsType,
                     rhs: ?rhsType): returnTypeForOpTypes(lhsType, rhsType)
    where returnTypeForOpTypes(lhsType, rhsType) != nothing do
      return getValue(lhs) + getValue(rhs);
    inline operator+=(ref lhs: vectorRef(?), rhs: ?rhsType)
      where validEqOperatorTypes(lhs.type, rhsType) do
      getRef(lhs) += getValue(rhs);

    inline operator-(lhs: ?lhsType,
                     rhs: ?rhsType): returnTypeForOpTypes(lhsType, rhsType)
    where returnTypeForOpTypes(lhsType, rhsType) != nothing do
      return getValue(lhs) + getValue(rhs);
    inline operator-=(ref lhs: vectorRef(?), rhs: ?rhsType)
      where validEqOperatorTypes(lhs.type, rhsType) do
      getRef(lhs) -= getValue(rhs);

    inline operator*(lhs: ?lhsType,
                     rhs: ?rhsType): returnTypeForOpTypes(lhsType, rhsType)
    where returnTypeForOpTypes(lhsType, rhsType) != nothing do
      return getValue(lhs) * getValue(rhs);
    inline operator*=(ref lhs: vectorRef(?), rhs: ?rhsType)
    where validEqOperatorTypes(lhs.type, rhsType) do
      getRef(lhs) *= getValue(rhs);

    // inline operator/(lhs: ?lhsType,
    //                  rhs: ?rhsType): returnTypeForOpTypes(lhsType, rhsType)
    //   where returnTypeForOpTypes(lhsType, rhsType) != nothing do
    //   return getValue(lhs) / getValue(rhs);
    // inline operator/=(ref lhs: vectorRef(?), rhs: ?rhsType)
    //   where validEqOperatorTypes(lhs.type, rhsType) do
    //   getRef(lhs) /= getValue(rhs);

    // more strict checking is technically needed to do assignment
    // this is done by the vector type already
    // TODO: we also need init= from vector, init= from vectorRef, and
    //  init= from tuple
    //
    // operator=(ref lhs: ?lhsType, rhs: ?rhsType)
    //   where isVectorType(lhsType) &&
    //        (isVectorType(rhsType) || isHomogeneousTupleType(rhsType)) do
    //   getRef(lhs) = getValue(rhs);
  }
  private proc isVectorType(type T) param: bool do
    return isSubtype(T, vector) || isSubtype(T, vectorRef);
  private proc getEltType(type T) type where isSubtype(T, vector) do
    return T.eltType;
  private proc getEltType(type T) type where isSubtype(T, vectorRef) do
    return T.vectorType.eltType;
  private proc getNumElts(type T) param: int where isSubtype(T, vector) do
    return T.numElts;
  private proc getNumElts(type T) param: int where isSubtype(T, vectorRef) do
    return T.vectorType.numElts;

  private inline proc getValue(x: vector(?)): x.type do return x;
  private inline proc getValue(x: vectorRef(?)): x.vectorType do return x.vec;
  private inline proc getValue(x: ?t): t do return x;
  private inline proc getRef(ref x: vector(?)) ref: x.type do return x;
  private inline proc getRef(ref x: vectorRef(?)) ref: x.vectorType do
    return x.vec;
  private inline proc getRef(ref x: ?t) ref: t do return x;

  private proc returnTypeForOpTypes(type lhsType, type rhsType) type {
    // one of the types can be scalar, but not both
    if !isVectorType(lhsType) && isVectorType(rhsType) {
      return vector(getEltType(rhsType), getNumElts(rhsType));
    } else if isVectorType(lhsType) && !isVectorType(rhsType) {
      return vector(getEltType(lhsType), getNumElts(lhsType));
    } else if isVectorType(lhsType) && isVectorType(rhsType) {
      // must be same eltType/numElt
      if getEltType(lhsType) == getEltType(rhsType) &&
         getNumElts(lhsType) == getNumElts(rhsType) {
        return vector(getEltType(lhsType), getNumElts(lhsType));
      } else return nothing;
    } else return nothing;
  }
  // must be a valid operator and the lhs must be a vector
  proc validEqOperatorTypes(type lhsType, type rhsType) param: bool {
    if returnTypeForOpTypes(lhsType, rhsType) == nothing {
      return false;
    }
    if !isVectorType(lhsType) {
      return false;
    }
    return true;
  }

}
