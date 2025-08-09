
use Math, Random, Time, CVL, CTypes;

record vec3d_array {
  type T;
  param N;
  const D: domain(N);
  var x: [D] T;
  var y: [D] T;
  var z: [D] T;
  proc init(type T, param N) {
    this.T = T;
    this.N = N;
  }
  proc init(type T, D: domain(?)) {
    this.T = T;
    this.N = D.rank;
    this.D = D;
  }
  proc init(D: domain(?), x: ?t, y: t, z: t) {
    this.T = t;
    this.N = D.rank;
    this.D = D;
    this.x = x;
    this.y = y;
    this.z = z;
  }
  proc init(type T, D: domain(?), x: T, y: T, z: T) {
    this.T = T;
    this.N = D.rank;
    this.D = D;
    this.x = x;
    this.y = y;
    this.z = z;
  }

  proc init=(in other: vec3d_array(?T, ?N)) {
    this.T = other.T;
    this.N = other.N;
    this.D = other.D;
    this.x = other.x;
    this.y = other.y;
    this.z = other.z;
  }
  operator =(ref lhs: vec3d_array(?T, ?N), rhs: vec3d_array(T, N)) {
    lhs.x = rhs.x;
    lhs.y = rhs.y;
    lhs.z = rhs.z;
  }
}

operator /=(ref a: vec3d_array(?T, ?N), b: vec3d_array(T, N)) {
  a.x /= b.x;
  a.y /= b.y;
  a.z /= b.z;
}
operator /=(ref a: vec3d_array(?T, ?N), b: [] T) {
  a.x /= b;
  a.y /= b;
  a.z /= b;
}
operator /(a: vec3d_array(?T, ?N), b: vec3d_array(T, N)): vec3d_array(T, N) {
  return new vec3d_array(T, a.D, a.x / b.x, a.y / b.y, a.z / b.z);
}
operator /(a: vec3d_array(?T, ?N), b: [] T): vec3d_array(T, N) {
  return new vec3d_array(T, a.D, a.x / b, a.y / b, a.z / b);
}


proc dotProd(a: vec3d_array(?T, ?N), b: vec3d_array(T, N)): [] T {
  var result: [a.D] T;
  forall i in a.D {
    result[i] = a.x[i] * b.x[i] + a.y[i] * b.y[i] + a.z[i] * b.z[i];
  }
  return result;
}

proc magnitude(a: vec3d_array(?T, ?N)): [] T {
  var result: [a.D] T;
  forall i in a.D {
    result[i] = sqrt(a.x[i] * a.x[i] + a.y[i] * a.y[i] + a.z[i] * a.z[i]);
  }
  return result;
}

proc flux(field: vec3d_array(?T, ?N), normal: vec3d_array(T, N), area: [] T): [] T {
  return dotProd(field, normal) * area;
}


record plane {
  type T;
  const D: domain(2);
  var fields: vec3d_array(T, 2);
  var normals: vec3d_array(T, 2);

  proc init(type T, n: int, m: int) {
    this.T = T;
    this.D = {1..n, 1..m};
    this.fields = new vec3d_array(T, D);
    this.normals = new vec3d_array(T, D);
  }
  proc ref fill(seed: int = 0) {

    inline proc getStream() do
      return if seed == 0 then new randomStream(T)
                          else new randomStream(T, seed);

    forall (i, j) in D with (var rs = getStream()) {
      fields.x[i, j] = rs.next();
      fields.y[i, j] = rs.next();
      fields.z[i, j] = rs.next();
      normals.x[i, j] = rs.next();
      normals.y[i, j] = rs.next();
      normals.z[i, j] = rs.next();
    }

    // Normalize normals
    const mag = magnitude(normals);
    normals /= mag;
    // const normalized = normals / mag;
    // normals = normalized;

  }

  proc totalFlux(type VT) {
    var sum: VT;
    const area = new VT(1.0);
    const r = 0..<(D.dim(0).size * D.dim(1).size);
    forall i in VT.indices(r) with (+ reduce sum) {
      // dotProd(field, normal) * area;
      const FIELD_X = VT.load(c_ptrTo(fields.x), i);
      const FIELD_Y = VT.load(c_ptrTo(fields.y), i);
      const FIELD_Z = VT.load(c_ptrTo(fields.z), i);
      const NORMAL_X = VT.load(c_ptrTo(normals.x), i);
      const NORMAL_Y = VT.load(c_ptrTo(normals.y), i);
      const NORMAL_Z = VT.load(c_ptrTo(normals.z), i);

      const DOT = FIELD_X * NORMAL_X + FIELD_Y * NORMAL_Y + FIELD_Z * NORMAL_Z;
      sum += DOT * area;
    }
    // there are 4 element in VT
    var t0 = pairwiseAdd(sum, sum);
    var t1 = swapLowHigh(t0);
    var t2 = pairwiseAdd(t0, t1);
    return t2(0);
  }
}

config type T = real;
config const n = 10;
config const m = 10;
config const print = false;
config const timing = false;
config const iterations = 1;
config const seed = 0;

type VT = vector(T, 4);

proc main() {

  var planes = [1..iterations] new plane(T, n, m);
  forall p in planes {
    p.fill(seed);
  }
  var fluxes: [1..iterations] T;

  var s = new stopwatch();
  s.start();
  for i in 1..iterations {
    fluxes[i] = planes[i].totalFlux(VT);
  }
  s.stop();

  if print {
    writeln("Total Fluxes: ", + reduce fluxes);
  }
  if timing {
    writeln("Time taken: ", s.elapsed());
  }

}
