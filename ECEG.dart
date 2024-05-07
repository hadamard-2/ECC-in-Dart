import 'dart:math';

import 'elliptic_curve.dart';

void main(List<String> args) {
  // Public Info
  var ec = EllipticCurve(a: 0, b: 253, p: 257);

  Random rand = Random.secure();
  // Alice
  var alicePrivateKey = ec.order;
  var alicePublicKey = ec.scalarMultiply(alicePrivateKey, ec.generatorPoint);

  // Bob
  var bobPrivateKey = rand.nextInt(ec.order);
  var bobPublicKey = ec.scalarMultiply(bobPrivateKey, ec.generatorPoint);

  // Alice Encrypting Her Message
  var plaintextAlice = ec.pointsOnCurve.toList()[rand.nextInt(ec.order)];
  var ciphertext1 = alicePublicKey;
  var ciphertext2 =
      ec.add(plaintextAlice, ec.scalarMultiply(alicePrivateKey, bobPublicKey));

  var ciphertext = (ciphertext1, ciphertext2);

  // Bob Decrypting Alice's Ciphertext
  var plaintextBob = ec.subtract(
      ciphertext.$2, ec.scalarMultiply(bobPrivateKey, ciphertext.$1));

  print("Message Alice Sent: $plaintextAlice");
  print("Message Bob Received: $plaintextBob");
}
