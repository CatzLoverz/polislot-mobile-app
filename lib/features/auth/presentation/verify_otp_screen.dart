import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/otp_type.dart';
import '../../../core/utils/snackbar_utils.dart'; // ✅ Import Helper SnackBar
import 'auth_controller.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String? email;
  final OtpType otpType;

  const VerifyOtpScreen({
    super.key,
    this.email,
    this.otpType = OtpType.register,
  });

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  late String _email;
  
  // State lokal untuk loading resend
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _email = widget.email ?? '';
    if (_email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // --- LOGIC VERIFIKASI ---
  Future<void> _verify() async {
    if (_otpController.text.length != 6) {
      // ✅ Gunakan Helper SnackBar (Error)
      AppSnackBars.show(context, "Masukkan 6 digit kode OTP", isError: true);
      return;
    }

    final notifier = ref.read(authControllerProvider.notifier);
    bool success = false;

    if (widget.otpType == OtpType.register) {
      success = await notifier.registerOtpVerify(email: _email, otp: _otpController.text);
    } else {
      success = await notifier.forgotPasswordOtpVerify(email: _email, otp: _otpController.text);
    }

    if (!mounted) return;

    if (success) {
      AppSnackBars.show(context, "Verifikasi Berhasil!");
      
      if (widget.otpType == OtpType.register) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
      } else {
        Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: {'email': _email});
      }
    } else {
      final error = ref.read(authControllerProvider).error.toString().replaceAll('Exception: ', '');
      AppSnackBars.show(context, error, isError: true);
    }
  }

  // --- LOGIC RESEND ---
  Future<void> _resend() async {
    setState(() => _isResending = true);

    final notifier = ref.read(authControllerProvider.notifier);
    bool success = false;

    if (widget.otpType == OtpType.register) {
      success = await notifier.registerOtpResend(email: _email);
    } else {
      success = await notifier.forgotPasswordOtpResend(email: _email);
    }
    
    if (mounted) {
      setState(() => _isResending = false);
      
      if (success) {
        AppSnackBars.show(context, "Kode OTP baru telah dikirim.");
      } else {
        AppSnackBars.show(context, "Gagal mengirim ulang OTP.", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingVerify = ref.watch(authControllerProvider).isLoading;
    
    // Title AppBar (Sesuai design lama)
    final appBarTitle = widget.otpType == OtpType.register ? "Verifikasi Akun" : "Reset Password";

    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ FIX APPBAR: Title di tengah & Warna Biru
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Title di tengah
        title: Text(
          appBarTitle, 
          style: const TextStyle(
            color: AppTheme.primaryColor, // Warna Biru
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIX BODY: Judul 'Masukkan Kode OTP'
            const Text(
              'Masukkan Kode OTP', 
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w800, 
                color: Color(0xFF0D47A1) // Biru Gelap (Sesuai file lama)
              )
            ),
            const SizedBox(height: 8),
            
            Text(
              'Kami telah mengirim kode verifikasi ke email:', 
              style: TextStyle(color: Colors.grey[700], fontSize: 16)
            ),
            const SizedBox(height: 4),
            
            // ✅ FIX EMAIL: Warna Biru (Primary)
            Text(
              _email, 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: AppTheme.primaryColor, // <-- Warna Biru
                fontSize: 16
              )
            ),
            const SizedBox(height: 40),

            // PIN INPUT
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              autoDisposeControllers: false,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 45,
                activeColor: AppTheme.primaryColor,
                inactiveColor: Colors.grey.shade300,
                selectedColor: AppTheme.primaryColor,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
              ),
              enableActiveFill: false,
              keyboardType: TextInputType.number,
              onCompleted: (_) => _verify(),
              onChanged: (_) {},
            ),

            const SizedBox(height: 30),

            // BUTTON VERIFIKASI
            SizedBox(
              width: double.infinity,
              height: 55, // Tinggi tombol disesuaikan
              child: ElevatedButton(
                onPressed: (isLoadingVerify || _isResending) ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                child: isLoadingVerify
                  ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    )
                  : const Text(
                      "Verifikasi Akun", 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // BUTTON RESEND (Loading Animation)
            Center(
              child: TextButton(
                onPressed: (isLoadingVerify || _isResending) ? null : _resend,
                child: _isResending
                    ? const SizedBox(
                        height: 16, 
                        width: 16, 
                        child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2)
                      )
                    : const Text(
                        "Kirim Ulang Kode", 
                        style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)
                      ),
              ),
            ),

            Center(
              child: Text(
                "Belum menerima kode? Periksa folder spam email Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}