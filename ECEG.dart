import 'elliptic_curve.dart';

void main(List<String> args) {
  // Public Info
  var ec = EllipticCurve(0, -4, 257);
  var generator = Point(2, 2);

  // Alice
  var alicePrivateKey = 41;
  var alicePublicKey = ec.scalarMultiply(alicePrivateKey, generator);

  // Bob
  var bobPrivateKey = 101;
  var bobPublicKey = ec.scalarMultiply(bobPrivateKey, generator);

  // Alice Encrypting Her Message
  var plaintextAlice = Point(122, 26);
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
