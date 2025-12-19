import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'park_model.dart'; // Pastikan file model sudah ada (ParkVisualData)

part 'park_repository.g.dart';

@Riverpod(keepAlive: true)
class ParkRepositoryInstance extends _$ParkRepositoryInstance {
  @override
  ParkRepository build() => ParkRepository(ref.watch(dioClientServiceProvider));
}

class ParkRepository {
  final Dio _dio;
  ParkRepository(this._dio);

  // Ambil List
  Future<List<ParkAreaItem>> getParkAreas() async {
    try {
      final response = await _dio.get('/map-visualization');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data'];
        return list.map((e) => ParkAreaItem.fromJson(e)).toList();
      }
      throw Exception("Gagal memuat daftar area.");
    } catch (e) {
      rethrow;
    }
  }

  // Ambil Visualisasi
  Future<ParkVisualData> getParkVisualization(String areaId) async {
    try {
      final response = await _dio.get('/map-visualization/$areaId');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return ParkVisualData.fromJson(response.data['data']);
      }
      throw Exception("Gagal memuat peta.");
    } catch (e) {
      rethrow;
    }
  }

  // Kirim Validasi
  Future<String> sendValidation(int subareaId, String statusContent) async {
    try {
      final response = await _dio.post(
        '/validation',
        data: {
          'park_subarea_id': subareaId,
          'user_validation_content':
              statusContent, // 'banyak', 'terbatas', 'penuh'
        },
      );
      return response.data['message'] ?? "Validasi berhasil.";
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      rethrow;
    }
  }
}
