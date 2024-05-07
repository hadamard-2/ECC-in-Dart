import 'dart:math';

import 'elliptic_curve.dart';

void main(List<String> args) {
  // Public Info
  var ec = EllipticCurve(a: 0, b: -4, p: 211);

  Random rand = Random.secure();
  // Alice
  var alicePrivateKey = rand.nextInt(ec.order - 1) + 1;
  var alicePublicKey = ec.scalarMultiplyGenerator(alicePrivateKey);

  // Bob
  var bobPrivateKey = rand.nextInt(ec.order - 1) + 1;
  var bobPublicKey = ec.scalarMultiplyGenerator(bobPrivateKey);

  // Shared Secret Key
  var sharedSecretKeyAlice = ec.scalarMultiply(alicePrivateKey, bobPublicKey);
  var sharedSecretKeyBob = ec.scalarMultiply(bobPrivateKey, alicePublicKey);

  print("Shared Secret Key with Alice: $sharedSecretKeyAlice");
  print("Shared Secret Key with Bob: $sharedSecretKeyBob");
}
