import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/faq_model.dart';
import '../data/faq_repository.dart';

part 'faq_controller.g.dart';

@riverpod
class FaqController extends _$FaqController {

  /// FAQ statis yang tampil saat pengguna offline.
  /// Topik: masalah jaringan & cara pengecekan koneksi.
  static const List<Map<String, String>> _offlineFaqs = [
    {
      'id': '-1',
      'question': 'Mengapa koneksi internet saya tiba-tiba mati?',
      'answer':
          'Koneksi internet bisa terputus karena beberapa sebab umum: '
          'gangguan dari ISP (provider), router/modem yang perlu di-restart, '
          'tagihan paket data habis, atau sinyal Wi-Fi yang lemah karena jarak '
          'terlalu jauh dari router. Coba periksa satu per satu mulai dari yang paling mudah.',
    },
    {
      'id': '-2',
      'question': 'Bagaimana cara memeriksa apakah masalah ada di perangkat saya atau di jaringan?',
      'answer':
          '1. Coba hubungkan perangkat lain (HP/laptop lain) ke Wi-Fi yang sama.\n'
          '2. Jika perangkat lain juga tidak bisa, masalah ada di router atau ISP.\n'
          '3. Jika hanya perangkat Anda yang bermasalah, coba matikan Wi-Fi lalu '
          'nyalakan kembali, atau restart perangkat Anda.',
    },
    {
      'id': '-3',
      'question': 'Apa langkah pertama yang harus dilakukan saat internet tidak bisa diakses?',
      'answer':
          'Ikuti langkah berikut secara berurutan:\n'
          '1. Matikan dan nyalakan kembali Wi-Fi di perangkat Anda.\n'
          '2. Restart router/modem (cabut listrik 30 detik, lalu pasang kembali).\n'
          '3. Periksa apakah lampu indikator internet pada router menyala normal.\n'
          '4. Jika tetap tidak bisa, hubungi layanan pelanggan ISP Anda.',
    },
  ];

  @override
  Future<List<FaqModel>> build() async {
    final repo = ref.watch(faqRepositoryInstanceProvider);
    return await repo.getFaqs();
  }

  /// Mengembalikan daftar FAQ statis untuk kondisi offline.
  List<FaqModel> getOfflineFaqs() {
    return _offlineFaqs
        .map((e) => FaqModel(
              id: int.parse(e['id']!),
              question: e['question']!,
              answer: e['answer']!,
            ))
        .toList();
  }

  /// Refresh data manual dari API.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(faqRepositoryInstanceProvider);
      return await repo.getFaqs();
    });
  }
}