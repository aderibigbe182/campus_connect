import 'package:encrypt/encrypt.dart';

class EncryptionService {

  static final key =
      Key.fromLength(32);

  static final iv =
      IV.fromLength(16);

  static final encrypter =
      Encrypter(AES(key));

  static String encryptMessage(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }

  static String decryptMessage(String text) {
    return encrypter.decrypt64(text, iv: iv);
  }
}