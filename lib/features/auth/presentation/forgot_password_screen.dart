import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/enums/otp_type.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _sendOtp() async {
    // 1. Validasi Input
    if (!_formKey.currentState!.validate()) return;

    // 2. Panggil Controller (Kirim OTP)
    final success = await ref.read(authControllerProvider.notifier).forgotPasswordVerify(
      email: _emailController.text.trim(),
    );

    // 3. Cek Mounted (Wajib setelah await)
    if (!mounted) return;

    // 4. Handle Hasil
    if (success) {
      // ✅ MODIFIKASI: Langsung Navigasi (Tanpa Dialog)
      
      // Tampilkan feedback sukses singkat
      AppSnackBars.show(context, "Kode OTP telah dikirim ke email Anda.");
      
      // Langsung pindah ke layar Verifikasi OTP
      Navigator.pushNamed(
        context,
        AppRoutes.verifyOtp,
        arguments: {
          'email': _emailController.text.trim(),
          'type': OtpType.forgotPassword, // Mode Lupa Password
        },
      );
    } else {
      // Tampilkan Error
      final error = ref.read(authControllerProvider).error.toString().replaceAll('Exception: ', '');
      AppSnackBars.show(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Lupa Password',
          style: const TextStyle(
            color: AppTheme.primaryColor, // Warna Biru
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
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
                  'Atur Ulang Password Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Masukkan alamat email Anda untuk menerima kode verifikasi (OTP).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 35),

                // Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email tidak boleh kosong';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Tombol Kirim
                ElevatedButton(
                  onPressed: isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Kode Verifikasi',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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