module SAXPY {
  use CVL;
  use Random;
  use BlockDist, BlockCycDist;

  enum distType { DR, block, blockCyclic }
  use distType;
  config param dist = DR;
  config const N = 16;

  proc saxpy(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
    // z = a * x + y
    forall i in D {
      z[i] = a * x[i] + y[i];
    }
  }

  proc saxpySIMD(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
    param vecSize = 4;
    type vec = vector(real, vecSize);

    if x.size % vecSize != 0 {
      halt("Error: vector size must be a multiple of " + vecSize:string);
    }

    // forall i in vec.indices(D) {
    //   const xv = vec.load(x, i);
    //   const yv = vec.load(y, i);
    //   const zv = a * xv + yv;
    //   zv.store(z, i);
    // }
    // forall (i, xv, yv) in zip(vec.indices(D), vec.vectors(x), vec.vectors(y)) {
    //   const zv = a * xv + yv;
    //   zv.store(z, i);
    // }
    forall (zv, xv, yv) in zip(vec.vectorsRef(z),
                               vec.vectors(x), vec.vectors(y)) {
      zv = a * xv + yv;
    }
  }

  proc getDomain() {
    if dist == DR {
      return {0..#N};
    } else if dist == block {
      return blockDist.createDomain(0..#N);
    } else if dist == blockCyclic {
      return {0..#N} dmapped new blockCycDist(startIdx=0, blocksize=4);
    } else {
      compilerError("Unknown distribution: " + dist);
    }
  }

  proc main() {
    const D = getDomain();
    var x, y, z1, z2: [D] real;

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

    writeln("Computing z = a * x + y using SIMD Chapel");
    saxpySIMD(a, x, y, z2);
    writeln("z = ", z2);

    const tol = 1e-6;
    const isSame = && reduce ([i in D] (abs(z1[i] - z2[i]) < tol));
    if isSame {
      writeln("Success: results match!");
      return 0;
    } else {
      writeln("Error: results do not match!");
      return 1;
    }

  }
}
