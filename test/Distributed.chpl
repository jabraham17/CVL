use CVL;
use UnitTest;
use TestHelpers;
use BlockDist, CyclicDist, BlockCycDist;

enum distType { DR, block, cyclic, blockCyclic }
proc getDomain(param dist: distType, dom: domain(?), blocksize=1) {
  if dist == distType.DR {
    return dom;
  } else if dist == distType.block {
    return blockDist.createDomain(dom);
  } else if dist == distType.cyclic {
    return blockDist.createDomain(dom);
  } else if dist == distType.blockCyclic {
    return dom dmapped new blockCycDist(startIdx=dom.low, blocksize=blocksize);
  } else {
    compilerError("Unknown distribution: " + dist);
  }
}


proc testDomainHelper(test: borrowed Test, type vecTy, dom) throws {
  var arr: [dom] vecTy.eltType;

  var mapping: [dom] int;
  forall i in dom do
    mapping[i] = here.id;


  arr = mapping:vecTy.eltType;

  writeln("Vector type: ", vecTy:string);
  writeln("Domain: ", dom.type:string, " ", dom);
  writeln("Mapping: ", mapping.type:string, " ", mapping);
  writeln("Array: ", arr.type:string, " ", arr);

  forall v in vecTy.vectors(arr) {
    writeln("Vector: ", v, " on locale ", here.id);
    for param i in 0..#vecTy.numElts {
      test.assertEqual(v[i]:int, here.id);
    }
  }

  var otherArr: [dom] vecTy.eltType;
  forall i in vecTy.indices(dom) {
    writeln("Index: ", i, " on locale ", here.id);
    var loaded = vecTy.load(arr, i);
    loaded.store(otherArr, i);
  }
  {
    const temp = otherArr:int;
    test.assertEqual(mapping, temp);
  }

  otherArr = -1;
  coforall l in dom.targetLocales() do on l {
    for d in dom.localSubdomains() {
      for i in vecTy.indices(d) {
        writeln("Index: ", i, " on locale ", here.id);
        var loaded = vecTy.load(arr, i);
        loaded.store(otherArr, i);
      }
    }
  }
  {
    const temp = otherArr:int;
    test.assertEqual(mapping, temp);
  }


  forall (i, v) in zip(vecTy.indices(dom), vecTy.vectors(arr)) {
    var loaded = vecTy.load(arr, i);
    test.assertEqual(loaded, v);
  }

  // TODO: whats wrong with this?
  forall (v, i) in zip(vecTy.vectors(arr), vecTy.indices(dom)) {
    var loaded = vecTy.load(arr, i);
    test.assertEqual(loaded, v);
  }

}


proc testOneLocale(test: borrowed Test) throws {
// TODO: bug in mason in <2.5 prevents us from using addNumLocales
  test.maxLocales(1);
  test.minLocales(1);

  testDomainHelper(test, vector(int(64), 4),
    getDomain(distType.DR, {0..63}));

  testDomainHelper(test, vector(int(32), 4),
    getDomain(distType.block, {0..63}));

  testDomainHelper(test, vector(real(32), 4),
    getDomain(distType.block, {10.. by 4 #64}));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {1.. #64}, 8));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {-32..#128}, 16));

  testDomainHelper(test, vector(int(64), 2),
    getDomain(distType.cyclic, {0..63}));
}

proc testTwoLocales(test: borrowed Test) throws {
// TODO: bug in mason in <2.5 prevents us from using addNumLocales
  test.maxLocales(2);
  test.minLocales(2);

  testDomainHelper(test, vector(int(64), 4),
    getDomain(distType.DR, {0..63}));

  testDomainHelper(test, vector(int(32), 4),
    getDomain(distType.block, {1..by 4 #64}));

  testDomainHelper(test, vector(real(32), 4),
    getDomain(distType.block, {10..#64}));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {0..63}, 8));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {-32..#128}, 16));
}

proc testFourLocales(test: borrowed Test) throws {
  // TODO: bug in mason in <2.5 prevents us from using addNumLocales
  test.maxLocales(4);
  test.minLocales(4);

  testDomainHelper(test, vector(int(64), 4),
    getDomain(distType.DR, {0..63}));

  testDomainHelper(test, vector(int(32), 4),
    getDomain(distType.block, {1..by 4 #64}));

  testDomainHelper(test, vector(real(32), 4),
    getDomain(distType.block, {10..#64}));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {0..63}, 8));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {-32..#128}, 16));
}


UnitTest.main();
