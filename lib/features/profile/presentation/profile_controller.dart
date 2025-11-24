import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/profile_repository.dart';
import '../../auth/presentation/auth_controller.dart'; // Import AuthController

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {
    // Initial state: idle
  }

  Future<bool> updateProfile({
    required String name,
    File? avatar,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    // 1. UI Loading
    state = const AsyncLoading();

    // 2. Eksekusi Logic
    final result = await AsyncValue.guard(() async {
      // A. Panggil API Update
      final updatedUser = await ref.read(profileRepositoryInstanceProvider).updateProfile(
        name: name,
        avatar: avatar,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // B. ⚠️ SINKRONISASI PENTING!
      // Beritahu AuthController bahwa data user berubah.
      // Ini akan memicu rebuild pada semua UI yang watch authControllerProvider (Home & Profile).
      ref.read(authControllerProvider.notifier).updateUser(updatedUser);
      
      return updatedUser;
    });

    // 3. Update State Controller ini
    state = result;

    // 4. Return status (True jika sukses, False jika error)
    return !state.hasError;
  }
}