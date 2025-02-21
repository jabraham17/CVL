use CVI;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc arrTest(of, type eltType, param numElts: int) {
  of.writeln("arrTest for ", eltType:string, " ", numElts);

  var arr: [1..#(numElts*4)] eltType;
  arr = [i in arr.domain] i:eltType;

  of.withSerializer(vecSerializer).writeln("  arr: ", arr);

  var a: vector(eltType, numElts);
  for i in arr.domain by numElts {
    a.load(arr, i);
    of.withSerializer(vecSerializer).writeln("  vec at ", i, ": ", a);

    var b = new a.type();
    b = a+a;
    b.store(arr, i);
  }
  of.withSerializer(vecSerializer).writeln("  arr: ", arr);

  param stride = 2;
  var strided: [1.. by stride #(numElts*4)] eltType;
  strided = [i in strided.domain] i:eltType;

  of.withSerializer(vecSerializer).writeln("  strided: ", strided);
  for i in strided.domain by numElts {
    a.load(strided, i);
    of.withSerializer(vecSerializer).writeln("  vec at ", i, ": ", a);

    var b = new a.type();
    b = a+a;
    b.store(strided, i);
  }

  of.withSerializer(vecSerializer).writeln("  strided: ", strided);
}



proc arrTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    arrTest(actualOutput, real(32), 4);
    arrTest(actualOutput, real(64), 2);
    // arrTest(actualOutput, real(32), 8);
    // arrTest(actualOutput, real(64), 4);

    arrTest(actualOutput, int(8), 16);
    arrTest(actualOutput, int(16), 8);
    arrTest(actualOutput, int(32), 4);
    arrTest(actualOutput, int(64), 2);

    // arrTest(actualOutput, int(8), 32);
    // arrTest(actualOutput, int(16), 16);
    // arrTest(actualOutput, int(32), 8);
    // arrTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
