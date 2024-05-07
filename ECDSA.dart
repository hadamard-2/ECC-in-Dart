import 'dart:math';
import 'elliptic_curve.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

// I'm lucky to have found an elliptic curve of prime order randomly
var ec = EllipticCurve(a: 5, b: 7, p: 29);

BigInt hashMessage(String message) {
  var messageBytes = utf8.encode(message);
  var messageDigest = sha256.convert(messageBytes);
  return BigInt.parse(messageDigest.toString(), radix: 16);
}

// NOTE - k & s need to coprime order of the elliptic curve
// k needs to be coprime with order of the elliptic curve for the signing
// s needs to be coprime with order of the elliptic curve for the verification
(int, BigInt) signMessage(String message, int privateKey) {
  var messageDigest = hashMessage(message);

  var r, s, s1, s2;
  var k;
  do {
    k = Random.secure().nextInt(ec.order - 1) + 1;
    r = ec.scalarMultiplyGenerator(k).x;
    if (r != 0) {
      try {
        s1 = BigInt.from(k.modInverse(ec.order));
        s2 = messageDigest + BigInt.from(privateKey * r);
        s = (s1 * s2) % BigInt.from(ec.order);
      } catch (e) {
        print(e);
        s = null;
      }
    }
  } while (r == 0 || s == null);

  return (r, s);
}

bool verifySignature(String message, (int, BigInt) signature, Point publicKey) {
  var r = signature.$1, s = signature.$2;
  if (!(1 <= r && r < ec.order) ||
      !(BigInt.one <= s && s < BigInt.from(ec.order))) return false;

  var messageDigest = hashMessage(message);
  // NOTE - what if s & order of ec aren't coprime???
  var modularInverseOfS;
  try {
    modularInverseOfS = s.modInverse(BigInt.from(ec.order));
  } catch (e) {
    print('''Cannot verify signature because...
multiplicative modular inverse of s: $s modulus order: ${ec.order} doesn't exist!''');
  }
  var (u1, u2) =
      (messageDigest * modularInverseOfS, BigInt.from(r) * modularInverseOfS);

  var signaturePoint = ec.add(ec.scalarMultiply(u1, ec.generatorPoint),
      ec.scalarMultiply(u2, publicKey));
  if (signaturePoint.isPointAtInfinity) return false;

  var signatureVerificationValue = signaturePoint.x! % ec.order;
  return signatureVerificationValue == r;
}

void main(List<String> args) {
  var message = "Selam Alem";

  // Bob - signer
  var privateKey = Random.secure().nextInt(ec.order - 1) + 1;
  var publicKey = ec.scalarMultiplyGenerator(privateKey);

  var signature = signMessage(message, privateKey);

  // Alice - verifier
  var bobSignedIt = verifySignature(message, signature, publicKey);
  print(
      bobSignedIt ? "It's Bob's Signature :)" : "It's not Bob's Signature :(");
}
