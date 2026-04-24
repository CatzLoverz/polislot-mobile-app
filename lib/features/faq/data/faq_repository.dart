import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'faq_model.dart';

part 'faq_repository.g.dart';

@Riverpod(keepAlive: true)
class FaqRepositoryInstance extends _$FaqRepositoryInstance {
  @override
  FaqRepository build() {
    return FaqRepository(ref.watch(dioClientServiceProvider));
  }
}

class FaqRepository {
  final Dio _dio;
  FaqRepository(this._dio);

  // Mengambil daftar FAQ
  Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await _dio.get('/user-faq');
      final data = response.data;

      // Sesuai dengan controller Anda yang mengembalikan 'status' => 'success'
      if (response.statusCode == 200 && data['status'] == 'success') {
        final List list = data['data'];
        return list.map((e) => FaqModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}