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
var vecSerializer = new precisionSerializer(precision=precision, padding=padding);
// var vecOut = stdout.withSerializer(vecSerializer);

//
// Test Helpers
//

proc getGoodFile(fileName: string): IO.file {
  return IO.open(fileName, IO.ioMode.r);
}
proc newOutputFile(): IO.file {
  return IO.openMemFile();
}

proc compareOutput(test: borrowed Test, goodFile: IO.fileReader(?), actualOutput: IO.fileReader(?)) throws {
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

  test.assertEqual(goodFileContents.size, actualOutputLines.size);
  for (good, actual) in zip(goodFileContents, actualOutputLines) {
    test.assertEqual(good, actual);
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

  proc exitContext(in err: owned Error?) {
    actualWriter.close();
    if err then test.assertTrue(false);
    compareOutput(test, goodFile.reader(), actualFile.reader());
  }
}
