
use CVL;
proc test() {

  var arr: [1..#16] real(32) = 1.. by 2 # 16;
  var arr2: [0..#16] real(32) = 1..#16;

  type vecType = vector(real(32), 4);
  writeln("arr: ", arr);
  writeln("arr2: ", arr2);
  for (v1, v2) in zip(vecType.vectorsRef(arr), vecType.vectors(arr2)) {
    v1 *= 10 + v2;
  }
  writeln("arrAfter: ", arr);
}
test();
