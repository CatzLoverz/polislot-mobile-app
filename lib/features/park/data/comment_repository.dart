import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import 'comment_model.dart';

part 'comment_repository.g.dart';

@Riverpod(keepAlive: true)
class CommentRepositoryInstance extends _$CommentRepositoryInstance {
  @override
  CommentRepository build() =>
      CommentRepository(ref.watch(dioClientServiceProvider));
}

class CommentRepository {
  final Dio _dio;
  CommentRepository(this._dio);

  Future<List<Comment>> getComments(int subareaId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/comment',
        queryParameters: {'park_subarea_id': subareaId, 'page': page},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['list'];
        return list.map((e) => Comment.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> postComment(int subareaId, String content, File? image) async {
    try {
      FormData formData = FormData.fromMap({
        'park_subarea_id': subareaId,
        'subarea_comment_content': content,
      });

      if (image != null) {
        formData.files.add(
          MapEntry(
            'subarea_comment_image',
            await MultipartFile.fromFile(image.path),
          ),
        );
      }

      await _dio.post('/comment', data: formData);
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

  Future<void> editComment(int commentId, String content, File? image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      FormData formData = FormData.fromMap({
        'subarea_comment_content': content,
        '_method': 'PUT',
      });

      if (image != null) {
        formData.files.add(
          MapEntry(
            'subarea_comment_image',
            await MultipartFile.fromFile(image.path),
          ),
        );
      }

      await _dio.post(
        '/comment/$commentId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );
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

  Future<void> deleteComment(int commentId) async {
    try {
      await _dio.delete('/comment/$commentId');
    } catch (e) {
      rethrow;
    }
  }
}
