use IO;
use SIMD;
use PrecisionSerializer;

config const shouldPrint = true;
config const precision = 2;
config const padding = 5;
var vecOut = stdout.withSerializer(new precisionSerializer(precision=precision, padding=padding));


proc log(args...) do log((...args), strm=stdout);
proc log(args..., strm: fileWriter(?)) {
  if !shouldPrint then return;
  strm.writeln((...args));
}

config param compileTestName: string = "all";
config const runTestName: string = "all";

proc sqrtTest(type eltType, param numElts: int) {
  log("sqrtTest for ", eltType:string, " ", numElts);

  var a: vector(eltType, numElts);
  var v: numElts*eltType;
  for param i in 0..#a.numElts {
    v(i) = ((i+1)*(i+1)):eltType;
  }
  log(strm=vecOut, "  v: ", v);
  a.set(v);

  log(strm=vecOut, "  a: ", v);
  a = sqrt(a);
  log(strm=vecOut, "  sqrt(a): ", a);

  a = rsqrt(a*a);
  log(strm=vecOut, "  rsqrt(a): ", a);
}

proc arrTest(type eltType, param numElts: int) {
  log("arrTest for ", eltType:string, " ", numElts);

  var arr: [1..#(numElts*4)] eltType;
  arr = [i in arr.domain] i:eltType;

  log(strm=vecOut, "  arr: ", arr);

  var a: vector(eltType, numElts);
  for i in arr.domain by numElts {
    a.load(arr, i);
    log(strm=vecOut, "  vec at ", i, ": ", a);

    var b = new a.type();
    b = a+a;
    b.store(arr, i);
  }
  log(strm=vecOut, "  arr: ", arr);

  param stride = 2;
  var strided: [1.. by stride #(numElts*4)] eltType;
  strided = [i in strided.domain] i:eltType;

  log(strm=vecOut, "  strided: ", strided);
  for i in strided.domain by numElts {
    a.load(strided, i);
    log(strm=vecOut, "  vec at ", i, ": ", a);

    var b = new a.type();
    b = a+a;
    b.store(strided, i);
  }

  log(strm=vecOut, "  strided: ", strided);
}
proc initTest(type eltType, param numElts: int) {
  log("initTest for ", eltType:string, " ", numElts);

  var a = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
  }
  log(strm=vecOut, "  set individual: ", a);
  a.set(0:eltType);
  log(strm=vecOut, "  reset: ", a);

  var tup: numElts*eltType;
  for param i in 0..#numElts {
    tup(i) = (i+1):eltType;
  }
  a.set(tup);
  log(strm=vecOut, "  set tuple: ", a);

  var res = a:(numElts*eltType);
  log(strm=vecOut, "  get tuple (", res.type:string, "): ", res);

}

proc shuffleTest(type eltType, param numElts: int) {
  log("shuffleTest for ", eltType:string, " ", numElts);

  var a, other = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    other.set(i, (numElts + (i+1)):eltType);
  }
  log(strm=vecOut, "  a                : ", a);
  log(strm=vecOut, "  other            : ", other);
  log(strm=vecOut, "  -----------------");

  {
    var b = swapPairs(a);
    log(strm=vecOut, "  swapPairs        : ", b);
  }
  {
    var b = swapLowHigh(a);
    log(strm=vecOut, "  swapLowHigh      : ", b);
  }
  {
    var b = reverse(a);
    log(strm=vecOut, "  reverse          : ", b);
  }
  {
    var b = rotateLeft(a);
    log(strm=vecOut, "  rotateLeft       : ", b);
  }
  {
    var b = rotateRight(a);
    log(strm=vecOut, "  rotateRight      : ", b);
  }
  {
    var b = interleaveLower(a, other);
    log(strm=vecOut, "  interleaveLower  : ", b);
  }
  {
    var b = interleaveUpper(a, other);
    log(strm=vecOut, "  interleaveUpper  : ", b);
  }
  {
    var b = deinterleaveLower(a, other);
    log(strm=vecOut, "  deinterleaveLower: ", b);
  }
  {
    var b = deinterleaveUpper(a, other);
    log(strm=vecOut, "  deinterleaveUpper: ", b);
  }
  {
    var b = blendLowHigh(a, other);
    log(strm=vecOut, "  blendLowHigh     : ", b);
  }
}

proc mathTest(type eltType, param numElts: int) {
  log("mathTest for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  log(strm=vecOut, "  a: ", a);
  log(strm=vecOut, "  b: ", b);
  log(strm=vecOut, "  -----------------");

  {
    var c = a + b;
    log(strm=vecOut, "  a + b: ", c);
  }
  {
    var c = -a;
    log(strm=vecOut, "     -a: ", c);
  }
  {
    var c = a - b;
    log(strm=vecOut, "  a - b: ", c);
  }
  {
    var c = b - a;
    log(strm=vecOut, "  b - a: ", c);
  }
  if eltType != int(64) { // UNSUPPORTED
    var c = a * b;
    log(strm=vecOut, "  a * b: ", c);
  }
  {
    var c = a / b;
    log(strm=vecOut, "  a / b: ", c);
  }
  {
    var c = b / a;
    log(strm=vecOut, "  b / a: ", c);
  }
  {
    var c = pairwiseAdd(a, b);
    log(strm=vecOut, "  pairAdd(a, b): ", c);
  }
}

proc fmaTest(type eltType, param numElts: int) {
  log("fmaTest for ", eltType:string, " ", numElts);

  var a, b, c = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
    c.set(i, (numElts*2 + (i+1)):eltType);
  }
  log(strm=vecOut, "  a: ", a);
  log(strm=vecOut, "  b: ", b);
  log(strm=vecOut, "  c: ", c);
  log(strm=vecOut, "  -----------------");

  {
    var d = fma(a, b, c);
    log(strm=vecOut, "  fma(a, b, c): ", d);
  }
  {
    var d = fms(a, b, c);
    log(strm=vecOut, "  fms(a, b, c): ", d);
  }
}

proc mathFuncs(type eltType, param numElts: int) {
  log("math functions for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  a = -a;
  log(strm=vecOut, "  a: ", a);
  log(strm=vecOut, "  b: ", b);
  log(strm=vecOut, "  -----------------");

  {
    var r = min(a, b);
    log(strm=vecOut, "  min(a, b): ", r);
  }
  {
    var r = max(a, b);
    log(strm=vecOut, "  max(a, b): ", r);
  }
  {
    var r = abs(a);
    log(strm=vecOut, "     abs(a): ", r);
  }
}


proc bitTest(type eltType, param numElts: int) {
  log("bit functions for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts + (i+1)):eltType);
  }
  log(strm=vecOut, "  a: ", a);
  log(strm=vecOut, "  b: ", b);
  log(strm=vecOut, "  -----------------");

  {
    var mask = ~(a & 0:eltType); // all 1s
    var r = bitSelect(mask, a, b);
    log(strm=vecOut, "  bitSelect(ONE, a, b) : ", r);
    r = bitSelect(~(mask), a, b); // all 0s
    log(strm=vecOut, "  bitSelect(ZERO, a, b): ", r);
    for param i in 0..#numElts by 2 {
      mask.set(i, 0:eltType);
    }
    r = bitSelect(mask, a, b);
    log(strm=vecOut, "  bitSelect(EVEN, a, b): ", r);
    r = bitSelect(~(mask), a, b);
    log(strm=vecOut, "  bitSelect(ODD, a, b) : ", r);
  }
  {
    var r = a & b;
    log(strm=vecOut, "  a & b: ", r);
  }
  {
    var r = a | b;
    log(strm=vecOut, "  a | b: ", r);
  }
  {
    var r = a ^ b;
    log(strm=vecOut, "  a ^ b: ", r);
  }
  {
    var r = ~a;
    log(strm=vecOut, "     ~a: ", r);
  }
  {
    var r = andNot(a, b);
    log(strm=vecOut, "  andNot(a, b): ", r);
  }
  // TODO shifts
}

proc cmpTest(type eltType, param numElts: int) {
  log("comparisons for ", eltType:string, " ", numElts);

  var a, b = new vector(eltType, numElts);
  for param i in 0..#numElts {
    a.set(i, (i+1):eltType);
    b.set(i, (numElts - (i+1)):eltType);
  }
  log(strm=vecOut, "  a: ", a);
  log(strm=vecOut, "  b: ", b);
  log(strm=vecOut, "  -----------------");

  {
    var r = a == b;
    log(strm=vecOut, "  a == b: ", r);
  }
  {
    var r = a != b;
    log(strm=vecOut, "  a != b: ", r);
  }
  {
    var r = a < b;
    log(strm=vecOut, "  a < b: ", r);
  }
  {
    var r = a <= b;
    log(strm=vecOut, "  a <= b: ", r);
  }
  {
    var r = a > b;
    log(strm=vecOut, "  a > b: ", r);
  }
  {
    var r = a >= b;
    log(strm=vecOut, "  a >= b: ", r);
  }
}

proc shouldCompileTest(param name: string) param do
  return compileTestName == "all" || compileTestName == name;
proc shouldRunTest(param name: string) do
  return runTestName == "all" || runTestName == name;

proc main() {

  if shouldCompileTest("arrTest") && shouldRunTest("arrTest") {
    arrTest(real(32), 4);
    arrTest(real(64), 2);
    arrTest(real(32), 8);
    arrTest(real(64), 4);

    arrTest(int(8), 16);
    arrTest(int(16), 8);
    arrTest(int(32), 4);
    arrTest(int(64), 2);

    arrTest(int(8), 32);
    arrTest(int(16), 16);
    arrTest(int(32), 8);
    arrTest(int(64), 4);
  }
  if shouldCompileTest("initTest") && shouldRunTest("initTest") {
    initTest(real(32), 4);
    initTest(real(64), 2);
    initTest(real(32), 8);
    initTest(real(64), 4);

    initTest(int(8), 16);
    initTest(int(16), 8);
    initTest(int(32), 4);
    initTest(int(64), 2);

    initTest(int(8), 32);
    initTest(int(16), 16);
    initTest(int(32), 8);
    initTest(int(64), 4);
  }
  if shouldCompileTest("mathTest") && shouldRunTest("mathTest") {
    mathTest(real(32), 4);
    mathTest(real(64), 2);
    mathTest(real(32), 8);
    mathTest(real(64), 4);

    mathTest(int(8), 16);
    mathTest(int(16), 8);
    mathTest(int(32), 4);
    mathTest(int(64), 2);

    mathTest(int(8), 32);
    mathTest(int(16), 16);
    mathTest(int(32), 8);
    mathTest(int(64), 4);
  }
  if shouldCompileTest("sqrtTest") && shouldRunTest("sqrtTest") {
    sqrtTest(real(32), 4);
    sqrtTest(real(64), 2);
    sqrtTest(real(32), 8);
    sqrtTest(real(64), 4);

    // sqrtTest(int(8), 16); // UNSUPPORTED
    // sqrtTest(int(16), 8); // UNSUPPORTED
    // sqrtTest(int(32), 4); // UNSUPPORTED
    // sqrtTest(int(64), 2); // UNSUPPORTED

    // sqrtTest(int(8), 32); // UNSUPPORTED
    // sqrtTest(int(16), 16); // UNSUPPORTED
    // sqrtTest(int(32), 8); // UNSUPPORTED
    // sqrtTest(int(64), 4); // UNSUPPORTED
  }
  if shouldCompileTest("shuffleTest") && shouldRunTest("shuffleTest") {
    shuffleTest(real(32), 4);
    shuffleTest(real(64), 2);
    shuffleTest(real(32), 8);
    shuffleTest(real(64), 4);

    shuffleTest(int(8), 16);
    shuffleTest(int(16), 8);
    shuffleTest(int(32), 4);
    shuffleTest(int(64), 2);

    shuffleTest(int(8), 32);
    shuffleTest(int(16), 16);
    shuffleTest(int(32), 8);
    shuffleTest(int(64), 4);
  }
  if shouldCompileTest("fmaTest") && shouldRunTest("fmaTest") {
    fmaTest(real(32), 4);
    fmaTest(real(64), 2);
    fmaTest(real(32), 8);
    fmaTest(real(64), 4);

    fmaTest(int(8), 16);
    fmaTest(int(16), 8);
    fmaTest(int(32), 4);
    // fmaTest(int(64), 2); // UNSUPPORTED

    fmaTest(int(8), 32);
    fmaTest(int(16), 16);
    fmaTest(int(32), 8);
    // fmaTest(int(64), 4); // UNSUPPORTED
  }

  if shouldCompileTest("mathFuncs") && shouldRunTest("mathFuncs") {
    mathFuncs(real(32), 4);
    mathFuncs(real(64), 2);
    mathFuncs(real(32), 8);
    mathFuncs(real(64), 4);

    mathFuncs(int(8), 16);
    mathFuncs(int(16), 8);
    mathFuncs(int(32), 4);
    mathFuncs(int(64), 2);

    mathFuncs(int(8), 32);
    mathFuncs(int(16), 16);
    mathFuncs(int(32), 8);
    mathFuncs(int(64), 4);
  }

  if shouldCompileTest("bitTest") && shouldRunTest("bitTest") {
    bitTest(real(32), 4);
    bitTest(real(64), 2);
    bitTest(real(32), 8);
    bitTest(real(64), 4);

    bitTest(int(8), 16);
    bitTest(int(16), 8);
    bitTest(int(32), 4);
    bitTest(int(64), 2);

    bitTest(int(8), 32);
    bitTest(int(16), 16);
    bitTest(int(32), 8);
    bitTest(int(64), 4);
  }

  if shouldCompileTest("cmpTest") && shouldRunTest("cmpTest") {
    cmpTest(real(32), 4);
    cmpTest(real(64), 2);
    cmpTest(real(32), 8);
    cmpTest(real(64), 4);

    cmpTest(int(8), 16);
    cmpTest(int(16), 8);
    cmpTest(int(32), 4);
    cmpTest(int(64), 2);

    cmpTest(int(8), 32);
    cmpTest(int(16), 16);
    cmpTest(int(32), 8);
    cmpTest(int(64), 4);
  }

}
