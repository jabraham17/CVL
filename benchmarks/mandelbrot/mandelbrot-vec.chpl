// NOTE: this does not output the correct image yet.
use DynamicIters, IO, Math, CVL;

config const n = 200,             // image size in pixels (n x n)
             maxIter = 50,        // max # of iterations per pixel
             limit = 4.0,         // per-pixel convergence limit
             chunkSize = 1,       // dynamic iterator's chunk size
             outFile = "mandelbrot.pbm"; // output file name

param bitsPerElt = 8;             // # of bits to store per array element
type eltType = uint(bitsPerElt);  // element type used to store the image

type VT = vector(real, 4);

proc main() {
  var of: fileWriter(?);
  if outFile == '-' then
    of = stdout;
  else
    of = openWriter(outFile);
  const xsize = divCeilPos(n, bitsPerElt),  // the compacted x dimension
        imgSpace = {0..#n, 0..#xsize};      // the compacted image size

  var image: [imgSpace] eltType;            // the compacted image
      // xval, yval: [0..#n] real;             // pre-computed (x,y) values

  // precompute (x, y) values from the complex plane
  const inv = new VT(2.0 / n);
  const one = new VT(1.0);
  const onePointFive = new VT(1.5);
  const baseInc = new VT((0, 1, 2, 3));
  const baseInc2 = new VT((4, 5, 6, 7));
  // forall i in 0..#n {
    // xval[i] = inv*i - 1.5;
    // yval[i] = inv*i - 1.0;
  // }

  const two = new VT(2.0);
  const limitVec = new VT(limit);

  // compute the image
  forall (y, xelt) in dynamic(imgSpace, chunkSize) {
    const xbase = xelt*bitsPerElt;
    const xbaseVec = new VT(xbase);
    var cr_low = inv * (xbaseVec + baseInc) - onePointFive;
    var cr_high = inv * (xbaseVec + baseInc2) - onePointFive;
    var ci = new VT(inv*y - 1.0);

    var Zr_low, Zr_high,
        Zi_low, Zi_high,
        Tr_low, Tr_high,
        Ti_low, Ti_high: VT;

    for 1..maxIter {                      // for the max # of iterations
      Zi_low = two*Zr_low*Zi_low + ci;// update Z and T
      Zi_high = two*Zr_high*Zi_high + ci;
      Zr_low = Tr_low - Ti_low + cr_low;
      Zr_high = Tr_high - Ti_high + cr_high;
      Tr_low = Zr_low*Zr_low;
      Tr_high = Zr_high*Zr_high;
      Ti_low = Zi_low*Zi_low;
      Ti_high = Zi_high*Zi_high;

      if (Tr_low + Ti_low <= limitVec).isZero() &&
         (Tr_high + Ti_high <= limitVec).isZero() then
        break;
    }

    // store 'bitsPerElt' pixels compactly into the final image
    var pixval: eltType;
    var mask_low =
      (Tr_low + Ti_low <= limitVec).transmute(vector(int(64), 4));
    var mask_high =
      (Tr_high + Ti_high <= limitVec).transmute(vector(int(64), 4));

    // TODO: this extract is going to be slow
    for param i in 0..#mask_low.numElts {
      if mask_low(i) then      // if 'C' is within the limit,
        pixval |= 0x1 << (bitsPerElt-i-1);  // turn the corresponding pixel on
    }
    for param i in 0..#mask_high.numElts {
      if mask_high(i) then      // if 'C' is within the limit,
        pixval |= 0x1 << (bitsPerElt-i-1-4);  // turn the corresponding pixel on
    }
    // var moveMask_low = mask_low.moveMask():eltType;
    // var moveMask_high = mask_high.moveMask():eltType;
    // pixval |= moveMask_low << 4 | moveMask_high;
    // pixval |= mask_low(0):eltType | mask_high(0):eltType;

    image[y, xelt] = pixval;
  }

  // Write the file header and the image array.
  of.writef("P4\n");
  of.writef("%i %i\n", n, n);
  of.writeBinary(image);
}

//
// Helper function to compare an 8-tuple and a singleton
//
inline operator >(xs, y) {
  for x in xs do
    if x <= y then
      return false;
  return true;
}
