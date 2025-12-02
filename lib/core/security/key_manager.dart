import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart';

class KeyManager {
  static RSAPublicKey? _publicKey;

  // Fungsi untuk memuat kunci dari aset (Panggil di main.dart)
  static Future<void> loadPublicKey() async {
    try {
      String pem = await rootBundle.loadString('assets/keys/public_key.pem');
      final parser = RSAKeyParser();
      _publicKey = parser.parse(pem) as RSAPublicKey;
      // print("✅ RSA Public Key Loaded Successfully");
    } catch (e) {
      // print("❌ Failed to load RSA Key: $e");
      throw Exception("Kunci RSA tidak ditemukan atau format salah.");
    }
  }

  // Getter untuk dipakai di Interceptor
  static RSAPublicKey get publicKey {
    if (_publicKey == null) {
      throw Exception("RSA Key belum dimuat! Panggil KeyManager.loadPublicKey() di main().");
    }
    return _publicKey!;
  }
}