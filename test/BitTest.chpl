use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
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
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var mask = ~(a & 0:eltType); // all 1s
    var r = bitSelect(mask, a, b);
    of.withSerializer(vecSerializer).writeln("  bitSelect(ONE, a, b) : ", r);
    r = bitSelect(~(mask), a, b); // all 0s
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
    of.withSerializer(vecSerializer).writeln("  a & b: ", r);
  }
  {
    var r = a | b;
    of.withSerializer(vecSerializer).writeln("  a | b: ", r);
  }
  {
    var r = a ^ b;
    of.withSerializer(vecSerializer).writeln("  a ^ b: ", r);
  }
  {
    var r = ~a;
    of.withSerializer(vecSerializer).writeln("     ~a: ", r);
  }
  {
    var r = andNot(a, b);
    of.withSerializer(vecSerializer).writeln("  andNot(a, b): ", r);
  }
  // TODO shifts
}



proc bitTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    bitTest(actualOutput, real(32), 4);
    bitTest(actualOutput, real(64), 2);
    bitTest(actualOutput, real(32), 8);
    bitTest(actualOutput, real(64), 4);

    bitTest(actualOutput, int(8), 16);
    bitTest(actualOutput, int(16), 8);
    bitTest(actualOutput, int(32), 4);
    bitTest(actualOutput, int(64), 2);

    bitTest(actualOutput, int(8), 32);
    bitTest(actualOutput, int(16), 16);
    bitTest(actualOutput, int(32), 8);
    bitTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
