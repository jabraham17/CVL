config const iterations = 100;
config const clusters = 3;
config const n = 0;

record pointsList {
  type T;
  const D: domain(1);
  var x: [D] T;
  var y: [D] T;
  var clusterId: [D] int;
  var minDist: [D] T;

  proc init(x: [], y: []) {
    this.T = x.eltType;
    this.D = x.domain;
    this.x = x;
    this.y = y;
  }
  proc init(type T, N: int) {
    this.T = T;
    this.D = {0..<N};
  }
}

inline proc distance(const ref p1, i1: int, const ref p2, i2: int): p1.T {
  return sqrt((p1.x[i1] - p2.x[i2])**2 + (p1.y[i1] - p2.y[i2])**2);
}

proc readCSV(filename: string, type eltType) {
  use IO;
  // var data: [1..numCols] eltType;
  const file = openReader(filename);
  const lines = file.lines();

  const numCols = lines(0).count(',') + 1;
  if numCols != 2 then
    halt("Expected 2 columns in input data");

  var x, y: [0..#lines.size] eltType;
  forall i in 0..#lines.size {
    const line = lines(i);
    const parts = line.split(',');
    x[i] = parts(0):eltType;
    y[i] = parts(1):eltType;
  }

  return (x, y);
}

proc kmeans(ref points: pointsList(?)) {
  use Random;
  var rs = new randomStream(points.T);

  const numPoints = points.D.size;

  var centroids = new pointsList(points.T, clusters);
  for i in centroids.D {
    centroids.x[i] = (rs.next():int % numPoints):points.T;
    centroids.y[i] = (rs.next():int % numPoints):points.T;
  }

  for 1..iterations {

    for cIdx in centroids.D {
      forall pIdx in points.D  with (ref points) {
        const dist = distance(points, pIdx, centroids, cIdx);
        if dist < points.minDist[pIdx] {
          points.minDist[pIdx] = dist;
          points.clusterId[pIdx] = cIdx;
        }
      }
    }


    var nPoints: [centroids.D] int = 0;
    var sumX: [centroids.D] points.T = 0;
    var sumY: [centroids.D] points.T = 0;

    for pIdx in points.D {
      const cIdx = points.clusterId[pIdx];
      nPoints[cIdx] += 1;
      sumX[cIdx] += points.x[pIdx];
      sumY[cIdx] += points.y[pIdx];

      points.minDist[pIdx] = +inf;
    }

    for cIdx in centroids.D {
      if nPoints[cIdx] > 0 {
        centroids.x[cIdx] = sumX[cIdx] / nPoints[cIdx];
        centroids.y[cIdx] = sumY[cIdx] / nPoints[cIdx];
      }
    }
  }
}

proc writeCSV(filename: string, points: pointsList(?)) {
  use IO;
  const file = openWriter(filename);
  for i in points.D {
    file.writeln(points.x[i], ",", points.y[i], ",", points.clusterId[i]);
  }
}

proc main() {
  use Time;

  var points;
  if n <= 0 {
    const data = readCSV("points.csv", real);
    points = new pointsList(data[0], data[1]);
  } else {
    use Random;
    var x, y: [0..#n] real;
    forall i in 0..#n with (var rs = new randomStream(real)) {
      x[i] = rs.next(-100, 100);
      y[i] = rs.next(-100, 100);
    }
    points = new pointsList(x, y);
  }
  points.minDist = +inf;

  var s = new stopwatch();
  s.start();
  kmeans(points);
  s.stop();

  writeln("KMeans took ", s.elapsed(), " seconds");

  writeCSV("clusters.csv", points);
}
