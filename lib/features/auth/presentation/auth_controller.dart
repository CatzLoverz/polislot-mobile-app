import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/connection_status_provider.dart';
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
        return false; 
      }

      state = AsyncData(localUser);

      // 2. Cek Koneksi Server (Ping)
      try {
        await repo.checkConnectivity();
        
        // 3. Jika Server OK -> Validasi Token & Update Data (Termasuk Trigger Misi)
        final freshUser = await repo.fetchUserProfile();
        state = AsyncData(freshUser);
        connectionNotifier.setOnline(); 
        
      } catch (e) {
        if (e is DioException && e.response?.statusCode != 401) {
           debugPrint("⚠️ Server unreachable. Masuk Mode Offline.");
           connectionNotifier.setOffline();
        }
      }

      return true; 

    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryInstanceProvider);
      
      // 1. Lakukan Login (Dapat Token)
      await repo.login(email: email, password: password);
      
      // 2. ✅ WAJIB: Fetch Profile untuk Trigger Mission Login & Update Data
      return await repo.fetchUserProfile();
    });
    
    state = result; 
    return !state.hasError;
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
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryInstanceProvider);

      // 1. Verifikasi OTP (Biasanya server langsung generate token di sini)
      await repo.registerOtpVerify(email: email, otp: otp);

      // 2. ✅ WAJIB: Fetch Profile agar langsung masuk dashboard dengan data fresh
      return await repo.fetchUserProfile();
    });

    state = result; 
    return !state.hasError;
  }

  Future<bool> registerOtpResend({required String email}) async {
    try { await ref.read(authRepositoryInstanceProvider).registerOtpResend(email: email); return true; } catch (_) { return false; }
  }

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