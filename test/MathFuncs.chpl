use CVI;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc mathFuncTest(of, type eltType, param numElts: int) {
  of.writeln("math functions for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  a = -a;
  of.withSerializer(vecSerializer).writeln("  a: ", a);
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var r = min(a, b);
    of.withSerializer(vecSerializer).writeln("  min(a, b): ", r);
  }
  {
    var r = max(a, b);
    of.withSerializer(vecSerializer).writeln("  max(a, b): ", r);
  }
  {
    var r = abs(a);
    of.withSerializer(vecSerializer).writeln("     abs(a): ", r);
  }
}


proc mathFuncTestDriver(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    mathFuncTest(actualOutput, real(32), 4);
    mathFuncTest(actualOutput, real(64), 2);
    mathFuncTest(actualOutput, real(32), 8);
    mathFuncTest(actualOutput, real(64), 4);

    mathFuncTest(actualOutput, int(8), 16);
    mathFuncTest(actualOutput, int(16), 8);
    mathFuncTest(actualOutput, int(32), 4);
    mathFuncTest(actualOutput, int(64), 2);

    mathFuncTest(actualOutput, int(8), 32);
    mathFuncTest(actualOutput, int(16), 16);
    mathFuncTest(actualOutput, int(32), 8);
    mathFuncTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
