use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}

proc toHex(tup) {
  use IO;
  var res: tup.size * string;
  for param i in 0..<tup.size {
    type elmType = tup[i].type;
    var bits = if isRealType(elmType)
                then tup[i].transmute(uint(numBits(elmType)))
                else tup[i]:uint(numBits(elmType));
    res[i] = "%@0xu".format(bits);
  }
  return res;
}
proc toHex(x: vector(?)) {
  return toHex(x.toTuple());
}

proc isAll(of, type eltType, param numElts: int) {
  of.writeln("isAll* functions for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  of.withSerializer(vecSerializer).writeln("  a: ", a);
  of.withSerializer(vecSerializer).writeln("  b: ", b);
  of.withSerializer(vecSerializer).writeln("  -----------------");


  var ones = a.type.ones();
  of.writeln("  ones(): ", toHex(ones));
  var zeros = a.type.zeros();
  of.writeln("  zeros(): ", toHex(zeros));

  {
    var r = zeros.isZero();
    of.writeln("  zeros.isZero(): ", r);
  }

  {
    var r = ones.isZero();
    of.writeln("  ones.isZero(): ", r);
  }

  {
    var r = a.isZero();
    of.writeln("  a.isZero(): ", r);
  }

  {
    for param i in 0..#numElts {
      var c = a.type.zeros();
      c.set(i, a.type.ones()[i]);
      of.withSerializer(vecSerializer).writeln("  c: ", toHex(c));
      var mm = c.moveMask();
      of.writef("  c.moveMask(): %@0"+numBits(mm.type):string+"bu\n", mm);
    }
  }

}



proc isAllReal128(test: borrowed Test) throws {
  test.skip("moveMask does't work yet");
  manage new outputManager(test, getGoodFile(".real-128")) as actualOutput {
    isAll(actualOutput, real(32), 4);
    isAll(actualOutput, real(64), 2);
  }
}
proc isAllReal256(test: borrowed Test) throws {
  test.skip("moveMask does't work yet");
  manage new outputManager(test, getGoodFile(".real-256")) as actualOutput {
    isAll(actualOutput, real(32), 8);
    isAll(actualOutput, real(64), 4);
  }
}
proc isAllInt128(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".int-128")) as actualOutput {
    isAll(actualOutput, int(8), 16);
    isAll(actualOutput, int(16), 8);
    isAll(actualOutput, int(32), 4);
    isAll(actualOutput, int(64), 2);
  }
}
proc isAllInt256(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile(".int-256")) as actualOutput {
    isAll(actualOutput, int(8), 32);
    isAll(actualOutput, int(16), 16);
    isAll(actualOutput, int(32), 8);
    isAll(actualOutput, int(64), 4);
  }
}

UnitTest.main();
