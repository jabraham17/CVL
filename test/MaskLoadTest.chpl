use CVI;
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

  var arr: [1..#(numElts*4)] eltType;
  arr = [i in arr.domain] i:eltType;

  of.withSerializer(vecSerializer).writeln("  arr: ", arr);

  var a: vector(eltType, numElts);

  var mask: vector(int, numBits(a.type)/numBits(int));
  mask.set(max(int)); // all ones
  mask.set(mask.numElts-1, 0); // last lane is zero

  for i in a.type.indicies(arr.domain) {
    of.withSerializer(vecSerializer).writeln("  mask: ", mask);

    a.loadWithMask(mask, arr, i);
    of.withSerializer(vecSerializer).writeln("  vec at ", i, ": ", a);

    of.withSerializer(vecSerializer).writeln("  ~mask: ", ~mask);
    var b = a.type.loadWithMask(~mask, arr, i);
    of.withSerializer(vecSerializer).writeln("  vec at ", i, ": ", b);
    
  }
}



proc maskLoadTestDriver(test: borrowed Test) throws {
  import ChplConfig;

  if ChplConfig.CHPL_TARGET_ARCH == "arm64" {
    test.skip("loadWithMask not supported on arm64 yet");
    return;
  }

  manage new outputManager(test, getGoodFile()) as actualOutput {
    maskLoadTest(actualOutput, real(32), 4);
    maskLoadTest(actualOutput, real(64), 2);
    maskLoadTest(actualOutput, real(32), 8);
    maskLoadTest(actualOutput, real(64), 4);

    maskLoadTest(actualOutput, int(8), 16);
    maskLoadTest(actualOutput, int(16), 8);
    maskLoadTest(actualOutput, int(32), 4);
    maskLoadTest(actualOutput, int(64), 2);

    maskLoadTest(actualOutput, int(8), 32);
    maskLoadTest(actualOutput, int(16), 16);
    maskLoadTest(actualOutput, int(32), 8);
    maskLoadTest(actualOutput, int(64), 4);
  }
}

UnitTest.main();
