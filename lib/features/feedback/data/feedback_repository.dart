import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'feedback_category_model.dart';

part 'feedback_repository.g.dart';

@Riverpod(keepAlive: true)
class FeedbackRepositoryInstance extends _$FeedbackRepositoryInstance {
  @override
  FeedbackRepository build() {
    return FeedbackRepository(ref.watch(dioClientServiceProvider));
  }
}

class FeedbackRepository {
  final Dio _dio;
  FeedbackRepository(this._dio);

  // 1. Ambil Daftar Kategori
  Future<List<FeedbackCategory>> getCategories() async {
    try {
      final response = await _dio.get('/feedback-categories');
      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List list = data['data'];
        return list.map((e) => FeedbackCategory.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. Kirim Feedback
  Future<void> sendFeedback({
    required int categoryId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.post('/feedback', data: {
        'category': categoryId, // Sesuai validasi Laravel (category)
        'title': title,
        'description': description,// Default value jika diperlukan
      });

      final data = response.data;
      if (response.statusCode != 201 && data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Gagal mengirim masukan');
      }
    } catch (e) {
      throw Exception(DioErrorHandler.parse(e));
    }
  }
}