import 'package:flutter/material.dart';

class ProfileFeedbackSection extends StatefulWidget {
  final VoidCallback onCancel;
  const ProfileFeedbackSection({super.key, required this.onCancel});

  @override
  State<ProfileFeedbackSection> createState() => _ProfileFeedbackSectionState();
}

class _ProfileFeedbackSectionState extends State<ProfileFeedbackSection> {
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  String? _selectedKategori;
  String? _selectedJenis;

  final List<String> kategoriList = ['Pengguna Parkir', 'Penyedia Layanan'];
  final List<String> jenisList = ['Kendala Teknis', 'Perilaku', 'Saran'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Masukan Pengguna", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        const SizedBox(height: 16),
        _dropdownField("Kategori", kategoriList, _selectedKategori, (val) => setState(() => _selectedKategori = val)),
        _dropdownField("Jenis Masukan", jenisList, _selectedJenis, (val) => setState(() => _selectedJenis = val)),
        _inputField("Judul", _judulCtrl),
        _inputField("Deskripsi", _deskripsiCtrl, maxLines: 4),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukan dikirim"), backgroundColor: Colors.green));
            widget.onCancel();
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Kirim Masukan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: widget.onCancel,
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1565C0)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Kembali", style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _inputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))]),
            child: TextField(controller: controller, maxLines: maxLines, decoration: const InputDecoration(border: InputBorder.none)),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(String label, List<String> list, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))]),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(value: value, isExpanded: true, hint: const Text("Pilih"), onChanged: onChanged, items: list.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()),
            ),
          ),
        ],
      ),
    );
  }
}