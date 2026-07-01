import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/validator_utils.dart';
import '../../../core/network/dio_client.dart';
import 'auth_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? token;
  const ResetPasswordScreen({super.key, this.email, this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _token;

  // Warna sesuai file lama (Dikembalikan)
  static const Color _deepBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _email = widget.email ?? '';
    _token = widget.token ?? '';

    // Safety check jika email kosong (reload/navigasi manual)
    if (_email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // 0. Manual Validation (Snackbar Style)
    if (_passwordController.text.isEmpty) {
      AppSnackBars.show(context, "Password tidak boleh kosong", isError: true);
      return;
    }

    if (!ValidatorUtils.isValidPassword(_passwordController.text)) {
      AppSnackBars.show(
        context,
        ValidatorUtils.passwordRequirementMsg,
        isError: true,
      );
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      AppSnackBars.show(
        context,
        "Konfirmasi password tidak boleh kosong",
        isError: true,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackBars.show(context, "Password tidak cocok", isError: true);
      return;
    }

    // 1. Panggil AuthController
    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: _email,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          token: _token,
        );

    // 2. Cek Mounted (Async Gap Fix)
    if (!mounted) return;

    // 3. Handle Hasil
    if (success) {
      AppSnackBars.show(context, "Password Berhasil Direset! Silakan Login.");

      // Tunggu sebentar agar user baca snackbar (Opsional, UX)
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // Kembali ke Login Screen dan hapus history
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      final error = DioErrorHandler.parse(
          ref.read(authControllerProvider).error ?? "Gagal mereset password"
      );
      AppSnackBars.show(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Atur Ulang Password'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _deepBlue),
        titleTextStyle: const TextStyle(
          color: _deepBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Password Baru',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Masukkan kata sandi baru untuk akun $_email',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 30),

                // Password Baru (Tanpa Mata)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Selalu tersembunyi
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _deepBlue, width: 2),
                    ),
                    // Suffix Icon dihapus sesuai permintaan
                  ),
                  // Validator Property dihapus (Pindah ke logic submit/Snackbar)
                ),

                // HELPER TEXT (Syarat Password dengan Bintang Merah)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20, left: 5),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      children: const [
                        TextSpan(
                          text: '* ',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Min. 8 karakter, mengandung huruf besar/kecil, angka dan simbol.',
                        ),
                      ],
                    ),
                  ),
                ),

                // Konfirmasi Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true, // Selalu tersembunyi
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _deepBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Reset Password
                ElevatedButton(
                  onPressed: isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
