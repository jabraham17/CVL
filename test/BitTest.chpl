use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}

proc bitTest(of, type eltType, param numElts: int) {
  of.writeln("bit functions for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  a: ", a);
  of.writeln("  a: ", toHex(a));
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.writeln("  b: ", toHex(b));
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var ones = a.type.ones();
    of.writeln("  ones(): ", toHex(ones));
    var computedOnes = ~(a & 0:eltType);
    of.writeln("  ~(a & 0): ", toHex(computedOnes));
    var zeros = a.type.zeros();
    of.writeln("  zeros(): ", toHex(zeros));
    var computedZeros = a & 0:eltType;
    of.writeln("  a & 0: ", toHex(computedZeros));
  }

  {
    var mask = a.type.ones();
    var r = bitSelect(mask, a, b);
    of.withSerializer(vecSerializer).writeln("  bitSelect(ONE, a, b): ", r);
    r = bitSelect(a.type.zeros(), a, b);
    of.withSerializer(vecSerializer).writeln("  bitSelect(ZERO, a, b): ", r);
    for param i in 0..#numElts by 2 {
      mask.set(i, 0:eltType);
    }
    r = bitSelect(mask, a, b);
    of.withSerializer(vecSerializer).writeln("  bitSelect(EVEN, a, b): ", r);
    r = bitSelect(~(mask), a, b);
    of.withSerializer(vecSerializer).writeln("  bitSelect(ODD, a, b) : ", r);
  }
  {
    var r = a & b;
    of.writeln("  a & b: ", toHex(r));
  }
  {
    var r = a | b;
    of.withSerializer(vecSerializer).writeln("  a | b: ", toHex(r));
  }
  {
    var r = a ^ b;
    of.writeln("  a ^ b: ", toHex(r));
  }
  {
    var r = ~a;
    of.writeln("     ~a: ", toHex(r));
  }
  {
    var r = andNot(a, b);
    of.writeln("  andNot(a, b): ", toHex(r));
  }
  // TODO shifts
}



proc bitTestReal128(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".real-128")) as actualOutput {
    bitTest(actualOutput, real(32), 4);
    bitTest(actualOutput, real(64), 2);
  }
}
proc bitTestReal256(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".real-256")) as actualOutput {
    bitTest(actualOutput, real(32), 8);
    bitTest(actualOutput, real(64), 4);
  }
}
proc bitTestInt128(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".int-128")) as actualOutput {
    bitTest(actualOutput, int(8), 16);
    bitTest(actualOutput, int(16), 8);
    bitTest(actualOutput, int(32), 4);
    bitTest(actualOutput, int(64), 2);
  }
}
proc bitTestInt256(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".int-256")) as actualOutput {
    bitTest(actualOutput, int(8), 32);
    bitTest(actualOutput, int(16), 16);
    bitTest(actualOutput, int(32), 8);
    bitTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
