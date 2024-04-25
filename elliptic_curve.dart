import 'dart:math' as math;

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  equalTo(Point point) {
    return this.x == point.x && this.y == point.y;
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
      throw ArgumentError('''The given values for a & b do not satisfy: 
      4 * a^3 + 27 * b^2 != 0
      Choose different values.''');
    }
  }

  bool testEllipticCurve(int a, int b) {
    return 4 * math.pow(a, 3) + 27 * math.pow(b, 2) != 0;
  }

  bool testPoint(Point point) {
    return math.pow(point.y, 2) ==
        (math.pow(point.x, 3) + this.a * point.x + this.b);
  }

  int computeChordSlope(Point point1, Point point2) {
    int numerator = (point2.y - point1.y) % this.p;
    int denominator = (point2.x - point1.x) % this.p;

    return numerator * computeModularInverse(denominator, this.p);
  }

  int computeTangentSlope(Point point) {
    int numerator = ((3 * math.pow(point.x, 2) as int) + this.a) % this.p;
    int denominator = (2 * point.y) % this.p;

    return numerator * computeModularInverse(denominator, this.p);
  }

  int computeX3(int slope, int x1, int x2) {
    return ((math.pow(slope, 2) as int) - (x1 + x2)) % this.p;
  }

  int computeY3(int slope, Point point1, int x3) {
    return (slope * (point1.x - x3) - point1.y) % this.p;
  }

  Point add(Point point1, point2) {
    if (point1.equalTo(point2)) {
      return double(point1);
    }

    int slope = this.computeChordSlope(point1, point2);
    int x3 = this.computeX3(slope, point1.x, point2.x);
    int y3 = this.computeY3(slope, point1, x3);

    return Point(x3, y3);
  }

  Point double(Point point) {
    int slope = this.computeTangentSlope(point);
    int x3 = this.computeX3(slope, point.x, point.x);
    int y3 = this.computeY3(slope, point, x3);

    return Point(x3, y3);
  }

  Point scalarMultiplication(int num, Point point) {
    String numInBinary = decimalToBinary(num);
    Point result = point;

    for (int i = 1; i < numInBinary.length; i++) {
      result = this.double(result);
      if (numInBinary[i] == "1") {
        result = this.add(result, point);
      }
    }

    return result;
  }
}

String decimalToBinary(int num) {
  String binary = "";
  int decimal = num;

  do {
    binary += (decimal % 2).toString();
    decimal = (decimal / num) as int;
  } while (decimal != 0);

  return binary;
}

int computeGCD(int num1, num2) {
  var (gcd, _) = EEA(num1, num2);
  return gcd;
}

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

  return (b, t2 % a);
}

void main(List<String> args) {}
