import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/connection_status_provider.dart';
// import '../../../../main.dart'; 
import '../data/auth_repository.dart';
import '../data/user_model.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  
  @override
  Future<User?> build() async {
    return await ref.read(authRepositoryInstanceProvider).getUserLocal();
  }

  // ✅ LOGIC STARTUP (Dipanggil Splash Screen)
  Future<bool> checkStartupSession() async {
    try {
      final repo = ref.read(authRepositoryInstanceProvider);
      final connectionNotifier = ref.read(connectionStatusProvider.notifier);

      // 1. Cek Token Lokal
      final localUser = await repo.getUserLocal();
      
      if (localUser == null) {
        // Tidak ada token -> Langsung ke Login
        return false; 
      }

      // Ada token -> Set state agar UI Home bisa render (Offline Mode Ready)
      state = AsyncData(localUser);

      // 2. Cek Koneksi Server (Ping)
      // Gunakan timeout pendek
      try {
        await repo.checkConnectivity(); // Pastikan repo punya method ini (return void/bool)
        
        // 3. Jika Server OK -> Validasi Token & Update Data
        final freshUser = await repo.fetchUserProfile();
        state = AsyncData(freshUser);
        connectionNotifier.setOnline(); // Set UI jadi Online
        
      } catch (e) {
        // Jika Server Gagal (Timeout/Down) ATAU 401
        
        // Jika 401, Interceptor Dio di atas SUDAH menangani logout.
        // Jadi di sini kita hanya perlu menangani kasus Offline.
        if (e is DioException && e.response?.statusCode != 401) {
           debugPrint("⚠️ Server unreachable. Masuk Mode Offline.");
           connectionNotifier.setOffline(); // Set UI jadi Offline (Merah)
        }
      }

      // Apapun yang terjadi (Online sukses / Offline), 
      // selama Token Lokal ada (dan bukan 401), kita izinkan masuk Home.
      return true; 

    } catch (e) {
      return false;
    }
  }

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