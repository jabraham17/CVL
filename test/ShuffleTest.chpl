use CVI;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc shuffleTest(of, type eltType, param numElts: int) {
  of.writeln("shuffleTest for ", eltType:string, " ", numElts);

  var a, other = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    other.set(i, (numElts + (i+1)):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  a                : ", a);
  of.withSerializer(vecSerializer).writeln("  other            : ", other);
  of.withSerializer(vecSerializer).writeln("  -----------------");

  {
    var b = swapPairs(a);
    of.withSerializer(vecSerializer).writeln("  swapPairs        : ", b);
  }
  {
    var b = swapLowHigh(a);
    of.withSerializer(vecSerializer).writeln("  swapLowHigh      : ", b);
  }
  {
    var b = reverse(a);
    of.withSerializer(vecSerializer).writeln("  reverse          : ", b);
  }
  {
    var b = rotateLeft(a);
    of.withSerializer(vecSerializer).writeln("  rotateLeft       : ", b);
  }
  {
    var b = rotateRight(a);
    of.withSerializer(vecSerializer).writeln("  rotateRight      : ", b);
  }
  {
    var b = interleaveLower(a, other);
    of.withSerializer(vecSerializer).writeln("  interleaveLower  : ", b);
  }
  {
    var b = interleaveUpper(a, other);
    of.withSerializer(vecSerializer).writeln("  interleaveUpper  : ", b);
  }
  {
    var b = deinterleaveLower(a, other);
    of.withSerializer(vecSerializer).writeln("  deinterleaveLower: ", b);
  }
  {
    var b = deinterleaveUpper(a, other);
    of.withSerializer(vecSerializer).writeln("  deinterleaveUpper: ", b);
  }
  {
    var b = blendLowHigh(a, other);
    of.withSerializer(vecSerializer).writeln("  blendLowHigh     : ", b);
  }
}

proc shuffleTestDriver(test: borrowed Test) throws {

  test.skip("not all shuffles are implemented");

  manage new outputManager(test, getGoodFile()) as actualOutput {
    shuffleTest(actualOutput, real(32), 4);
    shuffleTest(actualOutput, real(64), 2);
    shuffleTest(actualOutput, real(32), 8);
    shuffleTest(actualOutput, real(64), 4);

    shuffleTest(actualOutput, int(8), 16);
    shuffleTest(actualOutput, int(16), 8);
    shuffleTest(actualOutput, int(32), 4);
    shuffleTest(actualOutput, int(64), 2);

    shuffleTest(actualOutput, int(8), 32);
    shuffleTest(actualOutput, int(16), 16);
    shuffleTest(actualOutput, int(32), 8);
    shuffleTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
