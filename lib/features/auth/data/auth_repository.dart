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

  // 1. AMBIL DATA LOKAL
  Future<User?> getUserLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user_data');
      if (userString != null && userString.isNotEmpty) {
        return User.fromJson(jsonDecode(userString));
      }
    } catch (e) {
      // Ignore error parsing local data
    }
    return null;
  }

  // 2. CEK SERVER (VALIDASI TOKEN & GET USER)
  Future<User> fetchUserProfile() async {
    try {
      final response = await _dio.get('/user');
      
      final dynamic data = response.data;
      Map<String, dynamic> userJson;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map) {
          userJson = data['data'];
        } else if (data.containsKey('data') && data['data']['user'] is Map) {
          userJson = data['data']['user'];
        } else if (data.containsKey('user_id') || data.containsKey('id')) {
          userJson = data;
        } else {
          throw Exception("Format data user server tidak valid");
        }
      } else {
        throw Exception("Response bukan JSON Object");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userJson));
      
      return User.fromJson(userJson);

    } catch (e) {
      rethrow;
    }
  }

  // --- AUTH METHODS ---
  
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/login-attempt', data: {'email': email, 'password': password});
      return _handleAuthResponse(response.data);
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<void> register({required String name, required String email, required String password, required String confirmPassword}) async {
    try {
      final response = await _dio.post('/register-attempt', data: {'name': name, 'email': email, 'password': password, 'password_confirmation': confirmPassword});
      if (response.statusCode != 201 && response.data['status'] != 'success') {
        throw Exception(response.data['message'] ?? "Registrasi gagal");
      }
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  // OTP Register
  Future<User> registerOtpVerify({required String email, required String otp}) async {
    try {
      final response = await _dio.post('/register-otp-verify', data: {'email': email, 'otp': otp});
      return _handleAuthResponse(response.data);
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }

  Future<void> registerOtpResend({required String email}) async {
    try { await _dio.post('/register-otp-resend', data: {'email': email}); } catch (e) { throw Exception(DioErrorHandler.parse(e)); }
  }

  // OTP Forgot Password
  Future<void> forgotPasswordVerify({required String email}) async {
    try {
      final response = await _dio.post('/forgot-attempt', data: {'email': email});
      if (response.statusCode != 200 && response.data['status'] != 'success') {
         throw Exception(response.data['message'] ?? "Gagal mengirim OTP");
      }
    } catch (e) { throw Exception(DioErrorHandler.parse(e)); }
  }

  Future<void> forgotPasswordOtpVerify({required String email, required String otp}) async {
    try {
      final response = await _dio.post('/forgot-otp-verify', data: {'email': email, 'otp': otp});
      if (response.statusCode != 200) throw Exception(response.data['message']);
    } catch (e) { throw Exception(DioErrorHandler.parse(e)); }
  }

  Future<void> forgotPasswordOtpResend({required String email}) async {
    try { await _dio.post('/forgot-otp-resend', data: {'email': email}); } catch (e) { throw Exception(DioErrorHandler.parse(e)); }
  }
  
  Future<void> resetPassword({required String email, required String password, required String confirmPassword}) async {
    try {
      final response = await _dio.post('/reset-pass-attempt', data: {'email': email, 'password': password, 'password_confirmation': confirmPassword});
      if (response.statusCode != 200) throw Exception(response.data['message']);
    } catch (e) { throw Exception(DioErrorHandler.parse(e)); }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      try { await _dio.post('/logout', options: Options(headers: {'Authorization': 'Bearer $token'})); } catch (_) {}
    }
    await prefs.clear();
  }

  // Helper
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
      final token = payload['access_token'];
      final userJson = payload['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('user_data', jsonEncode(userJson));
      await prefs.setBool('isLoggedIn', true);
      return User.fromJson(userJson);
    }
    throw Exception("Respon server tidak valid.");
  }
}