use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}

proc testBasicIterators(of, type eltType, param numElts: int) {
  of.writeln(".vectors and .indices iterators for ",
             eltType:string, " ", numElts);

  type vecType = vector(eltType, numElts);

  //
  // arrays
  //

  var dom = {1..#(numElts*8) by 2};
  var arr = [i in dom] i:eltType;
  of.writeln(" arr: ", arr);

  of.writeln("  serial iterators:");
  for v in vecType.vectors(arr) {
    of.withSerializer(vecSerializer).writeln("    vec: ", v);
  }
  for i in vecType.indices(dom) {
    of.withSerializer(vecSerializer).writeln("    vec(",i,"): ",
                                             vecType.load(arr, i));
  }

  of.writeln("  parallel iterators:");
  var sum = 0: eltType;
  forall v in vecType.vectors(arr) with (+ reduce sum) {
    var t0 = pairwiseAdd(v, v);
    var t1 = swapLowHigh(t0);
    var t2 = pairwiseAdd(t0, t1);
    sum += t2(0);
  }
  of.withSerializer(vecSerializer)
    .writeln("    sum (by vectors iterator): ", sum);

  sum = 0: eltType;
  forall i in vecType.indices(dom) with (+ reduce sum) {
    var v = vecType.load(arr, i);
    var t0 = pairwiseAdd(v, v);
    var t1 = swapLowHigh(t0);
    var t2 = pairwiseAdd(t0, t1);
    sum += t2(0);
  }
  of.withSerializer(vecSerializer)
    .writeln("    sum (by indices iterator): ", sum);

  //
  // tuples
  //
  param tupleSize = numElts * 4;
  var tup: tupleSize*eltType;
  [i in 0..#tupleSize with (ref tup)] tup[i] = (i+1):eltType;

  of.withSerializer(vecSerializer).writeln(" tup: ", tup);
  of.writeln("  serial iterators:");
  for v in vecType.vectors(tup) {
    of.withSerializer(vecSerializer).writeln("    vec: ", v);
  }

  for i in vecType.indices(0..#tupleSize) {
    of.withSerializer(vecSerializer)
      .writeln("    vec(",i,"): ", vecType.load(tup, i));
  }

  of.writeln("  parallel iterators for tuples:");
  sum = 0: eltType;
  forall v in vecType.vectors(tup) with (+ reduce sum) {
    var t0 = pairwiseAdd(v, v);
    var t1 = swapLowHigh(t0);
    var t2 = pairwiseAdd(t0, t1);
    sum += t2(0);
  }
  of.withSerializer(vecSerializer)
    .writeln("    sum (by vectors iterator): ", sum);

  sum = 0: eltType;
  forall i in vecType.indices(0..#tupleSize) with (+ reduce sum) {
    var v = vecType.load(tup, i);
    var t0 = pairwiseAdd(v, v);
    var t1 = swapLowHigh(t0);
    var t2 = pairwiseAdd(t0, t1);
    sum += t2(0);
  }
  of.withSerializer(vecSerializer)
    .writeln("    sum (by indices iterator): ", sum);

}


proc testBasicIteratorsReal128(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".basic-real-128")
  ) as actualOutput {
    testBasicIterators(actualOutput, real(32), 4);
    testBasicIterators(actualOutput, real(64), 2);
  }
}
proc testBasicIteratorsReal256(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".basic-real-256")
  ) as actualOutput {
    testBasicIterators(actualOutput, real(32), 8);
    testBasicIterators(actualOutput, real(64), 4);
  }
}
proc testBasicIteratorsInt128(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".basic-int-128")
  ) as actualOutput {
    testBasicIterators(actualOutput, int(8), 16);
    testBasicIterators(actualOutput, int(16), 8);
    testBasicIterators(actualOutput, int(32), 4);
    testBasicIterators(actualOutput, int(64), 2);
  }
}
proc testBasicIteratorsInt256(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".basic-int-256")
  ) as actualOutput {
    testBasicIterators(actualOutput, int(8), 32);
    testBasicIterators(actualOutput, int(16), 16);
    testBasicIterators(actualOutput, int(32), 8);
    testBasicIterators(actualOutput, int(64), 4);
  }
}

proc testJaggedIterator(of, type eltType, param numElts: int) {
  of.writeln("testJaggedIterator for ", eltType:string, " ", numElts);

  var jaggedArr = [i in 1..#((numElts*4)+numElts/2)] i:eltType;
  of.writeln(" jaggedArr: ", jaggedArr);

  type vecType = vector(eltType, numElts);

  for v in vecType.vectorsJagged(jaggedArr) {
    of.withSerializer(vecSerializer).writeln("  v: ", v);
  }
  of.writeln(" use dummy value of 99:");
  for v in vecType.vectorsJagged(jaggedArr, 99:eltType) {
    of.withSerializer(vecSerializer).writeln("  v: ", v);
  }

}

proc testJaggedIteratorReal128(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".jagged-real-128")
  ) as actualOutput {
    testJaggedIterator(actualOutput, real(32), 4);
    testJaggedIterator(actualOutput, real(64), 2);
  }
}
proc testJaggedIteratorReal256(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".jagged-real-256")
  ) as actualOutput {
    testJaggedIterator(actualOutput, real(32), 8);
    testJaggedIterator(actualOutput, real(64), 4);
  }
}
proc testJaggedIteratorInt128(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".jagged-int-128")
  ) as actualOutput {
    testJaggedIterator(actualOutput, int(8), 16);
    testJaggedIterator(actualOutput, int(16), 8);
    testJaggedIterator(actualOutput, int(32), 4);
    testJaggedIterator(actualOutput, int(64), 2);
  }
}
proc testJaggedIteratorInt256(test: borrowed Test) throws {
  manage new outputManager(
    test,
    getGoodFile(".jagged-int-256")
  ) as actualOutput {
    testJaggedIterator(actualOutput, int(8), 32);
    testJaggedIterator(actualOutput, int(16), 16);
    testJaggedIterator(actualOutput, int(32), 8);
    testJaggedIterator(actualOutput, int(64), 4);
  }
}

proc testModifyingIterators(test: borrowed Test) throws {
  test.skip("modifying iterators not tested yet");
}

proc testZippering(test: borrowed Test) throws {
  test.skip("zippering not tested yet");
}


    // {
    //   var myArr = arr;
    //   actualOutput.writeln("arr: ", myArr);
    //   for v in vecType.vectorsRef(myArr) {
    //     v *= 2 + v;
    //   }
    //   actualOutput.writeln("arr: ", myArr);
    // }

    // {
    //   var arr = [i in 1..#100] i:real(32);
    //   var arr2 = [i in 1..#100] -i:real(32);
    //   forall (i1, i2) in zip(vecType.indices(arr.domain),
    //                          vecType.indices(arr2.domain)) {
    //     var v1 = vecType.load(arr, i1);
    //     var v2 = vecType.load(arr2, i2);
    //     actualOutput.writeln("  i1: ", i1, " i2: ", i2,
    //                          " v1: ", v1, " v2: ", v2);
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

    // {
    //   const D = {1..#100};
    //   const D2 = {0..by 2#100};
    //   var arr: [D] real(32) = D;
    //   var arr2: [D2] real(32) = -D;
    //   actualOutput.writeln("arr: ", arr2);
    //   forall (i, v) in zip(vecType.indices(arr), vecType.vectorsRef(arr2)) {
    //     actualOutput.writeln("  i: ", i);
    //     v += vecType.load(arr, i);
    //   }
    //   actualOutput.writeln("arr: ", arr2);
    // }

    // { // assign
    //   type vecType = vector(int, 4);
    //   const D = {1..#100};
    //   const D2 = {0..by 2#100};
    //   var arr: [D] int = D;
    //   var arr2: [D2] int;
    //   actualOutput.writeln("arr: ", arr);
    //   actualOutput.writeln("arr2: ", arr2);
    //   forall (v, i) in zip(vecType.vectors(arr), vecType.indices(arr2)) {
    //     v.store(arr2, i);
    //   }
    //   actualOutput.writeln("arr2: ", arr2);
    // }

    // { // assign2
    //   type vecType = vector(int, 4);
    //   const D = {1..#100};
    //   const D2 = {0..by 2#100};
    //   var arr: [D] int = D;
    //   var arr2: [D2] int;
    //   actualOutput.writeln("arr: ", arr);
    //   actualOutput.writeln("arr2: ", arr2);
    //   forall (v, v2) in zip(vecType.vectors(arr), vecType.vectorsRef(arr2)) {
    //     // v2 = v; // can;t assign because i can't actualOutput.write an init=
    //     v2.set(v);
    //   }
    //   actualOutput.writeln("arr2: ", arr2);
    // }

UnitTest.main();
