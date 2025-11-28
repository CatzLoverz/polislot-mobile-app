import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Ambil token dari memori HP
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // 2. Jika token ada, tempelkan ke Header Authorization
    // Kecuali untuk endpoint login/register yang tidak butuh token
    if (token != null && token.isNotEmpty) {
      // Pastikan tidak menimpa header jika sudah diset manual (misal multipart)
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }

    super.onRequest(options, handler);
  }
}