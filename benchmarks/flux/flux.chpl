
use Math, Random, Time;

record vec3d {
  type T;
  var x: T;
  var y: T;
  var z: T;
  proc init(type T) {
    this.T = T;
    x = 0:T;
    y = 0:T;
    z = 0:T;
  }
  proc init(x: ?t, y: t, z: t) {
    this.T = t;
    this.x = x;
    this.y = y;
    this.z = z;
  }
  proc init(type T, x: T, y: T, z: T) {
    this.T = T;
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

operator /(a: vec3d(?T), b: vec3d(T)): vec3d(T) do
  return vec3d(T, a.x / b.x, a.y / b.y, a.z / b.z);
operator /=(a: vec3d(?T), b: vec3d(T)) {
  a.x /= b.x;
  a.y /= b.y;
  a.z /= b.z;
}
operator /(a: vec3d(?T), b: T): vec3d(T) do
  return new vec3d(T, a.x / b, a.y / b, a.z / b);
operator /(a: ?T, b: vec3d(T)): vec3d(T) do
  return new vec3d(T, a / b.x, a / b.y, a / b.z);
operator /=(a: vec3d(?T), b: T) {
  a.x /= b;
  a.y /= b;
  a.z /= b;
}


proc dotProd(a: vec3d(?T), b: vec3d(T)): T {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
proc crossProd(a: vec3d(?T), b: vec3d(T)): vec3d(T) {
  return vec3d(T,
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  );
}

proc magnitude(a: vec3d(?T)): T {
  return sqrt(dotProd(a, a));
}

proc flux(field: vec3d(?T), normal: vec3d(T), area: T): T {
  return dotProd(field, normal) * area;
}


record plane {
  type T;
  var n: int;
  var m: int;
  const D = {1..n, 1..m};
  var fields: [D] vec3d(T);
  var normals: [D] vec3d(T);

  proc init(type T, n: int, m: int) {
    this.T = T;
    this.n = n;
    this.m = m;
  }
  proc ref fill(seed: int = 0) {

    inline proc getStream() do
      return if seed == 0 then new randomStream(T)
                          else new randomStream(T, seed);

    forall (i, j) in D with (var rs = getStream()){
      fields[i, j] = new vec3d(T, rs.next(), rs.next(), rs.next());
      normals[i, j] = new vec3d(T, rs.next(), rs.next(), rs.next());
      var mag = magnitude(normals[i, j]);
      normals[i, j] = normals[i, j] / mag;
    }
  }

  proc totalFlux() {
    const area: T = 1;
    var f: T = + reduce flux(fields, normals, area);
    return f;
  }
}

config type T = real;
config const n = 10;
config const m = 10;
config const print = false;
config const timing = false;
config const iterations = 1;
config const seed = 0;

proc main() {

  var planes = [1..iterations] new plane(T, n, m);
  forall p in planes {
    p.fill(seed);
  }
  var fluxes: [1..iterations] T;

  var s = new stopwatch();
  s.start();
  for i in 1..iterations {
    fluxes[i] = planes[i].totalFlux();
  }
  s.stop();

  if print {
    writeln("Total Fluxes: ", + reduce fluxes);
  }
  if timing {
    writeln("Time taken: ", s.elapsed());
  }

}
