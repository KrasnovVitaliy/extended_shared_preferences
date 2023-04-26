import 'package:encrypt/encrypt.dart';

String decrypt({required String key, required String encryptedData}) {
  final cipherKey = Key.fromUtf8(key);
  final encryptService = Encrypter(AES(cipherKey, mode: AESMode.cbc)); //Using AES CBC encryption
  final initVector = IV.fromUtf8(
      key.substring(0, 16)); //Here the IV is generated from key. This is for example only. Use some other text or random data as IV for better security.

  return encryptService.decrypt(Encrypted.from64(encryptedData), iv: initVector);
}

String encrypt({required String key, required String plainData}) {
  final cipherKey = Key.fromUtf8(key);
  final encryptService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(
      key.substring(0, 16)); //Here the IV is generated from key. This is for example only. Use some other text or random data as IV for better security.

  Encrypted encryptedData = encryptService.encrypt(plainData, iv: initVector);
  return encryptedData.base64;
}
