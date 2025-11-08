import StreamConfig;
use Time;
use CVL;

param variant = "scalar";

proc stream(a: real, x: [?D] real, y: [D] real, ref z: [D] real) {
  // z = a * x + y
  forall i in D {
    z[i] = a * x[i] + y[i];
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
    writeln("Variant '", variant, "'' took ", t.elapsed(), " seconds");
  }

  if StreamConfig.check {
    StreamConfig.checkResult(a, x, y, z);
  }

}
