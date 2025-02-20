use CVI;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc cmpTest(of, type eltType, param numElts: int) {
  of.writeln("comparisons for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts - (i+1)):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  a: ", a);
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var r = a == b;
    of.withSerializer(vecSerializer).writeln("  a == b: ", r);
  }
  {
    var r = a != b;
    of.withSerializer(vecSerializer).writeln("  a != b: ", r);
  }
  {
    var r = a < b;
    of.withSerializer(vecSerializer).writeln("  a < b: ", r);
  }
  {
    var r = a <= b;
    of.withSerializer(vecSerializer).writeln("  a <= b: ", r);
  }
  {
    var r = a > b;
    of.withSerializer(vecSerializer).writeln("  a > b: ", r);
  }
  {
    var r = a >= b;
    of.withSerializer(vecSerializer).writeln("  a >= b: ", r);
  }
}


proc cmpTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    cmpTest(actualOutput, real(32), 4);
    cmpTest(actualOutput, real(64), 2);
    cmpTest(actualOutput, real(32), 8);
    cmpTest(actualOutput, real(64), 4);

    cmpTest(actualOutput, int(8), 16);
    cmpTest(actualOutput, int(16), 8);
    cmpTest(actualOutput, int(32), 4);
    cmpTest(actualOutput, int(64), 2);

    cmpTest(actualOutput, int(8), 32);
    cmpTest(actualOutput, int(16), 16);
    cmpTest(actualOutput, int(32), 8);
    cmpTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
