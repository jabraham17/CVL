module VectorRef {

  use Vector only vector;

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
    where validTypesForOp(lhsType, rhsType) do
      return getValue(lhs) + getValue(rhs);
    inline operator+=(ref lhs: vectorRef(?), rhs: ?rhsType)
      where validEqOperatorTypes(lhs.type, rhsType) do
      getRef(lhs) += getValue(rhs);

    inline operator-(lhs: ?lhsType,
                     rhs: ?rhsType): returnTypeForOpTypes(lhsType, rhsType)
    where validTypesForOp(lhsType, rhsType) do
      return getValue(lhs) + getValue(rhs);
    inline operator-=(ref lhs: vectorRef(?), rhs: ?rhsType)
      where validEqOperatorTypes(lhs.type, rhsType) do
      getRef(lhs) -= getValue(rhs);

    inline operator*(lhs: ?lhsType,
                     rhs: ?rhsType): returnTypeForOpTypes(lhsType, rhsType)
    where validTypesForOp(lhsType, rhsType) do
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

  private proc validTypesForOp(type lhsType, type rhsType) param: bool {
    if returnTypeForOpTypes(lhsType, rhsType) == nothing {
      return false;
    }
    // both types cannot be 'vector', because that's already defined elsewhere
    if isSubtype(lhsType, vector) && isSubtype(rhsType, vector) {
      return false;
    }
    // one of the types must be a vectorRef
    if !isSubtype(lhsType, vectorRef) && !isSubtype(rhsType, vectorRef) {
      return false;
    }
    return true;
  }

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
