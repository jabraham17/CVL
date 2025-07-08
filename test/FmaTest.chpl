use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc fmaTest(of, type eltType, param numElts: int) {
  of.writeln("fmaTest for ", eltType:string, " ", numElts);

  var a, b, c = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
    c.set(i, (numElts*2 + (i+1)):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  a: ", a);
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.withSerializer(vecSerializer).writeln("  c: ", c);
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var d = fma(a, b, c);
    of.withSerializer(vecSerializer).writeln("  fma(a, b, c): ", d);
  }
  {
    var d = fms(a, b, c);
    of.withSerializer(vecSerializer).writeln("  fms(a, b, c): ", d);
  }
}



proc fmaTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    fmaTest(actualOutput, real(32), 4);
    fmaTest(actualOutput, real(64), 2);
    fmaTest(actualOutput, real(32), 8);
    fmaTest(actualOutput, real(64), 4);

    fmaTest(actualOutput, int(8), 16);
    fmaTest(actualOutput, int(16), 8);
    fmaTest(actualOutput, int(32), 4);
    // fmaTest(actualOutput, int(64), 2); // UNSUPPORTED

    fmaTest(actualOutput, int(8), 32);
    fmaTest(actualOutput, int(16), 16);
    fmaTest(actualOutput, int(32), 8);
    // fmaTest(actualOutput, int(64), 4); // UNSUPPORTED
  }
}

UnitTest.main();
