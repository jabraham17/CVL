use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}

proc shuffleTest(of, param op: string) {
  inner(real(32), 4);
  inner(real(64), 2);
  inner(real(32), 8);
  inner(real(64), 4);

  inner(int(8), 16);
  inner(int(16), 8);
  inner(int(32), 4);
  inner(int(64), 2);

  inner(int(8), 32);
  inner(int(16), 16);
  inner(int(32), 8);
  inner(int(64), 4);

  proc inner(type eltType, param numElts: int) {
    type VT = vector(eltType, numElts);
    of.writeln("=== ", VT:string, " ===");
    var a, other = new VT();
    for param i in 0..#numElts {
      a.set(i, (i+1):eltType);
      other.set(i, (numElts + (i+1)):eltType);
    }
    of.withSerializer(vecSerializer).writeln("  a                : ", a);
    of.withSerializer(vecSerializer).writeln("  other            : ", other);
    of.withSerializer(vecSerializer).writeln("  -----------------");

    select op {
      when "swap" {
        var b = swapPairs(a);
        of.withSerializer(vecSerializer).writeln("  swapPairs        : ", b);
        var c = swapLowHigh(a);
        of.withSerializer(vecSerializer).writeln("  swapLowHigh      : ", c);
      }
      when "reverse" {
        var b = reverse(a);
        of.withSerializer(vecSerializer).writeln("  reverse          : ", b);
      }
      when "rotate" {
        var b = rotateLeft(a);
        of.withSerializer(vecSerializer).writeln("  rotateLeft       : ", b);
        var c = rotateRight(a);
        of.withSerializer(vecSerializer).writeln("  rotateRight      : ", c);
      }
      when "interleave" {
        var b = interleaveLower(a, other);
        of.withSerializer(vecSerializer).writeln("  interleaveLower  : ", b);
        var c = interleaveUpper(a, other);
        of.withSerializer(vecSerializer).writeln("  interleaveUpper  : ", c);
      }
      when "deinterleave" {
        var b = deinterleaveLower(a, other);
        of.withSerializer(vecSerializer).writeln("  deinterleaveLower: ", b);
        var c = deinterleaveUpper(a, other);
        of.withSerializer(vecSerializer).writeln("  deinterleaveUpper: ", c);
      }
      when "blend" {
        var b = blendLowHigh(a, other);
        of.withSerializer(vecSerializer).writeln("  blendLowHigh     : ", b);
      }
    }
  }
}

proc shuffleTestSwap(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".swap")) as actualOutput {
    shuffleTest(actualOutput, "swap");
  }
}
proc shuffleTestReverse(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".reverse")) as actualOutput {
    shuffleTest(actualOutput, "reverse");
  }
}
proc shuffleTestRotate(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".rotate")) as actualOutput {
    shuffleTest(actualOutput, "rotate");
  }
}
proc shuffleTestInterleave(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".interleave")) as actualOutput {
    shuffleTest(actualOutput, "interleave");
  }
}
proc shuffleTestDeinterleave(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".deinterleave")) as actualOutput {
    shuffleTest(actualOutput, "deinterleave");
  }
}
proc shuffleTestBlend(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".blend")) as actualOutput {
    shuffleTest(actualOutput, "blend");
  }
}

UnitTest.main();
