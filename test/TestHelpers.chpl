use UnitTest;
import IO;
use PrecisionSerializer only precisionSerializer;


//
// Logging
//

config const verbosePrint = false;
config const dumpActual = false;
config const precision = 2;
config const padding = 5;
var vecSerializer = new precisionSerializer(precision=precision,
                                            padding=padding);

//
// Test Helpers
//

proc getGoodFile(fileName: string): IO.file {
  return IO.open(fileName, IO.ioMode.r);
}
proc newOutputFile(): IO.file {
  return IO.openMemFile();
}

proc compareOutput(test: borrowed Test,
                   goodFile: IO.fileReader(?),
                   actualOutput: IO.fileReader(?)) throws {
  var goodFileContents = goodFile.lines(stripNewline=true);
  var actualOutputLines = actualOutput.lines(stripNewline=true);

  if verbosePrint {
    writeln("goodFileContents: ");
    for l in goodFileContents {
      writeln(l);
    }
    writeln("========================================");
    writeln("actualOutputLines: ");
    for l in actualOutputLines {
      writeln(l);
    }
    writeln("========================================");
  }
  if dumpActual {
    for l in actualOutputLines {
      writeln(l);
    }
  }

  try {
    test.assertEqual(goodFileContents.size, actualOutputLines.size);
    for (good, actual, lineno) in
        zip(goodFileContents, actualOutputLines, 1..) {
      try {
        test.assertEqual(good, actual);
      } catch e: TestError.AssertionError {
        throw new TestError.AssertionError(
          "Line % 4i:\nExpected '%s'\n"+
                      "but got  '%s'".format(lineno, good, actual));
      }
    }
  } catch e: TestError.AssertionError {
    if !dumpActual then
      throw e;
  }
}

record outputManager: contextManager {
  var test: borrowed Test;
  var goodFile: IO.file;
  var actualFile: IO.file;
  var actualWriter: IO.fileWriter(false);

  proc init(test: borrowed Test, goodFileName: string) {
    this.test = test;
    this.goodFile = getGoodFile(goodFileName);
    this.actualFile = newOutputFile();
  }

  proc ref enterContext() ref : IO.fileWriter(?) {
    actualWriter = actualFile.writer();
    return actualWriter;
  }

  proc exitContext(in err: owned Error?) throws {
    actualWriter.close();
    if err then test.assertTrue(false);
    compareOutput(test, goodFile.reader(), actualFile.reader());
  }
}


proc toHex(tup, param filled = false) {
  use IO;
  var res: tup.size * string;
  for param i in 0..<tup.size {
    type elmType = tup[i].type;
    var bits = if isRealType(elmType)
                then tup[i].transmute(uint(numBits(elmType)))
                else tup[i]:uint(numBits(elmType));
    param fmt = if filled then "%@0"+(numBits(elmType)/4):string+"xu"
                          else "%@0xu";
    res[i] = fmt.format(bits);
  }
  return res;
}
import Vector.vector;
proc toHex(x: vector(?), param filled = false) {
  return toHex(x.toTuple(), filled=filled);
}
