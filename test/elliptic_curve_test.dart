import 'package:test/test.dart';
import '../elliptic_curve.dart';

void main() {
  // tests for computeModularInverse
  group("computeModularInverse tests", () {
    test("test 1", () {
      expect(computeModularInverse(11, 26), 19);
    });

    test("test 2", () {
      expect(computeModularInverse(3, 11), 4);
    });

    test("test 3", () {
      expect(computeModularInverse(10, 17), 12);
    });
  });

  // tests for decimalToBinary
  group("decimalToBinary tests", () {
    test("test 1", () {
      expect(decimalToBinary(26), "11010");
    });

    test("test 2", () {
      expect(decimalToBinary(0), "0");
    });

    test("test 3", () {
      expect(decimalToBinary(-51), "110011");
    });
  });

  // Elliptic Curve operations tests
  var ec = EllipticCurve(4, 3, 17);

  // tests for add
  group("ellipticCurve.add tests", () {
    // but how does test know how to compare two Points, I may have to override its equal to method or sth
    test("test 1", () {
      expect(ec.add(Point(11, 1), Point(2, 6)), Point(2, 11));
    });

    test("test 2", () {
      expect(ec.add(Point(13, 5), Point(4, 7)), Point(16, 7));
    });

    test("test 3", () {
      expect(ec.add(Point(11, 16), Point(14, 10)), Point(13, 5));
    });
  });

  // tests for double
  group("ellipticCurve.double tests", () {
    test("test 1", () {
      expect(ec.double(Point(3, 5)), Point(15, 2));
    });

    test("test 2", () {
      expect(ec.double(Point(4, 7)), Point(11, 1));
    });

    test("test 3", () {
      expect(ec.double(Point(13, 12)), Point(16, 7));
    });
  });

  // tests for scalarMultiplication
  group(
      "ellipticCurve.scalarMultiplication test",
      () => {
            test("test 1", () {
              expect(ec.scalarMultiplication(7, Point(3, 12)), Point(15, 15));
            }),
            test("test 2", () {
              expect(ec.scalarMultiplication(9, Point(4, 7)), Point(2, 6));
            }),
            test("test 3", () {
              expect(ec.scalarMultiplication(3, Point(16, 10)), Point(11, 16));
            }),
          });
}
