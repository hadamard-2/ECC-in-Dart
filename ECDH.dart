import 'elliptic_curve.dart';

void main(List<String> args) {
  // Public Info
  var ec = EllipticCurve(0, -4, 211);
  var generator = Point(2, 2);

  // Alice
  var alicePrivateKey = 121;
  var alicePublicKey = ec.scalarMultiplication(alicePrivateKey, generator);

  // Bob
  var bobPrivateKey = 203;
  var bobPublicKey = ec.scalarMultiplication(bobPrivateKey, generator);

  // Shared Secret Key
  var sharedSecretKeyAlice =
      ec.scalarMultiplication(alicePrivateKey, bobPublicKey);
  var sharedSecretKeyBob =
      ec.scalarMultiplication(bobPrivateKey, alicePublicKey);

  print("Shared Secret Key with Alice: $sharedSecretKeyAlice");
  print("Shared Secret Key with Bob: $sharedSecretKeyBob");
}
