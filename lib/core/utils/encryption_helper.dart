import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  // 32 chars key for AES-256
  static final _key = Key.fromUtf8('my32charactersecretkey1234567890');
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  /// Mã hóa chuỗi text
  static String encrypt(String text) {
    if (text.isEmpty) return text;
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  /// Giải mã chuỗi text
  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      // Nếu không giải mã được (ví dụ mật khẩu cũ chưa mã hóa), trả về bản gốc
      return encryptedText;
    }
  }
}
