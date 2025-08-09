import Math;
use Time;

config const n = 100_000;
config const timing = false;
config const print = false;

config param vectorize = false;

proc kernel(ref a: []) where vectorize == false {
  forall i in a.domain {
    const x = Math.cos(i*1.0);
    a[i] = if x > 0 then x * Math.sin(i*2.0) else 0.0;
  }
}

proc kernel(ref a: []) where vectorize == true {
  use CVL;
  type VT = vector(real, 2);
  const zero = 0.0:VT;
  const one = 1.0:VT;
  const two = 2.0:VT;
  forall i in VT.indices(a) {
    const ii = new VT(i:real);
    const x = CVL.cos(ii);
    const mask = x > zero;
    const y = bitSelect(mask, x * CVL.sin(ii*two), zero);
    y.store(a, i);
  }
}

proc main() {
  var a: [0..#n] real;
  var s = new stopwatch();
  s.start();
  kernel(a);
  s.stop();
  if timing {
    writeln("Time taken: ", s.elapsed(), " seconds");
  }
  if print {
    writeln("Result: ", a);
  }
}
