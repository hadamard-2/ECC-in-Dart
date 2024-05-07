import 'dart:math' as math;

class Point {
  int? x;
  int? y;
  bool _isPointAtInfinity = false;

  Point(this.x, this.y);
  Point.atInfinity() : _isPointAtInfinity = true;

  bool get isPointAtInfinity {
    return _isPointAtInfinity;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Point)
      throw ArgumentError(
          "Unsupported operand type for ==: ${other.runtimeType}");

    return (this.isPointAtInfinity && other.isPointAtInfinity) ||
        x == other.x && y == other.y;
  }

  @override
  int get hashCode {
    if (_isPointAtInfinity) return 0;
    return Object.hash(x, y);
  }

  @override
  String toString() {
    return _isPointAtInfinity ? "O" : "($x, $y)";
  }
}

class EllipticCurve {
  final int a;
  final int b;
  final int p;

  Set<Point>? _pointsOnCurve;
  Point? _generatorPoint;
  int? _order;

  EllipticCurve({required this.a, required this.b, required this.p}) {
    if (!_testEllipticCurve(a, b))
      throw ArgumentError(
          '''The given values for a & b do not satisfy, the following condition: 
      (4 * a^3 + 27 * b^2) mod p != 0 mod p
      Please, choose different values.''');

    _pointsOnCurve = _findPointsOnCurve();
    _order = _computeOrder();
    _generatorPoint = _findGeneratorPoint();

    if (_generatorPoint == null)
      throw ArgumentError(
          "The given elliptic curve doesn't have a generator point hence cannot be used for cryptographic purposes.");
  }

  Set<Point> _findPointsOnCurve() {
    Set<Point> points = {Point.atInfinity()};

    // using the concept of quadratic residues
    int lhs, rhs;
    for (int x = 0; x < p; x++) {
      for (int y = 0; y <= (p - 1) / 2; y++) {
        lhs = (y * y) % p;
        rhs = (math.pow(x, 3).toInt() + a * x + b) % p;
        if (lhs == rhs) points.addAll([Point(x, y % p), Point(x, -y % p)]);
      }
    }

    return points;
  }

  int _orderOfPoint(Point point) {
    if (point.isPointAtInfinity) return -1;

    int orderOfPoint = 1;
    Point nP;
    do {
      orderOfPoint++;
      nP = scalarMultiply(orderOfPoint, point);
    } while (!nP.isPointAtInfinity);

    return orderOfPoint;
  }

  Point? _findGeneratorPoint() {
    for (Point point in _pointsOnCurve!) {
      if (_orderOfPoint(point) == _order) return point;
    }
    return null;
  }

  int _computeOrder() {
    return _pointsOnCurve!.length;
  }

  Set<Point> get pointsOnCurve {
    return _pointsOnCurve!;
  }

  Point get generatorPoint {
    return _generatorPoint!;
  }

  int get order {
    return _order!;
  }

  bool _testEllipticCurve(int a, int b) {
    // NOTE - check if a and b are in the finite field
    // NOTE - check if p is prime
    // NOTE - it should return error code for each type of error
    // NOTE - (a: -1, b: -2, p: -3, discriminant: -4, no error: 0)
    return (4 * math.pow(a, 3) + 27 * math.pow(b, 2)) % p != 0;
  }

  bool testPoint(Point point) {
    return point.isPointAtInfinity ||
        math.pow(point.y!, 2) % p ==
            (math.pow(point.x!, 3) + a * point.x! + b) % p;
  }

  int? _computeChordSlope(Point point1, Point point2) {
    int numerator = (point2.y! - point1.y!) % p;
    int denominator = (point2.x! - point1.x!) % p;
    if (denominator == 0) return null;

    return numerator * computeModularInverse(denominator, p)!;
  }

  int? _computeTangentSlope(Point point) {
    int numerator = ((3 * math.pow(point.x!, 2) as int) + a) % p;
    int denominator = (2 * point.y!) % p;
    if (denominator == 0) return null;

    return numerator * computeModularInverse(denominator, p)!;
  }

  Point add(Point point1, Point point2) {
    if (point1.isPointAtInfinity && point2.isPointAtInfinity)
      return Point.atInfinity();
    else if (point1.isPointAtInfinity)
      return point2;
    else if (point2.isPointAtInfinity) return point1;

    if (point1 == point2) return double(point1);

    final slope = _computeChordSlope(point1, point2);
    if (slope == null) return Point.atInfinity();

    int x3 = ((math.pow(slope, 2) as int) - (point1.x! + point2.x!)) % p;
    int y3 = (slope * (point1.x! - x3) - point1.y!) % p;

    return Point(x3, y3);
  }

  Point subtract(Point point1, Point point2) {
    if (point1.isPointAtInfinity && point2.isPointAtInfinity)
      return Point.atInfinity();
    else if (point1.isPointAtInfinity)
      return Point(point2.x, -point2.y! % p);
    else if (point2.isPointAtInfinity) return point1;

    return add(point1, Point(point2.x, -point2.y! % p));
  }

  Point double(Point point) {
    if (point.isPointAtInfinity) return point;

    int? slope = _computeTangentSlope(point);
    if (slope == null) return Point.atInfinity();

    int x3 = ((math.pow(slope, 2) as int) - (point.x! + point.x!)) % p;
    int y3 = (slope * (point.x! - x3) - point.y!) % p;

    return Point(x3, y3);
  }

  // NOTE - I wanna build a table for this so that it can store values for scalar products
  // if it can find the value in the table it'll return that
  // else, it'll compute the value and store it in the table
  Point scalarMultiply(int num, Point point) {
    if (point.isPointAtInfinity) return point;

    String numInBinary = decimalToBinary(num);
    Point result = point;

    for (int i = 1; i < numInBinary.length; i++) {
      result = double(result);
      if (numInBinary[i] == "1") {
        result = add(result, point);
      }
    }

    return result;
  }

  @override
  String toString() {
    String ellipticCurveStr = "y^2 = x^3";

    ellipticCurveStr += a > 0
        ? " + ${a}x"
        : a < 0
            ? " - ${a.abs()}x"
            : "";
    ellipticCurveStr += b > 0
        ? " + ${b}"
        : b < 0
            ? " - ${b.abs()}"
            : "";
    ellipticCurveStr += "  mod ${p}";

    return ellipticCurveStr;
  }
}

// int? perfectSquareRoot(int num) {
//   double sqrt = math.sqrt(num);
//   int sqrtInt = sqrt.toInt();

//   return sqrt - sqrtInt == 0 ? sqrtInt : null;
// }

String decimalToBinary(int num) {
  String binary = "";
  // because I only care about the magnitude, I'll take the absolute value
  int decimal = num.abs();

  do {
    binary = (decimal % 2).toString() + binary;
    decimal ~/= 2;
  } while (decimal != 0);

  return binary;
}

// int computeGCD(int num1, num2) {
//   var (gcd, _) = EEA(num1, num2);
//   return gcd;
// }

int? computeModularInverse(int base, int modulus) {
  var (gcd, modularInverse) = EEA(modulus, base);
  if (gcd != 1) return null;
  return modularInverse;
}

(int, int) EEA(int num1, int num2) {
  var (a, b) = (num1, num2);
  var (q, r) = (a ~/ b, a % b);
  int t1 = 0, t2 = 1, t3 = -q;

  while (r != 0) {
    (a, b) = (b, r);
    (q, r) = (a ~/ b, a % b);
    (t1, t2) = (t2, t3);
    t3 = t1 - q * t2;
  }

  return (b, t2 % num1);
}

void main(List<String> args) {
  print("Implementing ECC in Dart!!");
  var ec = EllipticCurve(a: 1, b: 0, p: 13);
  // print(ec.order);
  print(ec._findGeneratorPoint());
}
