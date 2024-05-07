import 'dart:math';
import 'elliptic_curve.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

var ec = EllipticCurve(a: 2, b: 3, p: 17);
var publicKey;

int computeR(int privateKey) {
  var point = ec.scalarMultiply(privateKey, ec.generatorPoint);
  return point.x!;
}

int computeS(int randomNum, int messageDigest, int privateKey, int r) {
  var modularInverse = computeModularInverse(randomNum, ec.order);
  return modularInverse! * (messageDigest + privateKey * r) % ec.order;
}

int hashMessage(String message) {
  var messageBytes = utf8.encode(message);
  var messageDigest = sha256.convert(messageBytes);
  // NOTE - for testing purposes only
  // return BigInt.parse(messageDigest.toString(), radix: 16);
  return 2;
}

(int, int) signMessage(String message) {
  var messageDigest = hashMessage(message);

  var privateKey;
  var r, s;
  var randomNum;
  do {
    privateKey = Random.secure().nextInt(ec.order);
    r = computeR(privateKey);
    if (r != 0) {
      // NOTE - for testing purposes only
      // randomNum = Random.secure().nextInt(ec.order!);
      randomNum = 7;
      s = computeS(randomNum, messageDigest, privateKey, r);
    }
  } while (r == 0 || s == null);

  publicKey = ec.scalarMultiply(privateKey, ec.generatorPoint);

  return (r, s);
}

bool verifySignature(String message, (int, int) signature, Point publicKey) {
  var r = signature.$1, s = signature.$2;
  if (!(1 <= r && r < ec.order) || !(1 <= s && s < ec.order)) return false;

  var messageDigest = hashMessage(message);
  // NOTE - what is s & order of ec aren't coprime???
  var modularInverseOfS = computeModularInverse(s, ec.order);
  var (u1, u2) = (messageDigest * modularInverseOfS!, r * modularInverseOfS);

  var signaturePoint = ec.add(ec.scalarMultiply(u1, ec.generatorPoint),
      ec.scalarMultiply(u2, publicKey));
  if (signaturePoint.isPointAtInfinity) return false;

  var signatureVerificationValue = signaturePoint.x! % ec.order;
  return signatureVerificationValue == r;
}

void main(List<String> args) {

  var message = "Selam Alem";

  // Bob - signer
  var signature = signMessage(message);
  print(signature);

  // Alice - verifier
  var bobSignedIt = verifySignature(message, signature, publicKey);
  print(bobSignedIt ? "It's Bob's Signature!" : "It's not Bob's Signature");
}
