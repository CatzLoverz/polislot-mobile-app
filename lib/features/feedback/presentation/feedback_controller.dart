import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/feedback_repository.dart';
import '../data/feedback_category_model.dart';

part 'feedback_controller.g.dart';

@riverpod
class FeedbackCategoriesController extends _$FeedbackCategoriesController {
  
  @override
  Future<List<FeedbackCategory>> build() async {
    final repo = ref.watch(feedbackRepositoryInstanceProvider);
    
    // Panggil API
    return await repo.getCategories();
  }
}

@riverpod
class FeedbackFormController extends _$FeedbackFormController {
  @override
  FutureOr<void> build() {
    // Initial state: idle
  }

  Future<bool> submitFeedback({
    required int categoryId,
    required String title,
    required String description,
  }) async {
    // Set Loading
    state = const AsyncLoading();

    // Panggil API
    final result = await AsyncValue.guard(() async {
      await ref.read(feedbackRepositoryInstanceProvider).sendFeedback(
        categoryId: categoryId,
        title: title,
        description: description,
      );
    });

    // Update State
    state = result;

    return !state.hasError;
  }
}