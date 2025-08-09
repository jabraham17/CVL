use CVL;
use UnitTest;
use TestHelpers;
import Math;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}

// must be a length divisible by 2, 4, and 8
const testData = [
  0.0, 0.5, 1.0, 1.5, 2.0,
  Math.pi, Math.pi/2, Math.pi/4, Math.pi/3, Math.pi/6,
  2*Math.pi, 3*Math.pi/2, 3*Math.pi/4, 5*Math.pi/4, 7*Math.pi/4,
  4*Math.pi, 5*Math.pi/2, 11*Math.pi/6, 13*Math.pi/6, 15*Math.pi/6,
  -0.0, -0.5, -1.0, -1.5
];

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

// use a vecSerializer with a higher precision than the default
use PrecisionSerializer only precisionSerializer;
vecSerializer = new precisionSerializer(precision=8,
                                        padding=13);

proc trigTest(of, type eltType, param numElts: int) {
  of.writeln("trig functions for ", eltType:string, " ", numElts);

  const data = testData:eltType;
  of.withSerializer(vecSerializer).writeln(" data: ", data);

  type vectorType = vector(eltType, numElts);

  for a in vectorType.vectors(data) {
    var r = sin(a);
    of.withSerializer(vecSerializer).writeln("  sin(a)       : ", r);
    var r2 = testSerial(a, "sin");
    of.withSerializer(vecSerializer).writeln("  sin(a) serial: ", r2);
  }

  for a in vectorType.vectors(data) {
    var r = cos(a);
    of.withSerializer(vecSerializer).writeln("  cos(a)       : ", r);
    var r2 = testSerial(a, "cos");
    of.withSerializer(vecSerializer).writeln("  cos(a) serial: ", r2);
  }

  for a in vectorType.vectors(data) {
    var r = tan(a);
    of.withSerializer(vecSerializer).writeln("  tan(a)       : ", r);
    var r2 = testSerial(a, "tan");
    of.withSerializer(vecSerializer).writeln("  tan(a) serial: ", r2);
  }

  for a in vectorType.vectors(data) {
    var r = asin(a);
    of.withSerializer(vecSerializer).writeln("  asin(a)       : ", r);
    var r2 = testSerial(a, "asin");
    of.withSerializer(vecSerializer).writeln("  asin(a) serial: ", r2);
  }

  for a in vectorType.vectors(data) {
    var r = acos(a);
    of.withSerializer(vecSerializer).writeln("  acos(a)       : ", r);
    var r2 = testSerial(a, "acos");
    of.withSerializer(vecSerializer).writeln("  acos(a) serial: ", r2);
  }

  for a in vectorType.vectors(data) {
    var r = atan(a);
    of.withSerializer(vecSerializer).writeln("  atan(a)       : ", r);
    var r2 = testSerial(a, "atan");
    of.withSerializer(vecSerializer).writeln("  atan(a) serial: ", r2);
  }
}



proc trigTestReal128(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".real-128")) as actualOutput {
    trigTest(actualOutput, real(32), 4);
    trigTest(actualOutput, real(64), 2);
  }
}
proc trigTestReal256(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".real-256")) as actualOutput {
    trigTest(actualOutput, real(32), 8);
    trigTest(actualOutput, real(64), 4);
  }
}

UnitTest.main();
