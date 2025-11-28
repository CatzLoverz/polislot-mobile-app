import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../../main.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  
  @override
  Future<User?> build() async {
    return await ref.read(authRepositoryInstanceProvider).getUserLocal();
  }

  Future<bool> checkAuthSession() async {
    try {
      final repo = ref.read(authRepositoryInstanceProvider);
      
      // 1. Cek Data Lokal (Prioritas Utama agar UI cepat)
      final localUser = await repo.getUserLocal();
      
      if (localUser == null) {
        return false; // Tidak ada data -> Login
      }

      // Update state UI dengan data lokal (Optimistic)
      state = AsyncData(localUser); 
      
      // 2. Validasi ke Server (Background)
      // Kita jalankan ini tapi jangan await response-nya untuk memblokir UI Splash Screen
      // Biarkan dia berjalan, kalau 401 nanti dia force logout sendiri.
      _validateTokenInBackground(repo);

      return true; // Loloskan ke Home karena data lokal ada

    } catch (e) {
      return false;
    }
  }

  Future<void> _validateTokenInBackground(AuthRepository repo) async {
    try {
      // Request ke server
      final freshUser = await repo.fetchUserProfile();
      
      // Jika sukses, update state dengan data terbaru
      state = AsyncData(freshUser);
      debugPrint("✅ Token Valid. Data User diperbarui.");
      
    } catch (e) {
      // 🚨 HANYA LOGOUT JIKA 401 (Token Salah/Expired)
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("⛔ Token Expired (401). Force Logout.");
        
        // Hapus data
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Redirect paksa ke LoginRegis menggunakan Global Key
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/loginRegis', (route) => false);
      } 
      // Jika error lain (koneksi putus), biarkan saja (tetap di Home mode Offline)
      else {
        debugPrint("⚠️ Validasi Server Gagal (Offline Mode): $e");
      }
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await ref.read(authRepositoryInstanceProvider).login(email: email, password: password);
    });
    state = result;
    return !state.hasError;
  }

  // Register Attempt
  Future<bool> register({
    required String name, required String email, 
    required String password, required String confirmPassword
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).register(
        name: name, email: email, password: password, confirmPassword: confirmPassword
      );
      return state.value; // Return state lama (null) karena belum login
    });
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = AsyncData(state.value); 
    return true;
  }

  // ✅ REGISTER OTP VERIFY (Auto Login)
  Future<bool> registerOtpVerify({required String email, required String otp}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      // Panggil repo dan update state user (login)
      return await ref.read(authRepositoryInstanceProvider).registerOtpVerify(email: email, otp: otp);
    });
    state = result;
    return !state.hasError;
  }

  // ✅ REGISTER OTP RESEND
  Future<bool> registerOtpResend({required String email}) async {
    try {
      await ref.read(authRepositoryInstanceProvider).registerOtpResend(email: email);
      return true;
    } catch (e) { return false; }
  }

  // 🟡 KIRIM OTP (Forgot Password)
  Future<bool> forgotPasswordVerify({required String email}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).forgotPasswordVerify(email: email);
      return state.value;
    });
    
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = AsyncData(state.value);
    return true;
  }

  // 🟡 FORGOT PASSWORD OTP VERIFY (Hanya Cek, Tidak Login)
  Future<bool> forgotPasswordOtpVerify({required String email, required String otp}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).forgotPasswordOtpVerify(email: email, otp: otp);
      return state.value; // Return state lama
    });
    
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = AsyncData(state.value);
    return true;
  }

  // 🟡 FORGOT PASSWORD OTP RESEND
  Future<bool> forgotPasswordOtpResend({required String email}) async {
    try {
      await ref.read(authRepositoryInstanceProvider).forgotPasswordOtpResend(email: email);
      return true;
    } catch (e) { return false; }
  }

  // 🟡 RESET PASSWORD
  Future<bool> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).resetPassword(
        email: email, 
        password: password, 
        confirmPassword: confirmPassword
      );
      return state.value;
    });

    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = AsyncData(state.value);
    return true;
  }

  // Update User Manual
  void updateUser(User newUser) {
    state = AsyncData(newUser);
  }

  // Logout
  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryInstanceProvider).logout();
    state = const AsyncData(null);
  }
}