
use SIMD;

var dom = {1..#16 by 2};
var arr = [i in dom] i:real(32);

type vecType = vector(real(32), 4);
writeln("arr: ", arr);
for v in vecType.vectors(arr) {
  writeln("  vec: ", v);
}

writeln("arr: ", arr);
for i in vecType.indicies(dom) {
  writeln("  vec(",i,"): ", vecType.load(arr, i));
}

var tup: 16*real(32);
[i in 0..#16 with (ref tup)] tup[i] = (i+1):real(32);
writeln("tup: ", tup);
for v in vecType.vectors(tup) {
  writeln("  vec: ", v);
}

writeln("tup: ", tup);
for i in vecType.indicies(0..#16) {
  writeln("  vec(",i,"): ", vecType.load(tup, i));
}


var jaggedArr = [i in 1..#14] i:real(32);
writeln("  jaggedArr: ", jaggedArr);
for v in vecType.vectorsJagged(jaggedArr) {
  writeln("  v: ", v);
}
for v in vecType.vectorsJagged(jaggedArr, 99) {
  writeln("  v: ", v);
}
