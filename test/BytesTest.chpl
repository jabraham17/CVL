use CVL;
use UnitTest;
use TestHelpers;

proc getGoodFile(suffix="") {
  use Reflection, Path;
  var path = absPath(getFileName());
  path = path[0..#path.size-5] + suffix + ".good";
  return path;
}


proc loadBytes(test: borrowed Test) throws {
  manage new outputManager(test, getGoodFile()) as of {

    var b = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    of.writeln("Testing bytes: ", b);

    proc testInner(type vecType) {
      of.writeln("vector type: ", vecType:string);

      var v = vecType.load(b);
      of.writeln("  load: ", v);
      var v1 = vecType.load(b, 8);
      of.writeln("  load with offset: ", v1);

      var v2: vecType;
      v2.load(b);
      of.writeln("  load into existing: ", v2);
      v2.load(b, 8);
      of.writeln("  load into existing with offset: ", v2);
    }
    testInner(vector(int(8), 16));
    testInner(vector(int(8), 32));
  }
}

UnitTest.main();
