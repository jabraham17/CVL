module StreamConfig {
  use BlockDist, BlockCycDist;
  use Random;

  config const N = 16;
  config const check = true;
  config const timing = false;

  enum distType { DR, block, blockCyclic }
  config param dist: distType = distType.block;

  proc getDomain() {
    use distType;
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

  proc getData() {
    const D = getDomain();
    var x, y: [D] real;
    fillRandom(x);
    fillRandom(y);
    const a: real = (new randomStream(real)).next();
    return (D, x, y, a);
  }

  proc checkResult(a: real, x: [?D] real, y: [D] real, z: [D] real) {
    var z2 = x * a + y;
    const tol = 1e-6;
    const isSame = && reduce ([i in D] (abs(z[i] - z2[i]) < tol));
    if !isSame {
      writeln("Stream result is incorrect!");
    }
  }

}
