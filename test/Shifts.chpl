use CVL;
use UnitTest;
use TestHelpers;


proc Test.assertEqual(actual: vector(?),
                      expected: vector(?), msg: string) throws {
  if actual.type != expected.type {
    const s =
      "%? - '%?' and '%?' are not of same type"
      .format(msg, toHex(actual), toHex(expected));
    throw new TestError.AssertionError(s);
  }
  for param i in 0..#actual.numElts {
    if toHex(actual[i]) != toHex(expected[i]) {
      const s =
        "%? - '%?' and '%?' differ at index %i"
        .format(msg, toHex(actual), toHex(expected), i);
      throw new TestError.AssertionError(s);
    }
  }
}

proc Test.assertEqual(actual, expected, msg: string) throws {
  if actual != expected {
    const s = "%? - '%?' and '%?' differ"
              .format(msg, toHex(actual), toHex(expected));
    throw new TestError.AssertionError(s);
  }
}

proc iTy(type t: vector(?)) type {
  return int(numBits(t.eltType));
}
proc uTy(type t: vector(?)) type {
  return uint(numBits(t.eltType));
}

proc getVal(type t, val) {
  if isSubtype(t, vector(?)) {
    if isRealType(t.eltType) {
      return (val:uint(numBits(t.eltType))).transmute(t.eltType):t;
    } else if isReal(val) {
      return val.transmute(uint(numBits(t.eltType))):t;
    } else {
      return val:t.eltType:t;
    }
  } else {
    if isRealType(t) {
      return (val:uint(numBits(t))).transmute(t);
    } else if isReal(val) {
      return val.transmute(uint(numBits(t))):t;
    } else {
      return val:t;
    }
  }
}

proc testShiftImm(test: borrowed Test) throws {

  proc t1(type t) throws {
    const v = getVal(t, 0x70);
    const exp_left_shift_4 = getVal(t, 0x700);
    const exp_right_shift_4 = getVal(t, 0x7);
    const exp_right_shift_4_arith = getVal(t, 0x7);

    test.assertEqual(v << 4, exp_left_shift_4, "left shift by 4 failed");
    var tmp = v;
    tmp <<= 4;
    test.assertEqual(tmp, exp_left_shift_4, "left shift by 4 failed");

    test.assertEqual(v >> 4, exp_right_shift_4, "right shift by 4 failed");
    tmp = v;
    tmp >>= 4;
    test.assertEqual(tmp, exp_right_shift_4, "right shift by 4 failed");

    test.assertEqual(v.shiftLeft(4), exp_left_shift_4,
                     "left shift by 4 failed");
    test.assertEqual(v.shiftRight(4), exp_right_shift_4,
                     "right shift by 4 failed");
    test.assertEqual(v.shiftRightArith(4), exp_right_shift_4_arith,
                     "right shift arithmetic by 4failed");
  }
  proc t2(type t) throws {
    const v = min(t);
    const min_val = min(t.eltType);
    const exp_left_shift_1 = getVal(t, getVal(iTy(t), min_val) << 1);
    // Chapel shifts are arithmetic on signed values
    const exp_right_shift_1_arith = getVal(t, getVal(iTy(t), min_val) >> 1);
    const exp_right_shift_1 = getVal(t, getVal(uTy(t), min_val) >> 1);

    test.assertEqual(v << 1, exp_left_shift_1, "left shift by 1 failed");
    var tmp = v;
    tmp <<= 1;
    test.assertEqual(tmp, exp_left_shift_1, "left shift by 1 failed");

    test.assertEqual(v >> 1, exp_right_shift_1, "right shift by 1 failed");
    tmp = v;
    tmp >>= 1;
    test.assertEqual(tmp, exp_right_shift_1, "right shift by 1 failed");

    test.assertEqual(v.shiftLeft(1), exp_left_shift_1,
                     "left shift by 1 failed");
    test.assertEqual(v.shiftRight(1), exp_right_shift_1,
                     "right shift by 1 failed");
    test.assertEqual(v.shiftRightArith(1), exp_right_shift_1_arith,
                     "right shift arithmetic by 1 failed");
  }
  proc tests(type t) throws {
    t1(t);
    t2(t);
  }

  tests(vector(int(8), 16));
  tests(vector(int(16), 8));
  tests(vector(int(32), 4));
  tests(vector(int(64), 2));
  // tests(vector(uint(8), 16));
  // tests(vector(uint(16), 8));
  // tests(vector(uint(32), 4));
  // tests(vector(uint(64), 2));
  tests(vector(real(32), 4));
  tests(vector(real(64), 2));

  tests(vector(int(8), 32));
  tests(vector(int(16), 16));
  tests(vector(int(32), 8));
  tests(vector(int(64), 4));
  // tests(vector(uint(8), 32));
  // tests(vector(uint(16), 16));
  // tests(vector(uint(32), 8));
  // tests(vector(uint(64), 4));
  tests(vector(real(32), 8));
  tests(vector(real(64), 4));

}

proc testShiftVec(test: borrowed Test) throws {

  proc t1(type t, initial) throws {
    var base = initial:t.eltType;
    var v = base:t;
    var amt: t;
    for param i in 0..#t.numElts {
      amt.set(i, getVal(t.eltType, ((i % (numBits(t.eltType)-1))+1)));
    }

    {
      writeln("shifting ", toHex(v), " left by ", toHex(amt));
      var tmp = v.shiftLeft(amt);
      writeln(" result: ", toHex(tmp));
      for param i in 0..#t.numElts {
        const expected = base << amt[i];
        test.assertEqual(tmp[i], expected,
                         "left shift by vector failed at index "+i:string);
      }
    }

    {
      writeln("shifting ", toBin(v), " right by ", toBin(amt));
      var tmp = v.shiftRight(amt);
      writeln(" result: ", toBin(tmp));
      for param i in 0..#t.numElts {
        const expected = (getVal(uTy(t), base) >> amt[i]):t.eltType;
        test.assertEqual(tmp[i], expected,
                         "right shift by vector failed at index "+i:string);
      }
    }

    {
      writeln("shifting ", toHex(v), " right arith by ", toHex(amt));
      var tmp = v.shiftRightArith(amt);
      writeln(" result: ", toHex(tmp));
      for param i in 0..#t.numElts {
        const expected = (getVal(iTy(t), base) >> amt[i]):t.eltType;
        test.assertEqual(
          tmp[i], expected,
          "right shift arithmetic by vector failed at index "+i:string);
      }
    }

    {
      writeln("shifting ", toHex(v), " left by ", toHex(amt), " using <<=");
      var tmp = v;
      tmp <<= amt;
      writeln(" result: ", toHex(tmp));
      for param i in 0..#t.numElts {
        const expected = base << amt[i];
        test.assertEqual(tmp[i], expected,
                         "left shift by vector failed at index "+i:string);
      }
    }

    {
      writeln("shifting ", toHex(v), " right by ", toHex(amt), " using >>=");
      var tmp = v;
      tmp >>= amt;
      writeln(" result: ", toHex(tmp));
      for param i in 0..#t.numElts {
        const expected = (getVal(uTy(t), base) >> amt[i]):t.eltType;
        test.assertEqual(tmp[i], expected,
                         "right shift by vector failed at index "+i:string);
      }
    }

    {
      writeln("shifting ", toHex(v), " left by ", toHex(amt),
              " using <<");
      var tmp = v << amt;
      writeln(" result: ", toHex(tmp));
      for param i in 0..#t.numElts {
        const expected = (getVal(uTy(t), base) << amt[i]):t.eltType;
        test.assertEqual(tmp[i], expected,
                         "right shift by vector failed at index "+i:string);
      }
    }

    {
      writeln("shifting ", toHex(v), " right by ", toHex(amt),
              " using >>");
      var tmp = v >> amt;
      writeln(" result: ", toHex(tmp));
      for param i in 0..#t.numElts {
        const expected = (getVal(uTy(t), base) >> amt[i]):t.eltType;
        test.assertEqual(tmp[i], expected,
                         "right shift by vector failed at index "+i:string);
      }
    }
  }

  proc tests(type t) throws {
    t1(t, 0x18);
    t1(t, min(t.eltType));
    t1(t, max(t.eltType));
  }

  tests(vector(int(8), 16));
  tests(vector(int(16), 8));
  tests(vector(int(32), 4));
  tests(vector(int(64), 2));
  // tests(vector(uint(8), 16));
  // tests(vector(uint(16), 8));
  // tests(vector(uint(32), 4));
  // tests(vector(uint(64), 2));

  tests(vector(int(8), 32));
  tests(vector(int(16), 16));
  tests(vector(int(32), 8));
  tests(vector(int(64), 4));
  // tests(vector(uint(8), 32));
  // tests(vector(uint(16), 16));
  // tests(vector(uint(32), 8));
  // tests(vector(uint(64), 4));

}


UnitTest.main();

