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
    if actual[i] != expected[i] {
      const s =
        "%? - '%?' and '%?' differ at index %i"
        .format(msg, toHex(actual), toHex(expected), i);
      throw new TestError.AssertionError(s);
    }
  }
}

proc iTy(type t: vector(?)) type {
  return int(numBits(t.eltType));
}
proc uTy(type t: vector(?)) type {
  return uint(numBits(t.eltType));
}

proc testShift(test: borrowed Test) throws {

  proc t1(type t) throws {
    // TODO: 0xF0 is a param, I should be able to cast it to the vector type
    // directly since I know for certain that it will fit at compile time.
    const v = 0x70:t.eltType:t;
    const exp_left_shift_4 = 0x700:t.eltType:t;
    const exp_right_shift_4 = 0x7:t.eltType:t;
    const exp_right_shift_4_arith = 0x7:t.eltType:t;
    test.assertEqual(v << 4, exp_left_shift_4, "left shift by 4 failed");
    test.assertEqual(v >> 4, exp_right_shift_4, "right shift by 4 failed");

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
    const exp_left_shift_1 = (min_val:iTy(t) << 1):t.eltType:t;
    // Chapel shifts are arithmetic on signed values
    const exp_right_shift_1_arith = (min_val:iTy(t) >> 1):t.eltType:t;
    const exp_right_shift_1 = (min_val:uTy(t) >> 1):t.eltType:t;

    test.assertEqual(v << 1, exp_left_shift_1, "left shift by 1 failed");
    test.assertEqual(v >> 1, exp_right_shift_1, "right shift by 1 failed");

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



UnitTest.main();

