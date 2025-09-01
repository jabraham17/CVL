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
                   goodFileName: string,
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
      if good != actual {
        throw new TestError.AssertionError(
          ("\n"+
           "in %s:%i:\n"+
           "expected '%s'\n"+
           "actual   '%s'").format(goodFileName, lineno, good, actual));
      }
    }
  } catch e: TestError.AssertionError {
    if !dumpActual then
      throw e;
  }
}

record outputManager: contextManager {
  var test: borrowed Test;
  var goodFileName: string;
  var goodFile: IO.file;
  var actualFile: IO.file;
  var actualWriter: IO.fileWriter(false);

  proc init(test: borrowed Test, goodFileName: string) {
    this.test = test;
    this.goodFileName = goodFileName;
    this.goodFile = getGoodFile(this.goodFileName);
    this.actualFile = newOutputFile();
  }

  proc ref enterContext() ref : IO.fileWriter(?) {
    actualWriter = actualFile.writer();
    return actualWriter;
  }

  proc exitContext(in err: owned Error?) throws {
    actualWriter.close();
    if err then test.assertTrue(false);
    compareOutput(test, goodFileName, goodFile.reader(), actualFile.reader());
  }
}


proc toHex(tup, param filled = false) where isTuple(tup) {
  use IO;
  var res: tup.size * string;
  for param i in 0..<tup.size {
    res[i] = toHex(tup[i], filled=filled);
  }
  return res;
}
import Vector.vector;
proc toHex(x: vector(?), param filled = false) {
  return toHex(x.toTuple(), filled=filled);
}
proc toHex(x: numeric, param filled = false) {
  use IO;
  type T = x.type;
  var bits = if isRealType(T)
              then x.transmute(uint(numBits(T)))
              else x:uint(numBits(T));
  param width = numBits(T)/4 + 2; // +2 for "0x"
  param fmt = if filled then "%@0"+width:string+"xu"
                        else "%@0xu";
  return fmt.format(bits);
}


proc toBin(tup, param filled = false) where isTuple(tup) {
  use IO;
  var res: tup.size * string;
  for param i in 0..<tup.size {
    res[i] = toBin(tup[i], filled=filled);
  }
  return res;
}
proc toBin(x: vector(?), param filled = false) {
  return toBin(x.toTuple(), filled=filled);
}
proc toBin(x: numeric, param filled = false) {
  use IO;
  type T = x.type;
  var bits = if isRealType(T)
              then x.transmute(uint(numBits(T)))
              else x:uint(numBits(T));
  param width = numBits(T) + 2; // +2 for "0b"
  param fmt = if filled then "%@0"+width:string+"bu"
                        else "%@0bu";
  return fmt.format(bits);
}
