use CVL;
use UnitTest;
use BlockDist, CyclicDist, BlockCycDist;

enum distType { DR, block, cyclic, blockCyclic }
proc getDomain(param dist: distType, dom: domain(1), blocksize=1) {
  if dist == DR {
    return dom;
  } else if dist == block {
    return blockDist.createDomain(dom);
  } else if dist == cyclic {
    return blockDist.createDomain(dom);
  } else if dist == blockCyclic {
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

  writeln("Domain: ", dom);
  writeln("Array: ", arr);

  forall v in vecTy.vectors(dom) {
    for param j in 0..#vecTy.numElts {
      test.assertEqual(v[i]:int, here.id);
    }
  }

  var otherArr: [dom] vecTy.eltType;
  forall i in vecTy.indices(dom) {
    var loaded = vecTy.load(arr, i);
    loaded.store(otherArr, i);
  }
  test.assertEqual(mapping, otherArr:int);

  otherArr = -1;
  coforall l in dom.targetLocales() do on l {
    for d in dom.localSubdomains() {
      for i in vecTy.indices(d) {
        var loaded = vecTy.load(arr, i);
        loaded.store(otherArr, i);
      }
    }
  }
  test.assertEqual(mapping, otherArr:int);

}


proc testOneLocale(test: borrowed Test) throws {
  self.addNumLocales(1);

  testDomainHelper(test, vector(int(64), 4),
    getDomain(distType.DR, {0..63}));

  testDomainHelper(test, vector(int(32), 4),
    getDomain(distType.block, {0..63}));

  testDomainHelper(test, vector(real(32), 4),
    getDomain(distType.block, {10..#64}));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {0..63}, 8));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {-32..#128}, 16));

  testDomainHelper(test, vector(int(64), 2),
    getDomain(distType.cyclic, {0..63}));
}

proc testTwoLocales(test: borrowed Test) throws {
  test.addNumLocales(2);

  testDomainHelper(test, vector(int(64), 4),
    getDomain(distType.DR, {0..63}));

  testDomainHelper(test, vector(int(32), 4),
    getDomain(distType.block, {0..63}));

  testDomainHelper(test, vector(real(32), 4),
    getDomain(distType.block, {10..#64}));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {0..63}, 8));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {-32..#128}, 16));
}

proc testFourLocales(test: borrowed Test) throws {
  test.addNumLocales(4);

  testDomainHelper(test, vector(int(64), 4),
    getDomain(distType.DR, {0..63}));

  testDomainHelper(test, vector(int(32), 4),
    getDomain(distType.block, {0..63}));

  testDomainHelper(test, vector(real(32), 4),
    getDomain(distType.block, {10..#64}));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {0..63}, 8));

  testDomainHelper(test, vector(int(16), 8),
    getDomain(distType.blockCyclic, {-32..#128}, 16));
}


UnitTest.main();
