use UnitTest;
use TestHelpers;
use CVL;
use Random;
use BlockDist, BlockCycDist;

enum distType { DR, block, blockCyclic }

proc saxpy(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
  // z = a * x + y
  forall i in D {
    z[i] = a * x[i] + y[i];
  }
}

proc saxpyWithIndices(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
  param vecSize = 4;
  type vec = vector(real, vecSize);

  if x.size % vecSize != 0 {
    halt("Error: vector size must be a multiple of " + vecSize:string);
  }

  forall i in vec.indices(D) {
    const xv = vec.load(x, i);
    const yv = vec.load(y, i);
    const zv = a * xv + yv;
    zv.store(z, i);
  }
}

proc saxpyWithZip(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
  param vecSize = 4;
  type vec = vector(real, vecSize);

  if x.size % vecSize != 0 {
    halt("Error: vector size must be a multiple of " + vecSize:string);
  }

  forall (i,xv,yv) in zip(vec.indices(D), vec.vectors(x), vec.vectors(y)) {
    const zv = a * xv + yv;
    zv.store(z, i);
  }
}
proc saxpyWithVecRef(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
  param vecSize = 4;
  type vec = vector(real, vecSize);

  if x.size % vecSize != 0 {
    halt("Error: vector size must be a multiple of " + vecSize:string);
  }

  forall (zv, xv, yv) in zip(vec.vectorsRef(z),
                              vec.vectors(x), vec.vectors(y)) {
    zv = a * xv + yv;
  }
}

proc getDomain(N: int, param dist: distType) {
  if dist == distType.DR {
    return {0..#N};
  } else if dist == distType.block {
    return blockDist.createDomain(0..#N);
  } else if dist == distType. blockCyclic {
    return {0..#N} dmapped new blockCycDist(startIdx=0, blocksize=4);
  } else {
    compilerError("Unknown distribution: " + dist);
  }
}

proc allSame(z1, z2, z3, z4, tol=1e-6) {
  const D = z1.domain;
  const isSame12 = && reduce ([i in D] (abs(z1[i] - z2[i]) < tol));
  const isSame13 = && reduce ([i in D] (abs(z1[i] - z3[i]) < tol));
  const isSame14 = && reduce ([i in D] (abs(z1[i] - z4[i]) < tol));
  return isSame12 && isSame13 && isSame14;
}

proc testSaxpyDriver(test: borrowed Test, D) throws {
  var x, y, z1, z2, z3, z4: [D] real;

  fillRandom(x);
  fillRandom(y);

  const a = (new randomStream(real)).next();

  writeln("Running SAXPY");
  writeln("a = ", a);
  writeln("x = ", x);
  writeln("y = ", y);

  writeln("Computing z = a * x + y using regular Chapel");
  saxpy(a, x, y, z1);
  writeln("z = ", z1);

  writeln("Computing z = a * x + y using Chapel with vector indices");
  saxpyWithIndices(a, x, y, z2);
  writeln("z = ", z2);

  writeln("Computing z = a * x + y using Chapel with zip and vectors");
  saxpyWithZip(a, x, y, z3);
  writeln("z = ", z3);

  writeln("Computing z = a * x + y using Chapel with zip and vector refs");
  saxpyWithVecRef(a, x, y, z4);
  writeln("z = ", z4);

  test.assertTrue(allSame(z1, z2, z3, z4));
}


config const N = 64;

proc testSaxpyDR(test: borrowed Test) throws {
  const D = getDomain(N, distType.DR);
  writeln("Testing SAXPY with default rectangular: ", D);
  testSaxpyDriver(test, D);
}
proc testSaxpyBlock(test: borrowed Test) throws {
  const D = getDomain(N, distType.block);
  writeln("Testing SAXPY with block distribution: ", D);
  testSaxpyDriver(test, D);
}
proc testSaxpyBlockCyclic(test: borrowed Test) throws {
  const D = getDomain(N, distType.blockCyclic);
  writeln("Testing SAXPY with block-cyclic distribution: ", D);
  testSaxpyDriver(test, D);
}

proc testSaxpyBlock4Locales(test: borrowed Test) throws {
  test.skipIfExceedsMaxLocales();
  test.maxLocales(4);
  test.minLocales(4);
  const D = getDomain(N, distType.block);
  writeln("Testing SAXPY with block distribution on 4 locales: ", D);
  testSaxpyDriver(test, D);
}

proc testSaxpyBlockCyclic4Locales(test: borrowed Test) throws {
  test.skipIfExceedsMaxLocales();
  test.maxLocales(4);
  test.minLocales(4);
  const D = getDomain(N, distType.blockCyclic);
  writeln("Testing SAXPY with block-cyclic distribution on 4 locales: ", D);
  testSaxpyDriver(test, D);
}

UnitTest.main();
