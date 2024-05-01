import 'elliptic_curve.dart';

void main(List<String> args) {
  // Public Info
  var ec = EllipticCurve(0, -4, 211);
  var generator = Point(2, 2);

  // Alice
  var alicePrivateKey = 121;
  var alicePublicKey = ec.scalarMultiply(alicePrivateKey, generator);

  // Bob
  var bobPrivateKey = 203;
  var bobPublicKey = ec.scalarMultiply(bobPrivateKey, generator);

  // Shared Secret Key
  var sharedSecretKeyAlice = ec.scalarMultiply(alicePrivateKey, bobPublicKey);
  var sharedSecretKeyBob = ec.scalarMultiply(bobPrivateKey, alicePublicKey);

  print("Shared Secret Key with Alice: $sharedSecretKeyAlice");
  print("Shared Secret Key with Bob: $sharedSecretKeyBob");
}
