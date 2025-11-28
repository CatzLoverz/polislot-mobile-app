import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/data/user_model.dart'; // Reuse User Model

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
      // 1. Siapkan Data
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final formData = FormData.fromMap({
        '_method': 'PUT', // Trik Laravel untuk update data via POST Multipart
        'name': name,
        
        if (currentPassword != null && currentPassword.isNotEmpty)
          'current_password': currentPassword,
        if (newPassword != null && newPassword.isNotEmpty)
          'new_password': newPassword,
        if (confirmPassword != null && confirmPassword.isNotEmpty)
          'new_password_confirmation': confirmPassword,
        
        // Upload File
        if (avatar != null)
          'avatar': await MultipartFile.fromFile(
            avatar.path, 
            filename: avatar.path.split('/').last
          ),
      });

      // 2. Kirim Request
      final response = await _dio.post(
        '/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data', // Wajib
            'Accept': 'application/json',
          },
        ),
      );

      // 3. Parsing Response
      final data = response.data;
      
      // Cek status sukses (Format standar: { status: 'success', data: { user: ... } })
      if (response.statusCode == 200 && data['status'] == 'success') {
        
        // Ambil object user dari dalam 'data'
        final userData = data['data']['user'];
        
        // 4. Update Local Storage (PENTING!)
        // Agar saat user restart aplikasi, data baru (foto/nama) tetap muncul
        await prefs.setString('user_data', jsonEncode(userData));
        
        return User.fromJson(userData);
      } else {
        throw Exception(data['message'] ?? "Gagal memperbarui profil");
      }

    } on DioException catch (e) {
      // Gunakan Helper Error yang sama dengan AuthRepository
      throw Exception(DioErrorHandler.parse(e));
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}