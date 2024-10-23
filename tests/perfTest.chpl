
use Time;

config const n = 100_000;
config const i = 50;
config const print = false;
use SIMD;
type vecType = vector(int(32), 4);
const D = {1:int(32)..#n:int(32)};

var arr: [D] int(32) = D;

{
  if print then writeln("arr: ", arr);
  var t = new stopwatch();
  t.start();
  for 1..#i {
    forall v in vecType.vectorsRef(arr) {
      v.set(1:int(32) /v.vec);
    }
  }
  t.stop();
  if print then writeln("arr: ", arr);
  writeln("time: ", t.elapsed() /i);
}

{
  arr = D;
  if print then writeln("arr: ", arr);

  var t = new stopwatch();
  t.start();
  for 1..#i {
    forall v in arr {
      v = 1 / v;
    }
  }
  t.stop();
  if print then writeln("arr: ", arr);
  writeln("time: ", t.elapsed()/i);
}
