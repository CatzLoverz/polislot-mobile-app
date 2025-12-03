import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'info_board_model.dart';

part 'info_board_repository.g.dart';

@Riverpod(keepAlive: true)
class InfoBoardRepositoryInstance extends _$InfoBoardRepositoryInstance {
  @override
  InfoBoardRepository build() {
    return InfoBoardRepository(ref.watch(dioClientServiceProvider));
  }
}

class InfoBoardRepository {
  final Dio _dio;
  InfoBoardRepository(this._dio);

  Future<List<InfoBoard>> getInfoBoards() async {
    try {
      // Endpoint sesuai api.php Laravel
      final response = await _dio.get('/info-board');
      
      final data = response.data;
      if (response.statusCode == 200 && data['status'] == 'success') {
        final List list = data['data'];
        return list.map((e) => InfoBoard.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // Jika error/kosong, kembalikan list kosong agar UI tidak crash
      return [];
    }
  }
}