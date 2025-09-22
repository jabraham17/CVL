use CVL;
use UnitTest;
use TestHelpers;
import Math;

// must be a length divisible by 2, 4, and 8
const testData = [i in 1..#24] i / 24.0;

proc testEqual(vec1, vec2, epsilon=1e-6) throws {
  for param i in 0..#vec1.numElts {
    if abs(vec1(i) - vec2(i)) > epsilon {
      throw new TestError.AssertionError(
        "vec1 and vec2 differ at index %i: %r vs %r".format(
        i, vec1(i), vec2(i)));
    }
  }
}

proc testSerial(vec, param func: string) {
  var newVec: vec.type;
  for param i in 0..#vec.numElts {
    var temp = vec(i);

    select func {
      when "sin" do temp = Math.sin(temp);
      when "cos" do temp = Math.cos(temp);
      when "tan" do temp = Math.tan(temp);
      when "asin" do temp = Math.asin(temp);
      when "acos" do temp = Math.acos(temp);
      when "atan" do temp = Math.atan(temp);
      otherwise compilerError("Unknown function: ", func);
    }

    newVec.set(i, temp);
  }
  return newVec;
}

proc sinTestType(type eltType, param numElts: int) throws {
  const data = testData:eltType;
  type vectorType = vector(eltType, numElts);
  for a in vectorType.vectors(data) {
    var r = sin(a);
    var r2 = testSerial(a, "sin");
    testEqual(r, r2);
  }
}

proc cosTestType(type eltType, param numElts: int) throws {
  const data = testData:eltType;
  type vectorType = vector(eltType, numElts);
  for a in vectorType.vectors(data) {
    var r = cos(a);
    var r2 = testSerial(a, "cos");
    testEqual(r, r2);
  }
}

proc tanTestType(type eltType, param numElts: int) throws {
  const data = testData:eltType;
  type vectorType = vector(eltType, numElts);
  for a in vectorType.vectors(data) {
    var r = tan(a);
    var r2 = testSerial(a, "tan");
    testEqual(r, r2);
  }
}

proc asinTestType(type eltType, param numElts: int) throws {
  const data = testData:eltType;
  type vectorType = vector(eltType, numElts);
  for a in vectorType.vectors(data) {
    var r = asin(a);
    var r2 = testSerial(a, "asin");
    testEqual(r, r2);
  }
}

proc acosTestType(type eltType, param numElts: int) throws {
  const data = testData:eltType;
  type vectorType = vector(eltType, numElts);
  for a in vectorType.vectors(data) {
    var r = acos(a);
    var r2 = testSerial(a, "acos");
    testEqual(r, r2);
  }
}

proc atanTestType(type eltType, param numElts: int) throws {
  const data = testData:eltType;
  type vectorType = vector(eltType, numElts);
  for a in vectorType.vectors(data) {
    var r = atan(a);
    var r2 = testSerial(a, "atan");
    testEqual(r, r2);
  }
}

@chplcheck.ignore("UnusedFormal")
proc sinTest(test: borrowed Test) throws {
  sinTestType(real(32), 4);
  sinTestType(real(64), 2);
  sinTestType(real(32), 8);
  sinTestType(real(64), 4);
}
@chplcheck.ignore("UnusedFormal")
proc cosTest(test: borrowed Test) throws {
  cosTestType(real(32), 4);
  cosTestType(real(64), 2);
  cosTestType(real(32), 8);
  cosTestType(real(64), 4);
}
@chplcheck.ignore("UnusedFormal")
proc tanTest(test: borrowed Test) throws {
  tanTestType(real(32), 4);
  tanTestType(real(64), 2);
  tanTestType(real(32), 8);
  tanTestType(real(64), 4);
}
@chplcheck.ignore("UnusedFormal")
proc asinTest(test: borrowed Test) throws {
  asinTestType(real(32), 4);
  asinTestType(real(64), 2);
  asinTestType(real(32), 8);
  asinTestType(real(64), 4);
}
@chplcheck.ignore("UnusedFormal")
proc acosTest(test: borrowed Test) throws {
  acosTestType(real(32), 4);
  acosTestType(real(64), 2);
  acosTestType(real(32), 8);
  acosTestType(real(64), 4);
}
@chplcheck.ignore("UnusedFormal")
proc atanTest(test: borrowed Test) throws {
  atanTestType(real(32), 4);
  atanTestType(real(64), 2);
  atanTestType(real(32), 8);
  atanTestType(real(64), 4);
}


UnitTest.main();
