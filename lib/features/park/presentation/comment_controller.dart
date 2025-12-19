import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/comment_model.dart';
import '../data/comment_repository.dart';

part 'comment_controller.g.dart';

@riverpod
class CommentListController extends _$CommentListController {
  @override
  FutureOr<List<Comment>> build(int subareaId) {
    return ref.read(commentRepositoryInstanceProvider).getComments(subareaId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(commentRepositoryInstanceProvider).getComments(subareaId),
    );
  }
}

@riverpod
class CommentActionController extends _$CommentActionController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> postComment(int subareaId, String content, File? image) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(commentRepositoryInstanceProvider)
          .postComment(subareaId, content, image),
    );

    if (!state.hasError) {
      // Refresh list
      ref.invalidate(commentListControllerProvider(subareaId));
      return true;
    }
    return false;
  }

  Future<bool> editComment(
    int subareaId,
    int commentId,
    String content,
    File? image,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(commentRepositoryInstanceProvider)
          .editComment(commentId, content, image),
    );

    if (!state.hasError) {
      ref.invalidate(commentListControllerProvider(subareaId));
      return true;
    }
    return false;
  }

  Future<bool> deleteComment(int subareaId, int commentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () =>
          ref.read(commentRepositoryInstanceProvider).deleteComment(commentId),
    );

    if (!state.hasError) {
      ref.invalidate(commentListControllerProvider(subareaId));
      return true;
    }
    return false;
  }
}
