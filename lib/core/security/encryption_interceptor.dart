import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' as a;
// import 'package:pointycastle/asymmetric/api.dart';
import 'key_manager.dart';

class EncryptionInterceptor extends Interceptor {
  final _serverPublicKey = KeyManager.publicKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // 1. Generate Kunci Sesi (AES) untuk SETIAP request (GET/POST/dll)
      final sessionKey = _generateRandomString(32);
      final sessionIv = _generateRandomString(16);

      // Simpan di extra untuk dekripsi respon nanti
      options.extra['session_key'] = sessionKey;
      options.extra['session_iv'] = sessionIv;

      // 2. Enkripsi Kunci Sesi pakai RSA
      final rsaEncrypter = Encrypter(RSA(publicKey: _serverPublicKey));
      final sessionData = "$sessionKey|$sessionIv";
      final encryptedSessionKey = rsaEncrypter.encrypt(sessionData).base64;

      // ✅ PINDAHKAN KEY KE HEADER (Agar GET request juga membawanya)
      options.headers['X-Session-Key'] = encryptedSessionKey;

      // 3. SETUP AES ENCRYPTER
      final aesKey = Key.fromUtf8(sessionKey);
      final aesIv = IV.fromUtf8(sessionIv);
      final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));

      // 4. HEADER ENCRYPTION (BEARER TOKEN)
      // Gunakan case-insensitive check
      String? authKey;
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          authKey = key;
        }
      });

      if (authKey != null) {
        final authHeader = options.headers[authKey] as String;
        if (authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7); // Ambil token asli
          final encryptedToken = aesEncrypter.encrypt(token, iv: aesIv).base64;

          options.headers.remove(authKey); // Hapus token asli
          options.headers['X-Auth-Token'] =
              encryptedToken; // Kirim token terenkripsi

        }
      }

      // 5. BODY ENCRYPTION (Hanya jika ada data)
      if (options.data != null) {
        // KASUS A: JSON BIASA
        if (options.data is Map) {
          final jsonString = jsonEncode(options.data);
          final encryptedPayload = aesEncrypter
              .encrypt(jsonString, iv: aesIv)
              .base64;

          // Body hanya berisi payload, key sudah di header
          options.data = {'payload': encryptedPayload};
        }
        // KASUS B: MULTIPART / FILE
        else if (options.data is FormData) {
          final originalForm = options.data as FormData;
          final Map<String, dynamic> textFields = {};

          for (var field in originalForm.fields) {
            textFields[field.key] = field.value;
          }

          if (textFields.isNotEmpty) {
            final jsonString = jsonEncode(textFields);
            final encryptedPayload = aesEncrypter
                .encrypt(jsonString, iv: aesIv)
                .base64;

            final newForm = FormData();
            newForm.fields.add(MapEntry('payload', encryptedPayload));

            // Salin file asli
            for (var file in originalForm.files) {
              newForm.files.add(file);
            }
            options.data = newForm;
          }
        }
      }
    } catch (e) {
      a.debugPrint("❌ Encryption Init Failed: $e");
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _decryptResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) _decryptResponse(err.response!);
    super.onError(err, handler);
  }

  void _decryptResponse(Response response) {
    // Cek apakah respon terenkripsi (punya payload)
    if (response.data is Map && response.data.containsKey('payload')) {
      // Cek apakah kita punya kuncinya di memory request
      if (response.requestOptions.extra.containsKey('session_key')) {
        try {
          final keyString = response.requestOptions.extra['session_key'];
          final ivString = response.requestOptions.extra['session_iv'];

          final aesEncrypter = Encrypter(
            AES(Key.fromUtf8(keyString), mode: AESMode.cbc),
          );
          final encryptedData = response.data['payload'];

          final decrypted = aesEncrypter.decrypt64(
            encryptedData,
            iv: IV.fromUtf8(ivString),
          );
          response.data = jsonDecode(decrypted);
        } catch (e) {
          a.debugPrint("❌ Decryption Failed: $e");
        }
      }
    }
  }

  String _generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}
