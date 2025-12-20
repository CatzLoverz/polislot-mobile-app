import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import 'user_model.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
class AuthRepositoryInstance extends _$AuthRepositoryInstance {
  @override
  AuthRepository build() {
    return AuthRepository(ref.watch(dioClientServiceProvider));
  }
}

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  // ✅ CEK KONEKSI SERVER NYATA
  Future<bool> checkConnectivity() async {
    try {
      // Tembak endpoint ringan dengan timeout CEPAT (3 detik)
      await _dio.get(
        '/user',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return true; // Sukses
    } catch (e) {
      // Jika 401, berarti server NYAMBUNG (cuma token salah).
      // Kembalikan TRUE agar sistem tahu kita "Online", sehingga proses logout bisa jalan.
      if (e is DioException && e.response?.statusCode == 401) return true;

      // Timeout / SocketException -> Benar-benar OFFLINE
      return false;
    }
  }

  // ✅ 2. AMBIL DATA LOKAL
  Future<User?> getUserLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user_data');
      if (userString != null && userString.isNotEmpty) {
        return User.fromJson(jsonDecode(userString));
      }
    } catch (e) {
      debugPrint("Error baca data lokal: $e");
    }
    return null;
  }

  // ✅ 3. VALIDASI TOKEN KE SERVER
  Future<User> fetchUserProfile() async {
    try {
      final response = await _dio.get('/user');

      final dynamic data = response.data;
      Map<String, dynamic> userJson;

      // Parsing Fleksibel (Handle bungkus 'data' atau langsung)
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map) {
          userJson = data['data'];
        } else if (data.containsKey('data') && data['data']['user'] is Map) {
          userJson = data['data']['user'];
        } else if (data.containsKey('user_id') || data.containsKey('id')) {
          userJson = data;
        } else {
          throw Exception("Format data user tidak valid");
        }
      } else {
        throw Exception("Response bukan JSON Object");
      }

      // Simpan pembaruan ke lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userJson));

      return User.fromJson(userJson);
    } catch (e) {
      // Rethrow agar Controller bisa menangkap Error 401
      rethrow;
    }
  }

  // --- METHOD AUTH LAINNYA (PASTIKAN TETAP ADA) ---

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/login-attempt',
        data: {'email': email, 'password': password},
      );
      return _handleAuthResponse(response.data);
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        '/register-attempt',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );
      // Dio validates 200-299 automatically
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<User> registerOtpVerify({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/register-otp-verify',
        data: {'email': email, 'otp': otp},
      );
      return _handleAuthResponse(response.data);
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<void> registerOtpResend({required String email}) async {
    try {
      await _dio.post('/register-otp-resend', data: {'email': email});
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // Kirim OTP Forgot Password
  Future<void> forgotPasswordVerify({required String email}) async {
    try {
      await _dio.post('/forgot-attempt', data: {'email': email});
      // Dio validates 200-299 automatically
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // Verifikasi OTP Forgot Password
  Future<void> forgotPasswordOtpVerify({
    required String email,
    required String otp,
  }) async {
    try {
      await _dio.post('/forgot-otp-verify', data: {'email': email, 'otp': otp});
      // Dio validates 200-299 automatically
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<void> forgotPasswordOtpResend({required String email}) async {
    try {
      await _dio.post('/forgot-otp-resend', data: {'email': email});
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        '/reset-pass-attempt',
        data: {
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );
      // Dio validates 200-299 automatically
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // Method updateProfile (gunakan implementasi ProfileRepository, disini placeholder)
  Future<User> updateProfile({
    required String name,
    File? avatar,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    throw UnimplementedError();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      try {
        await _dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (_) {}
    }
    await prefs.clear();
  }

  Future<User> _handleAuthResponse(dynamic data) async {
    Map<String, dynamic>? payload;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map) {
        payload = data['data'];
      } else if (data.containsKey('access_token')) {
        payload = data;
      }
    }
    if (payload != null &&
        payload.containsKey('access_token') &&
        payload.containsKey('user')) {
      final token = payload['access_token'];
      final userJson = payload['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('user_data', jsonEncode(userJson));
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('has_seen_privacy_policy', true);
      return User.fromJson(userJson);
    }
    throw Exception("Respon server tidak valid.");
  }
}
