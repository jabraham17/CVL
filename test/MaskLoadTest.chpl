use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc maskLoadTest(of, type eltType, param numElts: int) {
  of.writeln("maskLoadTest for ", eltType:string, " ", numElts);

  // create a jagged array with 1 less element
  var arr: [0..#(numElts*4+numElts-1)] eltType;
  arr = [i in arr.domain] i:eltType;

  of.withSerializer(vecSerializer).writeln("  arr: ", arr);

  var a: vector(eltType, numElts);
  var mask = new vector(int(numBits(eltType)), numElts, 0);
  mask = ~mask;
  mask.set(mask.numElts-1, 0:mask.eltType); // last lane is zero
  of.withSerializer(vecSerializer).writeln("  mask: ", mask);

  for i in a.type.indices(arr.domain) {
    a.loadMasked(mask, arr, i);
    of.withSerializer(vecSerializer).writeln("  vec at ", i, ": ", a);

    var b = a.type.loadMasked(mask, arr, i);
    of.withSerializer(vecSerializer).writeln("  vec at ", i, ": ", b);
  }
}



proc maskLoadTestDriver(test: borrowed Test) throws {
  import ChplConfig;

  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    test.skip("loadMasked not supported on arm64 yet");
    return;
  }

  manage new outputManager(test, getGoodFile()) as actualOutput {
    maskLoadTest(actualOutput, real(32), 4);
    maskLoadTest(actualOutput, real(64), 2);
    maskLoadTest(actualOutput, real(32), 8);
    maskLoadTest(actualOutput, real(64), 4);

    // maskLoadTest(actualOutput, int(8), 16); // UNSUPPORTED
    // maskLoadTest(actualOutput, int(16), 8); // UNSUPPORTED
    maskLoadTest(actualOutput, int(32), 4);
    maskLoadTest(actualOutput, int(64), 2);

    // maskLoadTest(actualOutput, int(8), 32); // UNSUPPORTED
    // maskLoadTest(actualOutput, int(16), 16); // UNSUPPORTED
    maskLoadTest(actualOutput, int(32), 8);
    maskLoadTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
