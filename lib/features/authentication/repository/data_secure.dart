import 'package:encrypt/encrypt.dart';

abstract class SecretKey {
  static const key = 'Fcmne8q9hd99a:cndsiu3q_893jkancc';
}

class DataSecurity extends SecretKey {
  String decryptWithAES(Encrypted encryptedData) {
    final cipherKey = Key.fromUtf8(SecretKey.key);
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(cipherKey, mode: AESMode.cbc));

    final decryptor = encryptor.decrypt(encryptedData, iv: iv);

    return decryptor;
  }

  ///Encrypts the given plainText using the key. Returns encrypted data
  Encrypted encryptWithAES(String plainText) {
    final cipherKey = Key.fromUtf8(SecretKey.key);
    final iv = IV.fromLength(16);
    final encryptor = Encrypter(AES(cipherKey, mode: AESMode.cbc));

    final encrypted = encryptor.encrypt(plainText, iv: iv);
    return encrypted;
  }
}
