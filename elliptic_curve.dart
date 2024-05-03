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
  String toString() {
    return _isPointAtInfinity ? "O" : "($x, $y)";
  }
}

class EllipticCurve {
  int a;
  int b;
  // I think p has to be a prime number greater than 3
  // (if so I have to check the primality of p in testEllipticCurve)
  int p;

  EllipticCurve(this.a, this.b, this.p) {
    if (!_testEllipticCurve(a, b)) {
      throw ArgumentError(
          '''The given values for a & b do not satisfy, the following condition: 
      (4 * a^3 + 27 * b^2) mod p != 0 mod p
      Please, choose different values.''');
    }
  }

  bool _testEllipticCurve(int a, int b) {
    return (4 * math.pow(a, 3) + 27 * math.pow(b, 2)) % p != 0;
  }

  bool testPoint(Point point) {
    return point.isPointAtInfinity ||
        math.pow(point.y!, 2) == (math.pow(point.x!, 3) + a * point.x! + b);
  }

  int? _computeChordSlope(Point point1, Point point2) {
    int numerator = (point2.y! - point1.y!) % p;
    int denominator = (point2.x! - point1.x!) % p;
    if (denominator == 0) return null;

    return numerator * computeModularInverse(denominator, p);
  }

  int? _computeTangentSlope(Point point) {
    int numerator = ((3 * math.pow(point.x!, 2) as int) + a) % p;
    int denominator = (2 * point.y!) % p;
    if (denominator == 0) return null;

    return numerator * computeModularInverse(denominator, p);
  }

  int _computeX3(int slope, int x1, int x2) {
    return ((math.pow(slope, 2) as int) - (x1 + x2)) % p;
  }

  int _computeY3(int slope, Point point1, int x3) {
    return (slope * (point1.x! - x3) - point1.y!) % p;
  }

  Point add(Point point1, Point point2) {
    if (point1.isPointAtInfinity && point2.isPointAtInfinity)
      return Point.atInfinity();
    else if (point1.isPointAtInfinity)
      return point2;
    else if (point2.isPointAtInfinity) return point1;

    if (point1 == point2) return double(point1);

    int? slope = _computeChordSlope(point1, point2);
    if (slope == null) return Point.atInfinity();

    int x3 = _computeX3(slope, point1.x!, point2.x!);
    int y3 = _computeY3(slope, point1, x3);

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

    int x3 = _computeX3(slope, point.x!, point.x!);
    int y3 = _computeY3(slope, point, x3);

    return Point(x3, y3);
  }

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

int computeModularInverse(int base, int modulus) {
  var (gcd, modularInverse) = EEA(modulus, base);
  if (gcd != 1) {
    throw ArgumentError(
        "The modular inverse of $base mod $modulus does not exist because they are not coprime.");
  }
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
  var ec = EllipticCurve(0, -4, 257);
  // print(ec.add(Point(246, 174), Point(68, -84)));
  // print(ec.subtract(Point(246, 174), Point(68, 84)));
}
