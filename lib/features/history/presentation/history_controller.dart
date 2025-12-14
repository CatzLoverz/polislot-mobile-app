import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/history_repository.dart';
import '../data/history_model.dart';

part 'history_controller.g.dart';

@Riverpod(keepAlive: true)
class HistoryController extends _$HistoryController {
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  @override
  Future<List<HistoryItem>> build() async {
    _currentPage = 1;
    _lastPage = 1;
    _isLoadingMore = false;
    
    final repo = ref.read(historyRepositoryInstanceProvider);
    final response = await repo.getHistory(page: 1);
    
    _currentPage = response.pagination.currentPage;
    _lastPage = response.pagination.lastPage;
    
    return response.list;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    _isLoadingMore = true;
    
    try {
      final repo = ref.read(historyRepositoryInstanceProvider);
      final nextPage = _currentPage + 1;
      
      final response = await repo.getHistory(page: nextPage);
      
      _currentPage = response.pagination.currentPage;
      _lastPage = response.pagination.lastPage;

      // Update state dengan menggabungkan list lama + baru
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, ...response.list]);
      
    } catch (e) {
      // Handle error silent or show snackbar via UI listener
    } finally {
      _isLoadingMore = false;
    }
  }
}