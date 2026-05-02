import StreamConfig;
use Time;
use CVL;

param variant = "iterator";

proc stream(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
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
