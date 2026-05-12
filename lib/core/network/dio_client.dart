import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/encryption_interceptor.dart';
import 'auth_interceptor.dart';
import '../providers/connection_status_provider.dart';
import '../utils/navigator_key.dart';

part 'dio_client.g.dart';

bool _isLogoutDialogShowing = false;

@Riverpod(keepAlive: true)
class DioClientService extends _$DioClientService {
  @override
  Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://192.168.137.1/api',
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 15000),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final isOffline = ref.read(connectionStatusProvider);
          final path = options.path;

          // WHITELIST AUTH: Kecualikan endpoint Auth dari blokir Offline
          // Agar user tetap bisa mencoba Login/Register/OTP meski status "Offline"
          bool isAuthEndpoint =
              path.contains('/login') ||
              path.contains('/register') ||
              path.contains('/forgot') ||
              path.contains('/reset-pass');

          // Blokir request HANYA JIKA Offline DAN BUKAN endpoint Auth
          if (isOffline && !isAuthEndpoint) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: "Offline Mode Active",
                message:
                    "Aplikasi sedang dalam mode offline. Refresh untuk mencoba lagi.",
              ),
            );
          }

          return handler.next(options);
        },
      ),

      AuthInterceptor(),
      EncryptionInterceptor(),
      InterceptorsWrapper(
        onResponse: (response, handler) {
          ref.read(connectionStatusProvider.notifier).setOnline();
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          int? statusCode = e.response?.statusCode;
          final path = e.requestOptions.path;
          if (statusCode == 401) {
            bool ignoreDialog = e.requestOptions.headers['Ignore-401-Dialog'] == 'true';
            bool isAuthEndpoint =
                path.contains('/login') || path.contains('/register');
            if (!isAuthEndpoint) {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('access_token');

              // ✅ CEK: Hanya tampilkan dialog jika token MASIH ADA di HP
              // Jika token null, berarti user memang sudah logout manual, jadi biarkan saja.
              if (token != null && token.isNotEmpty) {
                if (ignoreDialog) {
                  // Cukup hapus token tanpa dialog dan tanpa redirect 
                  // (karena Splash screen akan redirect sendiri berdasarkan kembalian checkStartupSession)
                  await prefs.remove('access_token');
                  await prefs.remove('user_data');
                  await prefs.remove('isLoggedIn');
                  return handler.reject(e);
                }

                debugPrint(
                  "🚨 401 Session Expired di ($path). Menampilkan Dialog Logout...",
                );

                if (!_isLogoutDialogShowing && navigatorKey.currentContext != null) {
                  _isLogoutDialogShowing = true;
                  
                  // Gunakan Future.microtask agar aman dipanggil dari dalam interceptor
                  Future.microtask(() {
                    showDialog(
                      context: navigatorKey.currentContext!,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "Sesi Berakhir",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            "Sesi Anda telah berakhir. Silakan login kembali untuk melanjutkan.",
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              child: const Text(
                                "OK",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                _isLogoutDialogShowing = false;
                                await prefs.remove('access_token');
                                await prefs.remove('user_data');
                                await prefs.remove('isLoggedIn');
                                if (navigatorKey.currentState != null) {
                                  // Gunakan pushNamedAndRemoveUntil agar tidak bisa back
                                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                                    '/loginRegis',
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  });
                }
              } else {
                debugPrint("Output 401 ignored: Token already cleared.");
              }

              return handler.reject(e);
            }
          }

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            debugPrint("⚠️ Network Error ($path). Set Offline Mode.");
            ref.read(connectionStatusProvider.notifier).setOffline();
          }

          return handler.next(e);
        },
      ),

      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }
}

class DioErrorHandler {
  static String parse(Object e) {
    if (e is DioException) {
      String errorMsg = "Terjadi kesalahan koneksi";

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data['message'] != null) {
            errorMsg = data['message'];
          } else if (data['error'] != null) {
            errorMsg = data['error'];
          }
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstKey = errors.keys.first;
              final firstErrorList = errors[firstKey];
              if (firstErrorList is List && firstErrorList.isNotEmpty) {
                errorMsg = firstErrorList.first;
              }
            }
          }
        }
      } else if (e.error == "Offline Mode Active") {
        errorMsg = "Anda sedang offline. Tarik layar untuk menyegarkan.";
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMsg = "Koneksi timeout. Periksa internet Anda.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = "Tidak dapat terhubung ke server.";
      }

      return errorMsg;
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}
