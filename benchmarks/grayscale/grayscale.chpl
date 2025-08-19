use Image, CVL, Time;

enum Benchmark {
  ScalarFloat,
  ScalarInt,
  VectorFloat,
  VectorInt,
}

const floatConstants: 3*real(32) =
  (0.29891:real(32), 0.58661:real(32), 0.11448:real(32));

const intConstants1: 3*uint(16) = (66:uint(16), 129:uint(16), 25:uint(16));
const intConstants2: 3*uint(16) = (129:uint(16), 0:uint(16), 128:uint(16));

inline proc convertPixelToGrayscaleFloat(pixel: uint(32)): uint(8) {
  const r = pixel & 0xFF,
        g = (pixel & 0xFF00),
        b = (pixel & 0xFF0000);

  const rS = r * floatConstants[0],
        gS = g * (floatConstants[1] / 256.0:real(32)),
        bS = b * (floatConstants[2] / 65536.0:real(32));

  return (rS + gS + bS): uint(8);
}

inline proc convertPixelToGrayscaleInt(pixel: uint(32)): uint(8) {
  const r = (pixel & 0xFF):uint(16),
        g = ((pixel >> 8) & 0xFF):uint(16),
        b = ((pixel >> 16) & 0xFF):uint(16);

  const rS = (intConstants1[0] * r + intConstants2[0]),
        gS = (intConstants1[1] * g + intConstants2[1]),
        bS = (intConstants1[2] * b + intConstants2[2]);

  return ((rS + gS + bS) >> 8):uint(8) + 16;
}

proc convertToGrayscale(
  param benchmark: Benchmark,
  img: [] uint(32),
  ref res: [] uint(8)
) where benchmark == Benchmark.ScalarFloat {
  forall (pixel, resPixel) in zip(img, res) {
    resPixel = convertPixelToGrayscaleFloat(pixel);
  }
}

proc convertToGrayscale(
  param benchmark: Benchmark,
  img: [] uint(32),
  ref res: [] uint(8)
) where benchmark == Benchmark.ScalarInt {
  forall (pixel, resPixel) in zip(img, res) {
    resPixel = convertPixelToGrayscaleInt(pixel);
  }
}

proc convertToGrayscale(
  param benchmark: Benchmark,
  img: [] uint(32),
  ref res: [] uint(8)
) where benchmark == Benchmark.VectorFloat {

  const rMask = (new vector(int(32), 8, 0xFF:int(32))),
        gMask = (new vector(int(32), 8, 0xFF00:int(32))),
        bMask = (new vector(int(32), 8, 0xFF0000:int(32)));
  const floatVecConstants = (
    new vector(real(32), 8, floatConstants[0]),
    new vector(real(32), 8, floatConstants[1] / 256.0:real(32)),
    new vector(real(32), 8, floatConstants[2] / 65536.0:real(32)));
  inline proc toGrayscale(v) {
    const r = (v & rMask).convert(vector(real(32), 8)),
          g = (v & gMask).convert(vector(real(32), 8)),
          b = (v & bMask).convert(vector(real(32), 8));
    var res = r * floatVecConstants[0];
    res = fma(g, floatVecConstants[1], res);
    res = fma(b, floatVecConstants[2], res);

    return res.convert(vector(int(32), 8));
  }

  inline proc packTo16(v1, v2) {
    const t0 = v1.transmute(vector(int(16), 16)),
          t1 = v2.transmute(vector(int(16), 16));
    const res = deinterleaveLower(t0, t1);
    return res;
  }
  inline proc packTo8(v1, v2) {
    const t0 = v1.transmute(vector(int(8), 32)),
          t1 = v2.transmute(vector(int(8), 32));
    const res = deinterleaveLower(t0, t1);
    return res;
  }

  ref img1D = reshape(img, {0..#img.size});
  ref res1D = reshape(res, {0..#res.size});
  param chunk = 32;
  const iters = img.size / chunk;
  const rem = img.size % chunk;

  use CTypes;
  var img1dPtr = c_ptrTo(img1D):c_ptr(int(32));
  var res1dPtr = c_ptrTo(res1D):c_ptr(int(8));

  forall i in 0.. by chunk # iters {
    const v0 = vector(int(32), 8).load(img1dPtr, i);
    const v1 = vector(int(32), 8).load(img1dPtr, i+8);
    const v2 = vector(int(32), 8).load(img1dPtr, i+16);
    const v3 = vector(int(32), 8).load(img1dPtr, i+24);

    const g0 = toGrayscale(v0);
    const g1 = toGrayscale(v1);
    const g2 = toGrayscale(v2);
    const g3 = toGrayscale(v3);

    const t0 = packTo16(g0, g1);
    const t1 = packTo16(g2, g3);

    const res = packTo8(t0, t1);
    res.store(res1dPtr, i);
  }
  for i in iters*chunk..<img.size {
    const pixel = img1D[i];
    const resPixel = convertPixelToGrayscaleFloat(pixel);
    res1D[i] = resPixel;
  }

}


proc convertToGrayscale(
  param benchmark: Benchmark,
  img: [] uint(32),
  ref res: [] uint(8)
) where benchmark == Benchmark.VectorInt {

  const mask256 = (new vector(int(16), 16, 0xFF:int(16)));
  const sixteen = (new vector(int(8), 32, 16:int(8)));

  inline proc getPackedRed(v1, v2) {
    const t0 = v1.transmute(vector(int(16), 16)),
          t1 = v2.transmute(vector(int(16), 16));
    return deinterleaveLower(t0, t1) & mask256;
  }
  inline proc getPackedGreen(v1, v2) {
    return getPackedRed(v1 >> 8, v2 >> 8) & mask256;
  }
  inline proc getPackedBlue(v1, v2) {
  const t0 = v1.transmute(vector(int(16), 16)),
        t1 = v2.transmute(vector(int(16), 16));
    return deinterleaveUpper(t0, t1) & mask256;
  }
  inline proc packTo8(v1, v2) {
    const t0 = v1.transmute(vector(int(8), 32)),
          t1 = v2.transmute(vector(int(8), 32));
    const res = deinterleaveLower(t0, t1);
    return res;
  }


  ref img1D = reshape(img, {0..#img.size});
  ref res1D = reshape(res, {0..#res.size});
  param chunk = 32;
  const iters = img.size / chunk;
  const rem = img.size % chunk;

  use CTypes;
  var img1dPtr = c_ptrTo(img1D):c_ptr(int(32));
  var res1dPtr = c_ptrTo(res1D):c_ptr(int(8));

  forall i in 0.. by chunk # iters {
    // TODO: clean this up with a helper func
    const v0 = vector(int(32), 8).load(img1dPtr, i);
    const v1 = vector(int(32), 8).load(img1dPtr, i+8);
    const v2 = vector(int(32), 8).load(img1dPtr, i+16);
    const v3 = vector(int(32), 8).load(img1dPtr, i+24);

    const r1 = getPackedRed(v0, v1);
    const g1 = getPackedGreen(v0, v1);
    const b1 = getPackedBlue(v0, v1);

  // TODO: hoist these casts out and splats
    const rS1 = intConstants1[0]:int(16) * r1 + intConstants2[0]:int(16),
          gS1 = intConstants1[1]:int(16) * g1 + intConstants2[1]:int(16),
          bS1 = intConstants1[2]:int(16) * b1 + intConstants2[2]:int(16);

    const sum1 = ((rS1 + gS1 + bS1) >> 8);

    const r2 = getPackedRed(v2, v3);
    const g2 = getPackedGreen(v2, v3);
    const b2 = getPackedBlue(v2, v3);
    const rS2 = intConstants1[0]:int(16) * r2
      + intConstants2[0]:int(16),
          gS2 = intConstants1[1]:int(16) * g2
      + intConstants2[1]:int(16),
          bS2 = intConstants1[2]:int(16) * b2
      + intConstants2[2]:int(16);
    const sum2 = ((rS2 + gS2 + bS2) >> 8);




    const res = packTo8(sum1, sum2) + sixteen;

    res.store(res1dPtr, i);
  }
  

  for i in iters*chunk..<img.size {
    const pixel = img1D[i];
    const resPixel = convertPixelToGrayscaleInt(pixel);
    res1D[i] = resPixel;
  }

}


config const benchmark: Benchmark = Benchmark.ScalarInt;
config const n = 0;
config const timing = true;
config const verify = false;

proc getData() {
  if n <= 0 {
    const img = readImage("input.png", imageType.png);
    return img;
  } else {
    use Random;
    var img: [0..#n, 0..#n] int;
    fillRandom(img, 0, 255);
    return img;
  }
}

proc preprocessData(img: [] int) {
  // turn the image into an array of uint(32)
  var res: [img.domain] uint(32) = img: uint(32);
  return res;
}
proc writeGrayscale(img: [] uint(8)) {
  if n > 0 then return;
  var grayImg: [img.domain] int = img:int | (img: int << 8) | (img: int << 16);
  writeImage("output.png", imageType.png, grayImg);
}


@edition(first="preview")
proc enforceEdition() {}
@edition(last="2.0")
proc enforceEdition() {
  compilerError("This program requires the preview edition for reshape");
}
enforceEdition();

proc main() {
  const img = preprocessData(getData());
  var res: [img.domain] uint(8);

  var timer = new stopwatch();

  select benchmark {
    when Benchmark.ScalarFloat {
      timer.start();
      convertToGrayscale(Benchmark.ScalarFloat, img, res);
      timer.stop();
    }
    when Benchmark.ScalarInt {
      timer.start();
      convertToGrayscale(Benchmark.ScalarInt, img, res);
      timer.stop();
    }
    when Benchmark.VectorFloat {
      timer.start();
      convertToGrayscale(Benchmark.VectorFloat, img, res);
      timer.stop();
    }
    when Benchmark.VectorInt {
      timer.start();
      convertToGrayscale(Benchmark.VectorInt, img, res);
      timer.stop();
    }
  }

  if verify {
    for i in 0..#64 {
      writeln(res[res.domain.orderToIndex(i)]);
    }
  }
  if timing {
    writeln("Time taken: ", timer.elapsed(), " seconds");
  }
  writeGrayscale(res);
}
