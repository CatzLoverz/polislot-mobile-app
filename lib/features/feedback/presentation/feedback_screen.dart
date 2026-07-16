import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:polislot_mobile_catz/core/utils/snackbar_utils.dart';
import 'package:polislot_mobile_catz/core/network/dio_client.dart';
import '../data/feedback_category_model.dart';
import 'feedback_controller.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  FeedbackCategory? _selectedCategory;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      AppSnackBars.show(context, "Pilih kategori terlebih dahulu", isError: true);
      return;
    }
    if (_judulCtrl.text.trim().isEmpty) {
      AppSnackBars.show(context, "Judul tidak boleh kosong", isError: true);
      return;
    }
    if (_deskripsiCtrl.text.trim().isEmpty) {
      AppSnackBars.show(context, "Deskripsi tidak boleh kosong", isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref.read(feedbackFormControllerProvider.notifier).submitFeedback(
      categoryId: _selectedCategory!.id,
      title: _judulCtrl.text.trim(),
      description: _deskripsiCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      AppSnackBars.show(context, "Masukan berhasil dikirim");
      Navigator.pop(context);
    } else {
      final errorState = ref.read(feedbackFormControllerProvider);
      final errorMsg = DioErrorHandler.parse(errorState.error ?? "Gagal mengirim masukan");
      AppSnackBars.show(context, errorMsg, isError: true);
    }
  }

  // Fungsi Fetch Data (Disesuaikan untuk DropdownSearch Terbaru)
  // Menerima filter dan loadProps (wajib untuk sintaks baru)
  Future<List<FeedbackCategory>> _getAsyncCategories(String filter, LoadProps? loadProps) async {
    // Refresh provider untuk mendapatkan data terbaru dari server
    return await ref.refresh(feedbackCategoriesControllerProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(feedbackFormControllerProvider);
    final isSubmitting = formState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomAppBar(
        title: Text("Masukan Pengguna"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Kirim Masukan & Saran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),

          // ✅ DROPDOWN SEARCH (SYNTAX TERBARU v9/v10)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))]
            ),
            child: DropdownSearch<FeedbackCategory>(
              // 1. Gunakan 'items' untuk async (pengganti asyncItems)
              items: (filter, loadProps) => _getAsyncCategories(filter, loadProps),
              
              itemAsString: (FeedbackCategory u) => u.name,
              compareFn: (i1, i2) => i1.id == i2.id, // Penting untuk membandingkan objek
              onSelected: (FeedbackCategory? data) => setState(() => _selectedCategory = data),
              selectedItem: _selectedCategory,
              
              // 2. Gunakan 'decoratorProps' (pengganti dropdownDecoratorProps)
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: "Pilih Kategori",
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
              ),
              
              // 3. Gunakan 'popupProps'
              popupProps: PopupProps.menu(
                showSearchBox: false,
                fit: FlexFit.loose,
                menuProps: MenuProps(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                ),
                // 4. itemBuilder WAJIB 4 Parameter (context, item, isDisabled, isSelected)
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return ListTile(
                    title: Text(
                      item.name, 
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  );
                },
                // Loading Builder
                loadingBuilder: (context, searchEntry) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                // Error Builder
                errorBuilder: (context, searchEntry, exception) => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text("Gagal memuat data.", style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),

          _inputField("Judul Masukan", _judulCtrl),
          _inputField("Deskripsi Detail", _deskripsiCtrl, maxLines: 4),
          
          const SizedBox(height: 20),
          
          // Tombol Kirim
          isSubmitting 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Kirim Masukan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
          
          const SizedBox(height: 10),
          
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text("Kembali", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))]
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: const InputDecoration(border: InputBorder.none)
            ),
          ),
        ],
      ),
    );
  }
}