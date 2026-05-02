import StreamConfig;
use Time;
use CVL;

param variant = "explicit";

proc stream(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
  param vecSize = 4;
  type vec = vector(real, vecSize);

  if x.size % vecSize != 0 {
    halt("Error: vector size must be a multiple of " + vecSize:string);
  }

  const av = new vec(a);
  forall i in vec.indices(D) {
    const xv = vec.load(x, i);
    const yv = vec.load(y, i);
    const zv = av * xv + yv;
    zv.store(z, i);
  }
}

proc main() {

  var (D, x, y, a) = StreamConfig.getData();
  var z: [D] real;

  var t = new stopwatch();
  t.start();
  stream(a, x, y, z);
  t.stop();

  if StreamConfig.timing {
    writeln("Variant '", variant, "' took ", t.elapsed(), " seconds");
  }

  if StreamConfig.check {
    StreamConfig.checkResult(a, x, y, z);
  }

}
