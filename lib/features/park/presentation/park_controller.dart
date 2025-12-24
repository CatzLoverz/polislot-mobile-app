import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/park_repository.dart';
import '../data/park_model.dart';

part 'park_controller.g.dart';

// Controller List Area
@Riverpod(keepAlive: true)
class ParkAreaListController extends _$ParkAreaListController {
  @override
  Future<List<ParkAreaItem>> build() async {
    final repo = ref.read(parkRepositoryInstanceProvider);
    return await repo.getParkAreas();
  }

  Future<void> refreshData() async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(parkRepositoryInstanceProvider);
      return await repo.getParkAreas();
    });
  }
}

// Controller Data Peta
@riverpod
class ParkVisualizationController extends _$ParkVisualizationController {
  @override
  Future<ParkVisualData> build(String areaId) async {
    final repo = ref.read(parkRepositoryInstanceProvider);
    return await repo.getParkVisualization(areaId);
  }
}

// Controller Aksi Validasi
@riverpod
class ValidationActionController extends _$ValidationActionController {
  @override
  FutureOr<void> build() {}

  Future<(bool, String)> submitValidation(
    int subareaId,
    String status, {
    double? lat,
    double? lng,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(parkRepositoryInstanceProvider);
      final message = await repo.sendValidation(
        subareaId,
        status,
        lat: lat,
        lng: lng,
      );
      state = const AsyncData(null);
      return (true, message);
    } catch (e, st) {
      state = AsyncError(e, st);
      String errorMsg = "Gagal mengirim validasi.";
      if (e.toString().startsWith("Exception: ")) {
        errorMsg = e.toString().substring(11); // Remove "Exception: " prefix
      }
      return (false, errorMsg);
    }
  }
}

// 3. State Provider untuk Subarea yang dipilih user di Peta
@riverpod
class SelectedSubarea extends _$SelectedSubarea {
  @override
  ParkSubareaVisual? build() {
    return null; // Default state: null (tidak ada yang dipilih)
  }

  // Method untuk mengubah state (pengganti .state =)
  void set(ParkSubareaVisual? value) {
    state = value;
  }
}
