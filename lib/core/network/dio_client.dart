import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../security/encryption_interceptor.dart';
import 'auth_interceptor.dart';

part 'dio_client.g.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      LogInterceptor(
        requestBody: true, 
        responseBody: true,
      ),
      EncryptionInterceptor(),
      AuthInterceptor(),
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