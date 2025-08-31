module SLEEF {
  config param useSLEEF = false;
  config param SLEEF_INSTALL = "../third-party/sleef/sleef-install";
  if useSLEEF {
    require SLEEF_INSTALL + "/include/sleef.h";
    require SLEEF_INSTALL + "/lib/libsleef.a";
  }

  use Intrin only implType, vectorType;
  use Arch only isX8664, isArm64;


  inline proc doSimpleOp(
    type impl, param name: string, x: impl.vecType
  ): impl.vecType {
    if !useSLEEF then
      compilerError(
        "SLEEF is not enabled. Use `-suseSLEEF=true` to enable it.");

    param suffix = if impl.laneType == real(32) then "f" else "d";
    proc getNumLanes() param : int {
      param numLanes = impl.vecType.numBits / numBits(impl.laneType);
      if isArm64() {
        import IntrinArm64_256.vecPair;
        if isSubtype(impl.vecType, vecPair) then return numLanes / 2;
      }
      return numLanes;
    }
    param funcName = "Sleef_" + name + suffix + getNumLanes():string + "_u10";

    if isArm64() {
      import IntrinArm64_256.vecPair;
      if isSubtype(impl.vecType, vecPair) {
        pragma "fn synchronization free"
        extern funcName proc func(x: impl.vecType.vt): impl.vecType.vt;
        return new vecPair(func(x.lo), func(x.hi));
      }
    }
    pragma "fn synchronization free"
    extern funcName proc func(x: impl.vecType): impl.vecType;
    return func(x);
  }

  @lint.typeOnly
  record sleef {
    inline proc type sin(type e, param n: int, x: vectorType(e, n)): x.type do
      return doSimpleOp(implType(e, n), "sin", x);
    inline proc type cos(type e, param n: int, x: vectorType(e, n)): x.type do
      return doSimpleOp(implType(e, n), "cos", x);
    inline proc type tan(type e, param n: int, x: vectorType(e, n)): x.type do
      return doSimpleOp(implType(e, n), "tan", x);
    inline proc type asin(type e, param n: int, x: vectorType(e, n)): x.type do
      return doSimpleOp(implType(e, n), "asin", x);
    inline proc type acos(type e, param n: int, x: vectorType(e, n)): x.type do
      return doSimpleOp(implType(e, n), "acos", x);
    inline proc type atan(type e, param n: int, x: vectorType(e, n)): x.type do
      return doSimpleOp(implType(e, n), "atan", x);
  }
}
