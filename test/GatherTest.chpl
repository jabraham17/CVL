use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc gatherTest(of, type eltType, param numElts: int) {
  of.writeln("gatherTest for ", eltType:string, " ", numElts);

  // create an array with 1000 elements
  var arr: [0..#1000] eltType;
  arr = [i in arr.domain] i:eltType;

  type VT = vector(eltType, numElts);

  param nIndices = numBits(VT)/numBits(int(32));

  proc testInner(indices, ref src, startIdx) {
    of.writeln("  gathering at ", startIdx, " using indices: ", indices);
    of.withSerializer(vecSerializer).writeln("  original vector: ", src);
    src.gather(arr, startIdx, indices);
    of.withSerializer(vecSerializer).writeln("  gathered vector: ", src);
    of.writeln("====");
  }


  proc testInnerMasked(indices, ref src, startIdx, mask) {
    of.writeln("  gathering at ", startIdx,
               ", masked by ", toHex(mask,filled=true),
               ", using indices: ", indices);
    of.withSerializer(vecSerializer).writeln("  original vector: ", src);
    src.gather(arr, startIdx, indices, mask=mask);
    of.withSerializer(vecSerializer).writeln("  gathered vector: ", src);
  of.writeln("====");
  }


  {
    var indices = new vector(int(32), nIndices);
    for param i in 0..#nIndices do indices.set(i, i:int(32));

    var a = new VT();
    testInner(indices, a, 0);
    var mask = new VT();
    mask = ~mask;
    mask.set(mask.numElts-1, 0:mask.eltType); // last lane is zero
    a.set(0:eltType);
    testInnerMasked(indices, a, 2, mask);
  }

  {
    var indices = new vector(int(32), nIndices);
    for param i in 0..#nIndices do indices.set(i, (i+i):int(32));

    var a = new VT();
    testInner(indices, a, 0);
    var mask = new VT();
    mask = ~mask;
    mask.set(mask.numElts-1, 0:mask.eltType); // last lane is zero
    a.set(17:eltType);
    testInnerMasked(indices, a, 0, mask);
  }

}



proc gatherTestDriver(test: borrowed Test) throws {
  import ChplConfig;

  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    test.skip("gathers not supported on arm64 yet");
    return;
  }

  manage new outputManager(test, getGoodFile()) as actualOutput {
    gatherTest(actualOutput, real(32), 4);
    gatherTest(actualOutput, real(64), 2);
    gatherTest(actualOutput, real(32), 8);
    gatherTest(actualOutput, real(64), 4);

    // gatherTest(actualOutput, int(8), 16); // UNSUPPORTED
    // gatherTest(actualOutput, int(16), 8); // UNSUPPORTED
    gatherTest(actualOutput, int(32), 4);
    gatherTest(actualOutput, int(64), 2);

    // gatherTest(actualOutput, int(8), 32); // UNSUPPORTED
    // gatherTest(actualOutput, int(16), 16); // UNSUPPORTED
    gatherTest(actualOutput, int(32), 8);
    gatherTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
