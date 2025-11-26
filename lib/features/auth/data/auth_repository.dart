import 'dart:convert';
import 'package:dio/dio.dart';
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

  // --- USER LOCAL (Helper) ---
  Future<User?> getUserLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user_data');
      if (userString != null) return User.fromJson(jsonDecode(userString));
    } catch (_) {}
    return null;
  }

  // --- LOGIN ---
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/login-attempt', data: {'email': email, 'password': password});
      return _handleAuthResponse(response.data);
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- REGISTER ATTEMPT ---
  Future<void> register({
    required String name, required String email,
    required String password, required String confirmPassword,
  }) async {
    try {
      // URL sesuai api.php
      final response = await _dio.post('/register-attempt', data: {
        'name': name, 'email': email, 
        'password': password, 'password_confirmation': confirmPassword
      });
      
      final data = response.data;
      if (response.statusCode == 201 || (data['status'] == 'success')) {
        return;
      } else {
        throw Exception(data['message'] ?? "Registrasi gagal");
      }
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- REGISTER OTP VERIFY ---
  Future<User> registerOtpVerify({required String email, required String otp}) async {
    try {
      // URL sesuai api.php
      final response = await _dio.post('/register-otp-verify', data: {'email': email, 'otp': otp});
      return _handleAuthResponse(response.data); // Login otomatis
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- REGISTER OTP RESEND ---
  Future<void> registerOtpResend({required String email}) async {
    try {
      // URL sesuai api.php
      await _dio.post('/register-otp-resend', data: {'email': email});
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- FORGOT PASSWORD VERIFY ---
  Future<void> forgotPasswordVerify({required String email}) async {
    try {
      // Endpoint: /forgot-attempt (Sesuai api.php)
      final response = await _dio.post('/forgot-attempt', data: {'email': email});
      
      final data = response.data;
      if (response.statusCode == 200 && data['status'] == 'success') {
        return;
      } else {
        throw Exception(data['message'] ?? "Gagal mengirim kode OTP.");
      }
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- FORGOT PASSWORD OTP VERIFY ---
  Future<void> forgotPasswordOtpVerify({required String email, required String otp}) async {
    try {
      // URL sesuai api.php
      final response = await _dio.post('/forgot-otp-verify', data: {'email': email, 'otp': otp});
      final data = response.data;
      if (response.statusCode == 200 && data['status'] == 'success') {
        return;
      } else {
        throw Exception(data['message'] ?? "Kode OTP Salah");
      }
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- FORGOT PASSWORD OTP RESEND ---
  Future<void> forgotPasswordOtpResend({required String email}) async {
    try {
      // URL sesuai api.php
      await _dio.post('/forgot-otp-resend', data: {'email': email});
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- RESET PASSWORD ---
  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Endpoint: /reset-pass-attempt (Sesuai api.php)
      final response = await _dio.post('/reset-pass-attempt', data: {
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      final data = response.data;
      if (response.statusCode == 200 && data['status'] == 'success') {
        return;
      } else {
        throw Exception(data['message'] ?? "Gagal mereset password.");
      }
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      try {
        await _dio.post('/logout', options: Options(headers: {'Authorization': 'Bearer $token'}));
      } catch (_) {}
    }
    await prefs.clear();
  }

  // Helper Internal Response Handler
  Future<User> _handleAuthResponse(dynamic data) async {
    Map<String, dynamic>? payload;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map) {
        payload = data['data'];
      } else if (data.containsKey('access_token')) {
        payload = data;
      }
    }

    if (payload != null && payload.containsKey('access_token') && payload.containsKey('user')) {
      final String token = payload['access_token'];
      final Map<String, dynamic> userJson = payload['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('user_data', jsonEncode(userJson));
      await prefs.setBool('isLoggedIn', true);

      return User.fromJson(userJson);
    }
    throw Exception(data['message'] ?? "Respon server tidak valid.");
  }
}