import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
          final connectionState = ref.read(connectionStatusProvider);
          final path = options.path;

          // WHITELIST AUTH: Kecualikan endpoint Auth dari blokir Offline
          // Agar user tetap bisa mencoba Login/Register/OTP meski status "Offline"
          bool isAuthEndpoint =
              path.contains('/login') ||
              path.contains('/register') ||
              path.contains('/forgot') ||
              path.contains('/reset-pass');

          // Blokir request HANYA JIKA Offline DAN BUKAN endpoint Auth
          if (connectionState != ConnectionStateType.online && !isAuthEndpoint) {
            String errorType = connectionState == ConnectionStateType.noInternet ? "No Internet" : "Server Unreachable";
            String errorMessage = connectionState == ConnectionStateType.noInternet 
                ? "Koneksi internet terputus. Periksa WiFi atau data seluler Anda."
                : "Server sedang mengalami gangguan. Silakan coba beberapa saat lagi.";

            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: errorType,
                message: errorMessage,
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
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown) {
            
            final connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult.contains(ConnectivityResult.none)) {
              debugPrint("⚠️ No Internet ($path). Set NoInternet Mode.");
              ref.read(connectionStatusProvider.notifier).setNoInternet();
            } else {
              debugPrint("⚠️ Network Error ($path). Set ServerUnreachable Mode.");
              ref.read(connectionStatusProvider.notifier).setServerUnreachable();
            }
          } else if (statusCode != null && statusCode >= 500) {
            debugPrint("⚠️ Server Error $statusCode ($path). Set ServerUnreachable Mode.");
            ref.read(connectionStatusProvider.notifier).setServerUnreachable();
          }

          return handler.next(e);
        },
      ),
    ]);

    // Log request/response lengkap HANYA saat mode debug.
    // Di build rilis, log verbose ini tidak boleh ikut (bukan untuk end user).
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}

class DioErrorHandler {
  /// Pesan fallback yang ramah & aman ditampilkan ke end user.
  static const String _genericMessage =
      "Terjadi kesalahan. Silakan coba lagi.";

  /// Mengubah error apa pun (DioException / Exception biasa) menjadi pesan
  /// singkat yang menjelaskan masalah ke pengguna, TANPA detail debug teknis
  /// (stack trace, tipe DioException, dump response, dll).
  static String parse(Object e) {
    if (e is DioException) {
      String errorMsg = "Terjadi kesalahan koneksi. Silakan coba lagi.";

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data['message'] != null) {
            errorMsg = data['message'].toString();
          } else if (data['error'] != null) {
            errorMsg = data['error'].toString();
          }
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstErrorList = errors[errors.keys.first];
              if (firstErrorList is List && firstErrorList.isNotEmpty) {
                errorMsg = firstErrorList.first.toString();
              }
            }
          }
        } else {
          // Body bukan Map (mis. HTML error page) -> jangan tampilkan mentah
          errorMsg = _statusMessage(e.response?.statusCode);
        }
      } else if (e.error == "No Internet") {
        errorMsg =
            "Koneksi internet terputus. Periksa WiFi atau data seluler Anda.";
      } else if (e.error == "Server Unreachable") {
        errorMsg =
            "Server sedang mengalami gangguan. Silakan coba beberapa saat lagi.";
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMsg = "Koneksi timeout. Periksa internet Anda.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = "Tidak dapat terhubung ke server.";
      } else {
        errorMsg = _statusMessage(e.response?.statusCode);
      }

      return _sanitize(errorMsg);
    }

    // Exception biasa: ambil pesannya saja, buang prefix "Exception: ".
    return _sanitize(e.toString().replaceAll('Exception: ', ''));
  }

  static String _statusMessage(int? statusCode) {
    if (statusCode == null) return "Terjadi kesalahan koneksi. Silakan coba lagi.";
    if (statusCode >= 500) {
      return "Server sedang mengalami gangguan. Silakan coba beberapa saat lagi.";
    }
    if (statusCode == 404) return "Data tidak ditemukan.";
    if (statusCode == 403) return "Anda tidak memiliki akses untuk tindakan ini.";
    if (statusCode == 401) return "Sesi Anda telah berakhir. Silakan login kembali.";
    return _genericMessage;
  }

  /// Pastikan pesan tidak kosong, bukan "null", dan tidak mengandung jejak
  /// teknis (mis. "DioException", stack trace) yang lolos ke UI.
  static String _sanitize(String message) {
    final msg = message.trim();
    if (msg.isEmpty ||
        msg.toLowerCase() == 'null' ||
        msg.contains('DioException') ||
        msg.contains('#0 ') ||
        msg.startsWith('{') ||
        msg.startsWith('[')) {
      return _genericMessage;
    }
    return msg;
  }
}
