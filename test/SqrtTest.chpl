use CVI;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc sqrtTest(of, type eltType, param numElts: int) {
  of.writeln("sqrtTest for ", eltType:string, " ", numElts);

  var a: vector(eltType, numElts);
  var v: numElts*eltType;
  for param i in 0..#a.numElts {
    v(i) = ((i+1)*(i+1)):eltType;
  }
  of.withSerializer(vecSerializer).writeln("  v: ", v);
  a.set(v);

  of.withSerializer(vecSerializer).writeln("  a: ", v);
  a = sqrt(a);
  of.withSerializer(vecSerializer).writeln("  sqrt(a): ", a);

  a = rsqrt(a*a);
  of.withSerializer(vecSerializer).writeln("  rsqrt(a): ", a);
}


proc sqrtTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {

    sqrtTest(actualOutput, real(32), 4);
    sqrtTest(actualOutput, real(64), 2);
    sqrtTest(actualOutput, real(32), 8);
    sqrtTest(actualOutput, real(64), 4);

    // sqrtTest(int(8), 16); // UNSUPPORTED
    // sqrtTest(int(16), 8); // UNSUPPORTED
    // sqrtTest(int(32), 4); // UNSUPPORTED
    // sqrtTest(int(64), 2); // UNSUPPORTED

    // sqrtTest(int(8), 32); // UNSUPPORTED
    // sqrtTest(int(16), 16); // UNSUPPORTED
    // sqrtTest(int(32), 8); // UNSUPPORTED
    // sqrtTest(int(64), 4); // UNSUPPORTED

  }
}

UnitTest.main();
