use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc mathTest(of, type eltType, param numElts: int) {
  of.writeln("mathTest for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  a: ", a);
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var c = a + b;
    of.withSerializer(vecSerializer).writeln("  a + b: ", c);
  }
  {
    var c = -a;
    of.withSerializer(vecSerializer).writeln("     -a: ", c);
  }
  {
    var c = a - b;
    of.withSerializer(vecSerializer).writeln("  a - b: ", c);
  }
  {
    var c = b - a;
    of.withSerializer(vecSerializer).writeln("  b - a: ", c);
  }
  if eltType != int(64) { // UNSUPPORTED
    var c = a * b;
    of.withSerializer(vecSerializer).writeln("  a * b: ", c);
  }
  {
    var c = a / b;
    of.withSerializer(vecSerializer).writeln("  a / b: ", c);
  }
  {
    var c = b / a;
    of.withSerializer(vecSerializer).writeln("  b / a: ", c);
  }
  {
    var c = pairwiseAdd(a, b);
    of.withSerializer(vecSerializer).writeln("  pairAdd(a, b): ", c);
  }
}

proc mathTestDriver(test: borrowed Test) throws {

  import ChplConfig;
  if ChplConfig.CHPL_TARGET_ARCH == "x86_64" {
    test.skip("pairAdd doesn't work fully yet on x86_64");
    return;
  }

  manage new outputManager(test, getGoodFile()) as actualOutput {
    mathTest(actualOutput, real(32), 4);
    mathTest(actualOutput, real(64), 2);
    mathTest(actualOutput, real(32), 8);
    mathTest(actualOutput, real(64), 4);

    mathTest(actualOutput, int(8), 16);
    mathTest(actualOutput, int(16), 8);
    mathTest(actualOutput, int(32), 4);
    mathTest(actualOutput, int(64), 2);

    mathTest(actualOutput, int(8), 32);
    mathTest(actualOutput, int(16), 16);
    mathTest(actualOutput, int(32), 8);
    mathTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
