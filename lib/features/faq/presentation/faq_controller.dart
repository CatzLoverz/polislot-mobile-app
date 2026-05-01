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

  /// FAQ statis tambahan yang selalu tampil saat pengguna online.
  /// Topik: Informasi umum aplikasi (POLISLOT).
  static const List<Map<String, String>> _onlineHardcodedFaqs = [
    {
      'id': '100',
      'question': 'Apa itu aplikasi POLISLOT?',
      'answer': 'POLISLOT adalah platform parkir cerdas yang membantu civitas akademika Polibatam mencari slot parkir yang tersedia secara real-time melalui bantuan Computer Vision dan laporan komunitas.',
    },
    {
      'id': '101',
      'question': 'Bagaimana cara melaporkan status area parkiran Politeknik Negeri Batam?',
      'answer': 'Anda dapat memilih area yang ingin dilaporkan melalui menu utama (Home). Setelah itu, Anda akan masuk ke fitur parkiran. Tekan menu Validasi, lalu pilih status ketersediaan parkir: penuh (merah), terbatas (kuning), atau banyak tersedia (hijau).',
    },
    {
      'id': '102',
      'question': 'Bagaimana cara menukar hadiahnya yang telah kami beli menggunakan koin?',
      'answer': 'Anda dapat menukarkan hadiah di Pusat Informasi Politeknik Negeri Batam pada hari Senin hingga Jumat, pukul 08.00-16.00.',
    },
    {
      'id': '103',
      'question': 'Jika ada keluhan terhadap area parkir Politeknik Negeri Batam dimana saya melaporkannya?',
      'answer': 'Anda dapat melaporkannya melalui fitur komentar. Pertama, pilih area yang ingin dilaporkan di menu Home atau menu utama, kemudian masuk ke bagian komentar. Pastikan Anda menyertakan bukti yang jelas dengan menambahkan foto.',
    },
    {
      'id': '104',
      'question': 'Bagaimana cara mencari lokasi parkir di aplikasi Polislot?',
      'answer': 'Jika Anda ingin mencari parkir di aplikasi Polislot, Anda dapat memilih area parkir terlebih dahulu melalui menu utama. Setelah masuk ke tampilan parkir, tekan tombol Rute. Selanjutnya, Anda akan diarahkan ke Google Maps untuk mendapatkan petunjuk arah yang lebih detail menuju lokasi parkir tersebut.',
    },
  ];

  @override
  Future<List<FaqModel>> build() async {
    final repo = ref.watch(faqRepositoryInstanceProvider);
    
    // 1. Ambil data dari API
    final List<FaqModel> apiFaqs = await repo.getFaqs();

    // 2. Map data online hardcoded menjadi model
    final List<FaqModel> hardcodedOnline = _onlineHardcodedFaqs.map((e) => FaqModel(
      id: int.parse(e['id']!),
      question: e['question']!,
      answer: e['answer']!,
    )).toList();

    // 3. Gabungkan: Hardcoded di atas, data API di bawah
    return [...hardcodedOnline, ...apiFaqs];
  }

  /// Mengembalikan daftar FAQ statis untuk kondisi offline (Topik Jaringan).
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
      final List<FaqModel> apiFaqs = await repo.getFaqs();
      
      final List<FaqModel> hardcodedOnline = _onlineHardcodedFaqs.map((e) => FaqModel(
        id: int.parse(e['id']!),
        question: e['question']!,
        answer: e['answer']!,
      )).toList();

      return [...hardcodedOnline, ...apiFaqs];
    });
  }
}