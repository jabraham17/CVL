use IO, Subprocess, Regex, Reflection;
use CVL;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}

config const testcase = 0;

param numTests = /*procs*/14 * /*types*/8;

proc main(args: [] string) {
  if args.size > 1 then {
    return 1; // don't accept any args
  }
  if testcase == 0 {
    var f = openMemFile();
    var w = f.writer();
    for i in 1..#numTests {
      // TODO: all output must be to stderr until issue is resolved
      //  https://github.com/chapel-lang/chapel/issues/15497
      var p = spawn([args[0], "-nl1", "--testcase="+i:string],
          stdout=pipeStyle.pipe, stderr=pipeStyle.pipe);
        // stdout=pipeStyle.pipe, stderr=pipeStyle.stdout);
      p.wait();
      var stdout, stderr: string;
      p.stdout.readAll(stdout);
      p.stderr.readAll(stderr);
      w.write(stdout);
      w.write(stderr);
    }
    w.close();

    var actualOutput = f.reader().readAll(string);
    var pathRegex = new regex("(/.+)+\\.chpl:[0-9]+: ");
    actualOutput = actualOutput.replace(pathRegex, "");

    var expectedOutput = openReader(getGoodFile()).readAll(string);

    if actualOutput != expectedOutput {
      writeln("Output differs from expected output");
      writeln("Expected:\n", expectedOutput);
      writeln("Actual:\n", actualOutput);
      return 1;
    }

  } else {
    select testcase {
      when 0 {}
      when 1 do shiftLeftBySizeOfLane(vector(int(8), 16));
      when 2 do shiftLeftBySizeOfLane(vector(int(16), 8));
      when 3 do shiftLeftBySizeOfLane(vector(int(32), 4));
      when 4 do shiftLeftBySizeOfLane(vector(int(64), 2));
      when 5 do shiftLeftBySizeOfLane(vector(int(8), 32));
      when 6 do shiftLeftBySizeOfLane(vector(int(16), 16));
      when 7 do shiftLeftBySizeOfLane(vector(int(32), 8));
      when 8 do shiftLeftBySizeOfLane(vector(int(64), 4));

      when 9 do shiftLeftByZero(vector(int(8), 16));
      when 10 do shiftLeftByZero(vector(int(16), 8));
      when 11 do shiftLeftByZero(vector(int(32), 4));
      when 12 do shiftLeftByZero(vector(int(64), 2));
      when 13 do shiftLeftByZero(vector(int(8), 32));
      when 14 do shiftLeftByZero(vector(int(16), 16));
      when 15 do shiftLeftByZero(vector(int(32), 8));
      when 16 do shiftLeftByZero(vector(int(64), 4));

      when 17 do shiftLeftBySizeOfLaneOp(vector(int(8), 16));
      when 18 do shiftLeftBySizeOfLaneOp(vector(int(16), 8));
      when 19 do shiftLeftBySizeOfLaneOp(vector(int(32), 4));
      when 20 do shiftLeftBySizeOfLaneOp(vector(int(64), 2));
      when 21 do shiftLeftBySizeOfLaneOp(vector(int(8), 32));
      when 22 do shiftLeftBySizeOfLaneOp(vector(int(16), 16));
      when 23 do shiftLeftBySizeOfLaneOp(vector(int(32), 8));
      when 24 do shiftLeftBySizeOfLaneOp(vector(int(64), 4));

      when 25 do shiftLeftByZeroOp(vector(int(8), 16));
      when 26 do shiftLeftByZeroOp(vector(int(16), 8));
      when 27 do shiftLeftByZeroOp(vector(int(32), 4));
      when 28 do shiftLeftByZeroOp(vector(int(64), 2));
      when 29 do shiftLeftByZeroOp(vector(int(8), 32));
      when 30 do shiftLeftByZeroOp(vector(int(16), 16));
      when 31 do shiftLeftByZeroOp(vector(int(32), 8));
      when 32 do shiftLeftByZeroOp(vector(int(64), 4));

      when 33 do shiftLeftBySizeOfLaneOpEq(vector(int(8), 16));
      when 34 do shiftLeftBySizeOfLaneOpEq(vector(int(16), 8));
      when 35 do shiftLeftBySizeOfLaneOpEq(vector(int(32), 4));
      when 36 do shiftLeftBySizeOfLaneOpEq(vector(int(64), 2));
      when 37 do shiftLeftBySizeOfLaneOpEq(vector(int(8), 32));
      when 38 do shiftLeftBySizeOfLaneOpEq(vector(int(16), 16));
      when 39 do shiftLeftBySizeOfLaneOpEq(vector(int(32), 8));
      when 40 do shiftLeftBySizeOfLaneOpEq(vector(int(64), 4));

      when 41 do shiftLeftByZeroOpEq(vector(int(8), 16));
      when 42 do shiftLeftByZeroOpEq(vector(int(16), 8));
      when 43 do shiftLeftByZeroOpEq(vector(int(32), 4));
      when 44 do shiftLeftByZeroOpEq(vector(int(64), 2));
      when 45 do shiftLeftByZeroOpEq(vector(int(8), 32));
      when 46 do shiftLeftByZeroOpEq(vector(int(16), 16));
      when 47 do shiftLeftByZeroOpEq(vector(int(32), 8));
      when 48 do shiftLeftByZeroOpEq(vector(int(64), 4));

      when 49 do shiftRightBySizeOfLane(vector(int(8), 16));
      when 50 do shiftRightBySizeOfLane(vector(int(16), 8));
      when 51 do shiftRightBySizeOfLane(vector(int(32), 4));
      when 52 do shiftRightBySizeOfLane(vector(int(64), 2));
      when 53 do shiftRightBySizeOfLane(vector(int(8), 32));
      when 54 do shiftRightBySizeOfLane(vector(int(16), 16));
      when 55 do shiftRightBySizeOfLane(vector(int(32), 8));
      when 56 do shiftRightBySizeOfLane(vector(int(64), 4));

      when 57 do shiftRightByZero(vector(int(8), 16));
      when 58 do shiftRightByZero(vector(int(16), 8));
      when 59 do shiftRightByZero(vector(int(32), 4));
      when 60 do shiftRightByZero(vector(int(64), 2));
      when 61 do shiftRightByZero(vector(int(8), 32));
      when 62 do shiftRightByZero(vector(int(16), 16));
      when 63 do shiftRightByZero(vector(int(32), 8));
      when 64 do shiftRightByZero(vector(int(64), 4));

      when 65 do shiftRightBySizeOfLaneOp(vector(int(8), 16));
      when 66 do shiftRightBySizeOfLaneOp(vector(int(16), 8));
      when 67 do shiftRightBySizeOfLaneOp(vector(int(32), 4));
      when 68 do shiftRightBySizeOfLaneOp(vector(int(64), 2));
      when 69 do shiftRightBySizeOfLaneOp(vector(int(8), 32));
      when 70 do shiftRightBySizeOfLaneOp(vector(int(16), 16));
      when 71 do shiftRightBySizeOfLaneOp(vector(int(32), 8));
      when 72 do shiftRightBySizeOfLaneOp(vector(int(64), 4));

      when 73 do shiftRightByZeroOp(vector(int(8), 16));
      when 74 do shiftRightByZeroOp(vector(int(16), 8));
      when 75 do shiftRightByZeroOp(vector(int(32), 4));
      when 76 do shiftRightByZeroOp(vector(int(64), 2));
      when 77 do shiftRightByZeroOp(vector(int(8), 32));
      when 78 do shiftRightByZeroOp(vector(int(16), 16));
      when 79 do shiftRightByZeroOp(vector(int(32), 8));
      when 80 do shiftRightByZeroOp(vector(int(64), 4));

      when 81 do shiftRightBySizeOfLaneOpEq(vector(int(8), 16));
      when 82 do shiftRightBySizeOfLaneOpEq(vector(int(16), 8));
      when 83 do shiftRightBySizeOfLaneOpEq(vector(int(32), 4));
      when 84 do shiftRightBySizeOfLaneOpEq(vector(int(64), 2));
      when 85 do shiftRightBySizeOfLaneOpEq(vector(int(8), 32));
      when 86 do shiftRightBySizeOfLaneOpEq(vector(int(16), 16));
      when 87 do shiftRightBySizeOfLaneOpEq(vector(int(32), 8));
      when 88 do shiftRightBySizeOfLaneOpEq(vector(int(64), 4));

      when 89 do shiftRightByZeroOpEq(vector(int(8), 16));
      when 90 do shiftRightByZeroOpEq(vector(int(16), 8));
      when 91 do shiftRightByZeroOpEq(vector(int(32), 4));
      when 92 do shiftRightByZeroOpEq(vector(int(64), 2));
      when 93 do shiftRightByZeroOpEq(vector(int(8), 32));
      when 94 do shiftRightByZeroOpEq(vector(int(16), 16));
      when 95 do shiftRightByZeroOpEq(vector(int(32), 8));
      when 96 do shiftRightByZeroOpEq(vector(int(64), 4));

      when 97 do shiftRightArithBySizeOfLane(vector(int(8), 16));
      when 98 do shiftRightArithBySizeOfLane(vector(int(16), 8));
      when 99 do shiftRightArithBySizeOfLane(vector(int(32), 4));
      when 100 do shiftRightArithBySizeOfLane(vector(int(64), 2));
      when 101 do shiftRightArithBySizeOfLane(vector(int(8), 32));
      when 102 do shiftRightArithBySizeOfLane(vector(int(16), 16));
      when 103 do shiftRightArithBySizeOfLane(vector(int(32), 8));
      when 104 do shiftRightArithBySizeOfLane(vector(int(64), 4));

      when 105 do shiftRightArithByZero(vector(int(8), 16));
      when 106 do shiftRightArithByZero(vector(int(16), 8));
      when 107 do shiftRightArithByZero(vector(int(32), 4));
      when 108 do shiftRightArithByZero(vector(int(64), 2));
      when 109 do shiftRightArithByZero(vector(int(8), 32));
      when 110 do shiftRightArithByZero(vector(int(16), 16));
      when 111 do shiftRightArithByZero(vector(int(32), 8));
      when 112 do shiftRightArithByZero(vector(int(64), 4));
    }
    return 1;
  }
  return 0;
}


proc shiftLeftBySizeOfLane(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  v.shiftLeft(s);
}
proc shiftLeftByZero(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  v.shiftLeft(s);
}
proc shiftLeftBySizeOfLaneOp(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  var temp = v << s;
}
proc shiftLeftByZeroOp(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  var temp = v << s;
}
proc shiftLeftBySizeOfLaneOpEq(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  v <<= s;
}
proc shiftLeftByZeroOpEq(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  v <<= s;
}

proc shiftRightBySizeOfLane(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  v.shiftRight(s);
}
proc shiftRightByZero(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  v.shiftRight(s);
}
proc shiftRightBySizeOfLaneOp(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  var temp = v >> s;
}
proc shiftRightByZeroOp(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  var temp = v >> s;
}
proc shiftRightBySizeOfLaneOpEq(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  v >>= s;
}
proc shiftRightByZeroOpEq(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  v >>= s;
}

proc shiftRightArithBySizeOfLane(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = numBits(t.eltType):t.eltType:t;
  v.shiftRightArith(s);
}
proc shiftRightArithByZero(type t) {
  stderr.writeln("=== ", getRoutineName(), " ", t:string, " ===");
  var v: t;
  var s = 0:t.eltType:t;
  v.shiftRightArith(s);
}
