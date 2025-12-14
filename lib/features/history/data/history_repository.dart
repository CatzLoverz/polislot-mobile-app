import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'history_model.dart';

part 'history_repository.g.dart';

@Riverpod(keepAlive: true)
class HistoryRepositoryInstance extends _$HistoryRepositoryInstance {
  @override
  HistoryRepository build() {
    return HistoryRepository(ref.watch(dioClientServiceProvider));
  }
}

class HistoryRepository {
  final Dio _dio;
  HistoryRepository(this._dio);

  Future<HistoryResponse> getHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/history', queryParameters: {
        'page': page,
        'limit': limit,
      });
      
      final data = response.data;
      if (response.statusCode == 200 && data['status'] == 'success') {
        return HistoryResponse.fromJson(data['data']);
      }
      throw Exception("Gagal memuat data history.");
    } catch (e) {
      rethrow;
    }
  }
}