use CVI;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc initTest(of, type eltType, param numElts: int) {
  of.writeln("initTest for ", eltType:string, " ", numElts);

  var a = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  set individual: ", a);
  a.set(0:eltType);
  of.withSerializer(vecSerializer).writeln("  reset: ", a);

  var tup: numElts*eltType;
  for param i in 0..#numElts {
    tup(i) = (i+1):eltType;
  }
  a.set(tup);
  of.withSerializer(vecSerializer).writeln("  set tuple: ", a);

  var res = a:(numElts*eltType);
  of.withSerializer(vecSerializer).writeln("  get tuple (", res.type:string, "): ", res);

}



proc initTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    initTest(actualOutput, real(32), 4);
    initTest(actualOutput, real(64), 2);
    // initTest(actualOutput, real(32), 8);
    // initTest(actualOutput, real(64), 4);

    initTest(actualOutput, int(8), 16);
    initTest(actualOutput, int(16), 8);
    initTest(actualOutput, int(32), 4);
    initTest(actualOutput, int(64), 2);

    // initTest(actualOutput, int(8), 32);
    // initTest(actualOutput, int(16), 16);
    // initTest(actualOutput, int(32), 8);
    // initTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
