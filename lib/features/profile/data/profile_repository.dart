import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/data/user_model.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
class ProfileRepositoryInstance extends _$ProfileRepositoryInstance {
  @override
  ProfileRepository build() {
    return ProfileRepository(ref.watch(dioClientServiceProvider));
  }
}

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  Future<User> updateProfile({
    required String name,
    File? avatar,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final formData = FormData.fromMap({
        '_method': 'PUT', // Spoofing method
        'name': name,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'current_password': currentPassword,
        if (newPassword != null && newPassword.isNotEmpty)
          'new_password': newPassword,
        if (confirmPassword != null && confirmPassword.isNotEmpty)
          'new_password_confirmation': confirmPassword,
        if (avatar != null)
          'avatar': await MultipartFile.fromFile(avatar.path, filename: 'avatar.jpg'),
      });

      final response = await _dio.post(
        '/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json', // Wajib agar Laravel return JSON jika error
          },
        ),
      );

      final data = response.data; // Response mentah

      // Cek status sukses standar (dari helper sendSuccess di PHP)
      if (response.statusCode == 200 && data['status'] == 'success') {
        
        // Struktur: { "status": "success", "data": { "user": {...} } }
        // Jadi kita harus ambil data['data']['user']
        final userData = data['data']['user'];
        
        // Update Local Storage (PENTING: Agar saat restart app, data baru tetap ada)
        await prefs.setString('user_data', jsonEncode(userData));
        
        return User.fromJson(userData);
      } else {
        throw Exception(data['message'] ?? "Gagal memperbarui profil");
      }

    } on DioException catch (e) {
      // 🛡️ Error Handling Anti-Null
      String errorMsg = "Gagal terhubung ke server";
      
      if (e.response != null && e.response?.data != null) {
        final errData = e.response?.data;
        if (errData is Map) {
          // Prioritas pesan error: message -> error
          if (errData['message'] != null) {
            errorMsg = errData['message'];
          } else if (errData['error'] != null) {
            errorMsg = errData['error'];
          }
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}