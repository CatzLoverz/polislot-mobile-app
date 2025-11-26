import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionInterceptor extends Interceptor {
  static final String _keyString = dotenv.env['API_SECRET_KEY'] ?? '';
  static final String _ivString = dotenv.env['API_SECRET_IV'] ?? '';

  late final Encrypter _encrypter;
  late final IV _iv;

  EncryptionInterceptor() {
    if (_keyString.length != 32 || _ivString.length != 16) {
      throw Exception("Kunci Enkripsi di .env tidak valid (Key harus 32, IV harus 16 char)");
    }
    final key = Key.fromUtf8(_keyString);
    _iv = IV.fromUtf8(_ivString);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }

  // 1. ENKRIPSI REQUEST (Keluar)
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data != null && options.data is Map && 
       (options.method == 'POST' || options.method == 'PUT' || options.method == 'PATCH')) {
      try {
        final jsonString = jsonEncode(options.data);
        final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
        
        options.data = {'payload': encrypted.base64};
      } catch (e) {
        // print("Encryption Failed: $e");
      }
    }
    super.onRequest(options, handler);
  }

  // 2. DEKRIPSI RESPONSE SUKSES (200 OK)
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _decryptResponseData(response);
    super.onResponse(response, handler);
  }

  // 3. ✅ DEKRIPSI RESPONSE ERROR (401, 422, 500) - INI YANG KURANG TADI
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      // Coba dekripsi body error agar pesan aslinya terbaca
      _decryptResponseData(err.response!);
    }
    super.onError(err, handler);
  }

  // 🛠️ Helper Logic Dekripsi
  void _decryptResponseData(Response response) {
    if (response.data is Map && response.data.containsKey('payload')) {
      try {
        final encryptedData = response.data['payload'];
        final decrypted = _encrypter.decrypt64(encryptedData, iv: _iv);
        
        // Ganti data terenkripsi dengan data asli (JSON)
        response.data = jsonDecode(decrypted);
        
        // Debugging (Optional)
        // print("🔓 Decrypted (${response.statusCode}): ${response.data}");
      } catch (e) {
        // print("❌ Decryption Failed for ${response.statusCode}: $e");
      }
    }
  }
}