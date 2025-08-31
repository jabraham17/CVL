module SAXPY {
  use CVL;
  use Random;

  config const N = 16;

  proc saxpy(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
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

    forall i in vec.indices(D) {
      const xv = vec.load(x, i);
      const yv = vec.load(y, i);
      const zv = a * xv + yv;
      zv.store(z, i);
    }
  }

  proc main() {
    var x: [0..#N] real;
    var y: [0..#N] real;
    var z: [0..#N] real;

    fillRandom(x);
    fillRandom(y);

    const a = (new randomStream(real)).next();

    writeln("Running SAXPY");
    writeln("a = ", a);
    writeln("x = ", x);
    writeln("y = ", y);

    writeln("Computing z = a * x + y using regular Chapel");
    saxpy(a, x, y, z);
    writeln("z = ", z);

    writeln("Computing z = a * x + y using SIMD Chapel");
    saxpySIMD(a, x, y, z);
    writeln("z = ", z);
  }
}
