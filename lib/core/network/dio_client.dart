import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk hapus token manual
import '../security/encryption_interceptor.dart';
import 'auth_interceptor.dart';
import '../providers/connection_status_provider.dart'; // Import Provider Koneksi
import '../utils/navigator_key.dart';

part 'dio_client.g.dart';

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
      EncryptionInterceptor(),
      AuthInterceptor(),
      
      // ✅ INTERCEPTOR GLOBAL
      InterceptorsWrapper(
        onResponse: (response, handler) {
          ref.read(connectionStatusProvider.notifier).setOnline();
          return handler.next(response);
        },
        
        onError: (DioException e, handler) async { // ⚠️ Wajib ASYNC
          int? statusCode = e.response?.statusCode;
          final path = e.requestOptions.path;

          // 🛑 KASUS 1: 401 UNAUTHORIZED (Sesi Habis)
          if (statusCode == 401) {
            // Pengecualian: Jangan logout jika errornya saat sedang login/register
            // (Karena itu artinya password salah, bukan sesi expired)
            bool isAuthEndpoint = path.contains('/login') || path.contains('/register');

            if (!isAuthEndpoint) {
              debugPrint("🚨 401 Session Expired di ($path). Melakukan Force Logout...");

              try {
                // 1. Hapus Token Dulu (AWAIT Wajib!)
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // 2. Navigasi ke Login
                // Kita gunakan addPostFrameCallback opsional untuk memastikan frame siap, 
                // tapi navigatorKey biasanya aman dipanggil langsung.
                if (navigatorKey.currentState != null) {
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                    '/loginRegis', 
                    (route) => false,
                  );
                } else {
                  debugPrint("⚠️ Navigator State is NULL. Tidak bisa navigasi.");
                }
                
                // 3. STOP. Jangan panggil handler.next(e) di sini jika ingin memutus rantai
                // Tapi Dio butuh resolusi. Kita reject, tapi UI mungkin sudah pindah halaman.
                return handler.reject(e);

              } catch (err) {
                debugPrint("❌ Gagal Logout Otomatis: $err");
              }
            }
          }
          
          // 🛑 KASUS 2: MASALAH KONEKSI
          // Hanya dijalankan jika BUKAN 401 (atau 401 pada login page)
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout || 
              e.type == DioExceptionType.connectionError) {
             debugPrint("⚠️ Network Error. Set Offline Mode.");
             ref.read(connectionStatusProvider.notifier).setOffline();
          }

          // Lanjutkan error ke Controller/Repository seperti biasa
          return handler.next(e);
        },
      ),

      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }
}

// ✅ HELPER: CLASS KHUSUS HANDLING ERROR
class DioErrorHandler {
  static String parse(Object e) {
    if (e is DioException) {
      String errorMsg = "Terjadi kesalahan koneksi";
      
      // 1. Cek Response dari Server
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        
        if (data is Map) {
          // Prioritas 1: Pesan error standar Laravel ('message')
          if (data['message'] != null) {
            errorMsg = data['message'];
          } 
          // Prioritas 2: Pesan error custom ('error')
          else if (data['error'] != null) {
            errorMsg = data['error'];
          }
          
          // Prioritas 3: Validation Errors (422)
          // Jika ada field 'errors', ambil pesan pertama
          if (data['errors'] != null && data['errors'] is Map) {
             final errors = data['errors'] as Map;
             if (errors.isNotEmpty) {
               final firstKey = errors.keys.first;
               final firstErrorList = errors[firstKey];
               if (firstErrorList is List && firstErrorList.isNotEmpty) {
                 errorMsg = firstErrorList.first; // Contoh: "Email sudah terdaftar"
               }
             }
          }
        }
      } 
      // 2. Cek Error Koneksi (Timeout, No Internet)
      else if (e.type == DioExceptionType.connectionTimeout || 
               e.type == DioExceptionType.receiveTimeout ||
               e.type == DioExceptionType.sendTimeout) {
        errorMsg = "Koneksi timeout. Periksa internet Anda.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = "Tidak dapat terhubung ke server.";
      }

      return errorMsg;
    } 
    
    // Error generic lainnya
    return e.toString().replaceAll('Exception: ', '');
  }
}