import 'dart:math' as math;

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Point)
      throw ArgumentError(
          "Unsupported operand type for ==: ${other.runtimeType}");

    return x == other.x && y == other.y;
  }

  @override
  String toString() {
    return "($x, $y)";
  }
}

class EllipticCurve {
  int a;
  int b;
  // I think p has to be a prime number greater than 3
  // (if so I have to check the primality of p in testEllipticCurve)
  int p;

  EllipticCurve(this.a, this.b, this.p) {
    if (!testEllipticCurve(a, b)) {
      throw ArgumentError(
          '''The given values for a & b do not satisfy, the following condition: 
      (4 * a^3 + 27 * b^2) mod p != 0 mod p
      Please, choose different values.''');
    }
  }

  bool testEllipticCurve(int a, int b) {
    return (4 * math.pow(a, 3) + 27 * math.pow(b, 2)) % p != 0;
  }

  bool testPoint(Point point) {
    return math.pow(point.y, 2) == (math.pow(point.x, 3) + a * point.x + b);
  }

  int computeChordSlope(Point point1, Point point2) {
    int numerator = (point2.y - point1.y) % p;
    int denominator = (point2.x - point1.x) % p;

    return numerator * computeModularInverse(denominator, p);
  }

  int computeTangentSlope(Point point) {
    int numerator = ((3 * math.pow(point.x, 2) as int) + a) % p;
    int denominator = (2 * point.y) % p;

    return numerator * computeModularInverse(denominator, p);
  }

  int computeX3(int slope, int x1, int x2) {
    return ((math.pow(slope, 2) as int) - (x1 + x2)) % p;
  }

  int computeY3(int slope, Point point1, int x3) {
    return (slope * (point1.x - x3) - point1.y) % p;
  }

  Point add(Point point1, point2) {
    if (point1 == point2) {
      return double(point1);
    }

    int slope = computeChordSlope(point1, point2);
    int x3 = computeX3(slope, point1.x, point2.x);
    int y3 = computeY3(slope, point1, x3);

    return Point(x3, y3);
  }

  Point double(Point point) {
    int slope = computeTangentSlope(point);
    int x3 = computeX3(slope, point.x, point.x);
    int y3 = computeY3(slope, point, x3);

    return Point(x3, y3);
  }

  Point scalarMultiplication(int num, Point point) {
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
}
