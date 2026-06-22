import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'auth_service.dart';

class EncryptionService {
  static Key? _encryptionKey;

  /// Initializes the encryption key based on the user's UID.
  /// Must be called after user is logged in / UID is known.
  static Future<void> initialize() async {
    final uid = await AuthService.getUid();
    if (uid != null && uid.isNotEmpty) {
      // Hash the UID to ensure it's exactly 32 bytes for AES-256
      final bytes = utf8.encode(uid);
      final digest = sha256.convert(bytes);
      _encryptionKey = Key(Uint8List.fromList(digest.bytes));
    }
  }

  /// Encrypts a plain text string. Returns base64 encoded string.
  static String encrypt(String plainText) {
    if (_encryptionKey == null || plainText.isEmpty) return plainText;
    try {
      final encrypter = Encrypter(AES(_encryptionKey!));
      final iv = IV.fromSecureRandom(16); // Generate random IV
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // Store IV along with encrypted data (iv:encrypted)
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      return plainText; // Fallback or handle error
    }
  }

  /// Decrypts an encrypted string (iv:encrypted format).
  static String decrypt(String encryptedText) {
    if (_encryptionKey == null || encryptedText.isEmpty || !encryptedText.contains(':')) {
      return encryptedText;
    }
    try {
      final parts = encryptedText.split(':');
      final iv = IV.fromBase64(parts[0]);
      final cipherText = Encrypted.fromBase64(parts[1]);
      
      final encrypter = Encrypter(AES(_encryptionKey!));
      return encrypter.decrypt(cipherText, iv: iv);
    } catch (e) {
      return encryptedText; // Fallback to returning original if decryption fails
    }
  }
}
