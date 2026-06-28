import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/faq_model.dart';
import '../data/faq_repository.dart';

part 'faq_controller.g.dart';

@riverpod
class FaqController extends _$FaqController {

  /// FAQ statis yang tampil saat pengguna tidak ada koneksi internet.
  static const List<Map<String, String>> _offlineFaqs = [
    {
      'id': '-1',
      'question': 'Mengapa aplikasi menyatakan saya sedang offline?',
      'answer': 'Aplikasi membutuhkan koneksi internet yang stabil untuk mengambil data. Silakan periksa apakah data seluler atau Wi-Fi Anda aktif dan memiliki sinyal yang cukup.',
    },
    {
      'id': '-2',
      'question': 'Apa yang harus saya lakukan jika koneksi bermasalah?',
      'answer': '1. Pastikan mode pesawat tidak aktif.\n2. Coba matikan dan nyalakan kembali Wi-Fi atau data seluler Anda.\n3. Jika menggunakan Wi-Fi, pastikan router Anda terhubung ke internet.\n4. Coba buka aplikasi lain untuk memastikan perangkat Anda terhubung ke internet.',
    },
    {
      'id': '-3',
      'question': 'Apakah saya tetap bisa menggunakan aplikasi saat offline?',
      'answer': 'Beberapa fitur mungkin dibatasi atau tidak dapat diakses sama sekali karena aplikasi memerlukan data langsung (real-time) dari server.',
    },
  ];

  /// FAQ statis yang tampil saat server tidak dapat dijangkau.
  static const List<Map<String, String>> _serverErrorFaqs = [
    {
      'id': '-4',
      'question': 'Mengapa aplikasi tidak dapat terhubung ke server?',
      'answer': 'Saat ini server sedang mengalami gangguan atau sedang dalam masa pemeliharaan rutin. Tim teknis kami sedang berupaya untuk memperbaikinya secepat mungkin.',
    },
    {
      'id': '-5',
      'question': 'Apa yang harus saya lakukan saat terjadi masalah server?',
      'answer': 'Anda tidak perlu melakukan apa-apa. Silakan tunggu beberapa saat dan coba muat ulang aplikasi dengan menarik layar ke bawah (pull to refresh).',
    },
    {
      'id': '-6',
      'question': 'Apakah data saya aman saat server bermasalah?',
      'answer': 'Ya, data Anda tersimpan dengan aman di database kami. Masalah server biasanya hanya memengaruhi akses sementara ke sistem.',
    },
  ];

  @override
  Future<List<FaqModel>> build() async {
    final repo = ref.watch(faqRepositoryInstanceProvider);
    return await repo.getFaqs();
  }

  /// Mengembalikan daftar FAQ statis untuk kondisi offline (koneksi).
  List<FaqModel> getOfflineFaqs() {
    return _offlineFaqs
        .map((e) => FaqModel(
              id: int.parse(e['id']!),
              question: e['question']!,
              answer: e['answer']!,
            ))
        .toList();
  }

  /// Mengembalikan daftar FAQ statis untuk kondisi error server.
  List<FaqModel> getServerErrorFaqs() {
    return _serverErrorFaqs
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