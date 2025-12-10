import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'mission_model.dart';

part 'mission_repository.g.dart';

@Riverpod(keepAlive: true)
class MissionRepositoryInstance extends _$MissionRepositoryInstance {
  @override
  MissionRepository build() {
    return MissionRepository(ref.watch(dioClientServiceProvider));
  }
}

class MissionRepository {
  final Dio _dio;
  MissionRepository(this._dio);

  Future<MissionScreenData> getMissionData() async {
    try {
      final response = await _dio.get('/missions');
      final data = response.data;
      if (response.statusCode == 200 && data['status'] == 'success') {
        return MissionScreenData.fromJson(data['data']);
      }
      throw Exception("Gagal memuat data misi");
    } catch (e) {
      rethrow;
    }
  }
}