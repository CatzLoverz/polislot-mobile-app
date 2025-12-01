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

  // ✅ FUNGSI BARU: Cek Koneksi (Ping)
  Future<bool> isServerReachable() async {
    return await ref.read(authRepositoryInstanceProvider).checkConnectivity();
  }

  // ✅ LOGIK CEK SESI (Background & Fail-Safe)
  Future<bool> checkAuthSession() async {
    try {
      final repo = ref.read(authRepositoryInstanceProvider);
      
      // 1. Cek Lokal (Prioritas Utama)
      final localUser = await repo.getUserLocal();
      if (localUser == null) return false; // Tidak ada data -> Login

      // Update UI agar User langsung masuk Home
      state = AsyncData(localUser); 

      // 2. Validasi Server (Di Background)
      // Jangan 'await' ini di return statement agar Splash Screen tidak macet jika server down
      _validateTokenInBackground(repo);

      return true; // Izinkan masuk Home

    } catch (e) {
      return false;
    }
  }

  Future<void> _validateTokenInBackground(AuthRepository repo) async {
    try {
      final freshUser = await repo.fetchUserProfile();
      state = AsyncData(freshUser); // Update data terbaru
      debugPrint("✅ Token Valid & Data Updated");
    } catch (e) {
      // 🚨 CRITICAL: Hanya Logout jika 401 (Token Salah/Expired)
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("🛑 Token Expired (401). Force Logout.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/loginRegis', (route) => false);
      } else {
        // Error lain (Timeout/No Internet) -> Biarkan tetap Login (Mode Offline)
        debugPrint("⚠️ Server Validation Failed (Offline Mode): $e");
      }
    }
  }

  // ... (Semua method auth lainnya login/register/dll TETAP SAMA, copy dari file Anda sebelumnya) ...
  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryInstanceProvider).login(email: email, password: password));
    state = result; return !state.hasError;
  }
  
  Future<bool> register({required String name, required String email, required String password, required String confirmPassword}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).register(name: name, email: email, password: password, confirmPassword: confirmPassword);
      return state.value;
    });
    if (result.hasError) { state = AsyncError(result.error!, result.stackTrace!); return false; }
    state = AsyncData(state.value); return true;
  }

  Future<bool> registerOtpVerify({required String email, required String otp}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryInstanceProvider).registerOtpVerify(email: email, otp: otp));
    state = result; return !state.hasError;
  }

  Future<bool> registerOtpResend({required String email}) async {
    try { await ref.read(authRepositoryInstanceProvider).registerOtpResend(email: email); return true; } catch (_) { return false; }
  }

  Future<bool> forgotPasswordVerify({required String email}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      // Panggil Repo
      await ref.read(authRepositoryInstanceProvider).forgotPasswordVerify(email: email);
      return state.value; // Return state lama
    });
    
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return false;
    }
    state = AsyncData(state.value);
    return true;
  }

  Future<bool> forgotPasswordOtpVerify({required String email, required String otp}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).forgotPasswordOtpVerify(email: email, otp: otp);
      return state.value;
    });
    if (result.hasError) { state = AsyncError(result.error!, result.stackTrace!); return false; }
    state = AsyncData(state.value); return true;
  }

  Future<bool> forgotPasswordOtpResend({required String email}) async {
    try { await ref.read(authRepositoryInstanceProvider).forgotPasswordOtpResend(email: email); return true; } catch (_) { return false; }
  }
  
  Future<bool> resetPassword({required String email, required String password, required String confirmPassword}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryInstanceProvider).resetPassword(email: email, password: password, confirmPassword: confirmPassword);
      return state.value;
    });
    if (result.hasError) { state = AsyncError(result.error!, result.stackTrace!); return false; }
    state = AsyncData(state.value); return true;
  }

  void updateUser(User newUser) { state = AsyncData(newUser); }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryInstanceProvider).logout();
    state = const AsyncData(null);
  }
}