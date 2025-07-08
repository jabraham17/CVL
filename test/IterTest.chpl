use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile() {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-4] + "good";
  return path;
}

proc test1(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as actualOutput {
    var dom = {1..#16 by 2};
    var arr = [i in dom] i:real(32);

    type vecType = vector(real(32), 4);
    actualOutput.writeln("arr: ", arr);
    for v in vecType.vectors(arr) {
      actualOutput.writeln("  vec: ", v);
    }

    actualOutput.writeln("arr: ", arr);
    for i in vecType.indices(dom) {
      actualOutput.writeln("  vec(",i,"): ", vecType.load(arr, i));
    }

    var tup: 16*real(32);
    [i in 0..#16 with (ref tup)] tup[i] = (i+1):real(32);
    actualOutput.writeln("tup: ", tup);
    for v in vecType.vectors(tup) {
      actualOutput.writeln("  vec: ", v);
    }

    actualOutput.writeln("tup: ", tup);
    for i in vecType.indices(0..#16) {
      actualOutput.writeln("  vec(",i,"): ", vecType.load(tup, i));
    }


    var jaggedArr = [i in 1..#14] i:real(32);
    actualOutput.writeln("  jaggedArr: ", jaggedArr);
    for v in vecType.vectorsJagged(jaggedArr) {
      actualOutput.writeln("  v: ", v);
    }
    for v in vecType.vectorsJagged(jaggedArr, 99) {
      actualOutput.writeln("  v: ", v);
    }


    {
      var myArr = arr;
      actualOutput.writeln("arr: ", myArr);
      for v in vecType.vectorsRef(myArr) {
        v *= 2 + v;
      }
      actualOutput.writeln("arr: ", myArr);
    }

    // {
    //   var arr = [i in 1..#100] i:real(32);
    //   var arr2 = [i in 1..#100] -i:real(32);
    //   forall (i1, i2) in zip(vecType.indices(arr.domain), vecType.indices(arr2.domain)) {
    //     var v1 = vecType.load(arr, i1);
    //     var v2 = vecType.load(arr2, i2);
    //     actualOutput.writeln("  i1: ", i1, " i2: ", i2, " v1: ", v1, " v2: ", v2);
    //   }
    // }

    // {
    //   var arr = [i in 1..#100] i:real(32);
    //   var arr2 = [i in 1..#100] -i:real(32);
    //   forall (v1, v2) in zip(vecType.vectors(arr), vecType.vectors(arr2)) {
    //     // var v1 = vecType.load(arr, i1);
    //     // var v2 = vecType.load(arr2, i2);
    //     actualOutput.writeln("v1: ", v1, " v2: ", v2);
    //   }
    // }

    {
      const D = {1..#100};
      const D2 = {0..by 2#100};
      var arr: [D] real(32) = D;
      var arr2: [D2] real(32) = -D;
      actualOutput.writeln("arr: ", arr2);
      forall (i, v) in zip(vecType.indices(arr), vecType.vectorsRef(arr2)) {
        actualOutput.writeln("  i: ", i);
        v += vecType.load(arr, i);
      }
      actualOutput.writeln("arr: ", arr2);
    }

    { // assign
      type vecType = vector(int, 4);
      const D = {1..#100};
      const D2 = {0..by 2#100};
      var arr: [D] int = D;
      var arr2: [D2] int;
      actualOutput.writeln("arr: ", arr);
      actualOutput.writeln("arr2: ", arr2);
      forall (v, i) in zip(vecType.vectors(arr), vecType.indices(arr2)) {
        v.store(arr2, i);
      }
      actualOutput.writeln("arr2: ", arr2);
    }

    { // assign2
      type vecType = vector(int, 4);
      const D = {1..#100};
      const D2 = {0..by 2#100};
      var arr: [D] int = D;
      var arr2: [D2] int;
      actualOutput.writeln("arr: ", arr);
      actualOutput.writeln("arr2: ", arr2);
      forall (v, v2) in zip(vecType.vectors(arr), vecType.vectorsRef(arr2)) {
        // v2 = v; // can;t assign because i can't actualOutput.write an init=
        v2.set(v);
      }
      actualOutput.writeln("arr2: ", arr2);
    }
  }
}

UnitTest.main();
