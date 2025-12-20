import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../presentation/profile_controller.dart';

class ProfileEditSection extends ConsumerStatefulWidget {
  const ProfileEditSection({super.key});

  @override
  ConsumerState<ProfileEditSection> createState() => _ProfileEditSectionState();
}

class _ProfileEditSectionState extends ConsumerState<ProfileEditSection> {
  File? _selectedImage;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureCurrentPass = true;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;
  bool _isNotSameAsCurrent = false;
  bool _isMatchConfirm = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }

    _newPassController.addListener(_validatePasswordRules);
    _confirmPassController.addListener(_validateMatch);
    _currentPassController.addListener(_validatePasswordRules);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _validatePasswordRules() {
    final pass = _newPassController.text;
    final current = _currentPassController.text;

    setState(() {
      _hasMinLength = pass.length >= 8;
      _hasUppercase = pass.contains(RegExp(r'[A-Z]'));
      _hasLowercase = pass.contains(RegExp(r'[a-z]'));
      _hasNumber = pass.contains(RegExp(r'[0-9]'));
      _hasSymbol = pass.contains(RegExp(r'[^a-zA-Z0-9]'));
      _isNotSameAsCurrent = pass.isNotEmpty && pass != current;
    });
    _validateMatch();
  }

  void _validateMatch() {
    setState(() {
      _isMatchConfirm =
          _newPassController.text.isNotEmpty &&
          _newPassController.text == _confirmPassController.text;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _handleUpdate() async {
    if (_nameController.text.trim().isEmpty) {
      AppSnackBars.show(context, "Nama tidak boleh kosong", isError: true);
      return;
    }

    if (_newPassController.text.isNotEmpty) {
      if (!_hasMinLength || !_hasUppercase || !_hasNumber || !_hasSymbol) {
        AppSnackBars.show(
          context,
          "Password baru belum memenuhi syarat keamanan",
          isError: true,
        );
        return;
      }
      if (!_isMatchConfirm) {
        AppSnackBars.show(
          context,
          "Konfirmasi password tidak cocok",
          isError: true,
        );
        return;
      }
    }

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          avatar: _selectedImage,
          currentPassword: _currentPassController.text.isNotEmpty
              ? _currentPassController.text
              : null,
          newPassword: _newPassController.text.isNotEmpty
              ? _newPassController.text
              : null,
          confirmPassword: _confirmPassController.text.isNotEmpty
              ? _confirmPassController.text
              : null,
        );

    if (!mounted) return;

    if (success) {
      AppSnackBars.show(context, "Profil berhasil diperbarui!");
      Navigator.pop(context);
    } else {
      final error = ref
          .read(profileControllerProvider)
          .error
          .toString()
          .replaceAll('Exception: ', '');
      AppSnackBars.show(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final isUpdating = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text(
          "Ubah Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFEAF3FF),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (user?.fullAvatarUrl.isNotEmpty ?? false
                              ? NetworkImage(user!.fullAvatarUrl)
                              : null),
                    child:
                        _selectedImage == null &&
                            (user?.fullAvatarUrl.isEmpty ?? true)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF1565C0),
                          )
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _inputField(
              "Email (tidak dapat diubah)",
              _emailController,
              enabled: false,
            ),
            _inputField("Nama Lengkap", _nameController),

            const SizedBox(height: 20),
            const Text(
              "Ganti Kata Sandi (Opsional)",
              style: TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            _inputField(
              "Kata Sandi Lama",
              _currentPassController,
              obscure: _obscureCurrentPass,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrentPass ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF1565C0),
                ),
                onPressed: () =>
                    setState(() => _obscureCurrentPass = !_obscureCurrentPass),
              ),
            ),

            _inputField("Kata Sandi Baru", _newPassController, obscure: true),

            if (_newPassController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _RuleItem("Min. 8 Karakter", _hasMinLength),
                        ),
                        Expanded(
                          child: _RuleItem("Huruf Besar (A-Z)", _hasUppercase),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _RuleItem("Huruf Kecil (a-z)", _hasLowercase),
                        ),
                        Expanded(child: _RuleItem("Angka (0-9)", _hasNumber)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _RuleItem("Simbol", _hasSymbol)),
                        Expanded(
                          child: _RuleItem(
                            "Beda dari lama",
                            _isNotSameAsCurrent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            _inputField(
              "Konfirmasi Kata Sandi Baru",
              _confirmPassController,
              obscure: true,
            ),

            if (_confirmPassController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      _isMatchConfirm ? Icons.check_circle : Icons.cancel,
                      color: _isMatchConfirm ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isMatchConfirm
                          ? "Password cocok"
                          : "Password tidak cocok",
                      style: TextStyle(
                        color: _isMatchConfirm ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            isUpdating
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1565C0)),
                  )
                : ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Batal",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;
  final bool isValid;
  const _RuleItem(this.text, this.isValid);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isValid ? Colors.green : Colors.grey,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.green[700] : Colors.grey[600],
                fontSize: 11,
                fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
