use UnitTest;
use TestHelpers;
use CVL;

proc Test.testEqual(vec1, vec2, epsilon=1e-6) throws {
  for param i in 0..#vec1.numElts {
    if abs(vec1(i) - vec2(i)) > epsilon {
      throw new TestError.AssertionError(
        "vec1 and vec2 differ at index %i: %? vs %?".format(
        i, vec1(i), vec2(i)));
    }
  }
}


const testData = [i in 1..#64] i;

proc testTypeCastInner(test: borrowed,
                       type fromType, type toType) throws {
  for j in fromType.indices(testData.domain) {
    var fromTup: fromType.toTuple();
    var toTup: toType.toTuple();
    for param i in 0..#fromTup.size {
      fromTup[i] = testData[j + i]:fromType.eltType;
      toTup[i] = fromTup[i]:toType.eltType;
    }

    var fromVec = new fromType(fromTup);
    var toVec = fromVec.convert(toType);

    test.testEqual(toVec, toTup);

    var backVec = toVec.convert(fromType);
    test.testEqual(backVec, fromTup);
    test.testEqual(backVec, fromVec);
  }
}

proc transmute(x, type to): to {
  import CTypes.{c_ptrTo, c_size_t};
  import OS.POSIX.memcpy;
  var src = x,
      dst: to;
  memcpy(c_ptrTo(dst), c_ptrTo(src), numBytes(to).safeCast(c_size_t));
  return dst;
}

proc testReinterpretCastInner(test: borrowed,
                              type fromType, type toType) throws {
  for j in fromType.indices(testData.domain) {

    var fromTup: fromType.toTuple();
    var toTup: toType.toTuple();
    for param i in 0..#fromTup.size {
      fromTup[i] = testData[j + i]:fromType.eltType;
      toTup[i] = transmute(fromTup[i], toType.eltType);
    }

    var fromVec = new fromType(fromTup);
    var toVec = fromVec.transmute(toType);

    test.testEqual(toVec, toTup);


    var backVec = toVec.transmute(fromType);
    test.testEqual(backVec, fromTup);
    test.testEqual(backVec, fromVec);
  }
}

proc testTypeCast(test: borrowed Test) throws {
  testTypeCastInner(test, vector(int(32), 4), vector(real(32), 4));
  testTypeCastInner(test, vector(real(32), 4), vector(int(32), 4));
  testTypeCastInner(test, vector(int(32), 8), vector(real(32), 8));
  testTypeCastInner(test, vector(real(32), 8), vector(int(32), 8));


  testTypeCastInner(test, vector(int(64), 2), vector(real(64), 2));
  testTypeCastInner(test, vector(real(64), 2), vector(int(64), 2));
  testTypeCastInner(test, vector(int(64), 4), vector(real(64), 4));
  testTypeCastInner(test, vector(real(64), 4), vector(int(64), 4));
}


proc testReinterpretCast(test: borrowed Test) throws {
  testReinterpretCastInner(test, vector(int(8), 16), vector(int(8), 16));
  testReinterpretCastInner(test, vector(int(8), 32), vector(int(8), 32));

  testReinterpretCastInner(test, vector(int(16), 8), vector(int(16), 8));
  testReinterpretCastInner(test, vector(int(16), 16), vector(int(16), 16));

  testReinterpretCastInner(test, vector(int(32), 4), vector(int(32), 4));
  testReinterpretCastInner(test, vector(int(32), 4), vector(real(32), 4));
  testReinterpretCastInner(test, vector(real(32), 4), vector(int(32), 4));
  testReinterpretCastInner(test, vector(real(32), 4), vector(real(32), 4));
  testReinterpretCastInner(test, vector(int(32), 8), vector(int(32), 8));
  testReinterpretCastInner(test, vector(int(32), 8), vector(real(32), 8));
  testReinterpretCastInner(test, vector(real(32), 8), vector(int(32), 8));
  testReinterpretCastInner(test, vector(real(32), 8), vector(real(32), 8));

  testReinterpretCastInner(test, vector(int(64), 2), vector(int(64), 2));
  testReinterpretCastInner(test, vector(int(64), 2), vector(real(64), 2));
  testReinterpretCastInner(test, vector(real(64), 2), vector(int(64), 2));
  testReinterpretCastInner(test, vector(real(64), 2), vector(real(64), 2));
  testReinterpretCastInner(test, vector(int(64), 4), vector(int(64), 4));
  testReinterpretCastInner(test, vector(int(64), 4), vector(real(64), 4));
  testReinterpretCastInner(test, vector(real(64), 4), vector(int(64), 4));
  testReinterpretCastInner(test, vector(real(64), 4), vector(real(64), 4));

}

UnitTest.main();
