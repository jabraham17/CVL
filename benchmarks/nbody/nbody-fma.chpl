use Math, CVL;

config const n = 10000;       // The number of timesteps to simulate
type vecT = vector(real, 4);
param solarMass = 4 * pi * pi,
      daysPerYear = 365.24;

//
// a record for representing the position, velocity, and mass of
// bodies in the solar system
//
record body {
  var pos: vecT;
  var vel: vecT;
  var mass: real;
  proc init(pos:?=0.0, vel:?=0.0, mass=0.0) {
    this.pos = pos:vecT;
    this.vel = vel:vecT;
    this.mass = mass;
  }
}

var bodies = (/* sun */
              new body(mass = solarMass),

              /* jupiter */
              new body(pos = ( 0.0,
                               4.84143144246472090e+00,
                              -1.16032004402742839e+00,
                              -1.03622044471123109e-01),
                       vel = ( 0.0,
                               1.66007664274403694e-03 * daysPerYear,
                               7.69901118419740425e-03 * daysPerYear,
                              -6.90460016972063023e-05 * daysPerYear),
                      mass =   9.54791938424326609e-04 * solarMass),

              /* saturn */
              new body(pos = ( 0.0,
                               8.34336671824457987e+00,
                               4.12479856412430479e+00,
                              -4.03523417114321381e-01),
                       vel = ( 0.0,
                              -2.76742510726862411e-03 * daysPerYear,
                               4.99852801234917238e-03 * daysPerYear,
                               2.30417297573763929e-05 * daysPerYear),
                      mass =   2.85885980666130812e-04 * solarMass),

              /* uranus */
              new body(pos = ( 0.0,
                               1.28943695621391310e+01,
                              -1.51111514016986312e+01,
                              -2.23307578892655734e-01),
                       vel = ( 0.0,
                               2.96460137564761618e-03 * daysPerYear,
                               2.37847173959480950e-03 * daysPerYear,
                              -2.96589568540237556e-05 * daysPerYear),
                      mass =   4.36624404335156298e-05 * solarMass),

              /* neptune */
              new body(pos = ( 0.0,
                               1.53796971148509165e+01,
                              -2.59193146099879641e+01,
                               1.79258772950371181e-01),
                       vel = ( 0.0,
                               2.68067772490389322e-03 * daysPerYear,
                               1.62824170038242295e-03 * daysPerYear,
                              -9.51592254519715870e-05 * daysPerYear),
                      mass =   5.15138902046611451e-05 * solarMass)
              );

param numBodies = bodies.size,                  // the number of bodies being simulated
      nPairs = numBodies * (numBodies - 1) / 2; // the number of pairs of bodies

proc main() {
  initSun();                      // initialize the sun's velocity

  writef("%.9r\n", energy());     // print the initial energy

  advance(n, 0.01);               // simulate 'n' timesteps

  writef("%.9r\n", energy());     // print the final energy
}


//
// compute the sun's initial velocity
//
proc initSun() {
  var p = 0: vecT;
  for param i in 0..<numBodies {
    p += bodies[i].mass * bodies[i].vel;
  }
  bodies[0].vel = p * (-1.0 / solarMass);
}
//
// advance the positions and velocities of all the bodies
//
proc advance(n, dt: real) {
  param nr = nPairs + 3;
  var r: nr*vecT;
  var w: nr*real;

  r[nr-1] = 1.0:vecT;
  r[nr-2] = 1.0:vecT;
  r[nr-3] = 1.0:vecT;

  const rt = dt: vecT;

  var rm: numBodies*vecT;
  for param i in 0..<numBodies do rm[i] = bodies[i].mass:vecT;

  for 1..n {
    kernel(r, w);

    for param k in 0..<nPairs by vecT.numElts {
      var x = vecT.load(w, k);
      x = ((x * x) * x) * rt;
      x.store(w, k);
    }

    var k = 0;
    for param i in 1..<numBodies {
      for j in 0..<i {
        var t = r[k] * w[k];
        bodies[i].vel -= t * rm[j]; // can't use fms/fma due to precision issues
        bodies[j].vel = fma(t, rm[i], bodies[j].vel);

        k += 1;
      }
    }

    for param i in 0..<numBodies {
      bodies[i].pos = fma(rt, bodies[i].vel, bodies[i].pos);
    }
  }

}


//
// compute the energy of the bodies
//
proc energy() {
  var e = 0.0;

  param nr = nPairs + 3;
  var r: nr*vecT;
  var w: nr*real;

  for param k in 0..<numBodies {
    r[k] = bodies[k].vel * bodies[k].vel;
  }

  for param k in 0..<nPairs by vecT.numElts {
    var t0 = pairwiseAdd(r[k], r[k+1]);
    var t1 = pairwiseAdd(r[k+2], r[k+3]);
    var y0 = blendLowHigh(t0, t1);
    var y1 = swapLowHigh(blendLowHigh(t1, t0));
    var z = y0 + y1;
    z.store(w, k);
  }

  for param k in 0..<numBodies {
    e += 0.5 * bodies[k].mass * w[k];
  }

  r[nr-1] = 1.0:vecT;
  r[nr-2] = r[nr-1];
  r[nr-3] = r[nr-1];

  kernel(r, w);

  var k = 0;
  for param i in 1..<numBodies {
    for j in 0..<i {
      e -= bodies[i].mass * bodies[j].mass * w[k];
      k += 1;
    }
  }

  return e;

}



//
// Do the normal rsqrt, then refine it with Goldschmidt’s algorithm
//
inline proc refine_rsqrt(s: vecT): vecT {

  var x = rsqrt(s);

  var y = s * x * x;
  var a = y * 0.375 * y;
  var b = (y * 1.25) - 1.875;
  y = a - b;
  x *= y;
  return x;
}


//
// rsqrt of the distance between each pair of bodies
//
inline proc kernel(ref r, ref w) {

  var k = 0;
  for param i in 1..<numBodies {
    for j in 0..<i {
      r[k] = bodies[i].pos - bodies[j].pos;
      k += 1;
    }
  }

  for k in 0..<nPairs by vecT.numElts {
    var x0 = r[k]*r[k];
    var x1 = r[k+1]*r[k+1];
    var x2 = r[k+2]*r[k+2];
    var x3 = r[k+3]*r[k+3];

    var t0 = pairwiseAdd(x0, x1);
    var t1 = pairwiseAdd(x2, x3);
    var y0 = blendLowHigh(t0, t1);
    var y1 = swapLowHigh(blendLowHigh(t1, t0));
    var z = y0 + y1;

    z = refine_rsqrt(z);
    z.store(w, k);
  }

}
