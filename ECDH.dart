import 'dart:math';

import 'elliptic_curve.dart';

void main(List<String> args) {
  // Public Info
  var ec = EllipticCurve(a: 0, b: -4, p: 211);

  Random rand = Random.secure();
  // Alice
  var alicePrivateKey = rand.nextInt(ec.order);
  var alicePublicKey = ec.scalarMultiply(alicePrivateKey, ec.generatorPoint);

  // Bob
  var bobPrivateKey = rand.nextInt(ec.order);
  var bobPublicKey = ec.scalarMultiply(bobPrivateKey, ec.generatorPoint);

  // Shared Secret Key
  var sharedSecretKeyAlice = ec.scalarMultiply(alicePrivateKey, bobPublicKey);
  var sharedSecretKeyBob = ec.scalarMultiply(bobPrivateKey, alicePublicKey);

  print("Shared Secret Key with Alice: $sharedSecretKeyAlice");
  print("Shared Secret Key with Bob: $sharedSecretKeyBob");
}
