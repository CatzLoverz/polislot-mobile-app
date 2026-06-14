import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/park_repository.dart';
import '../data/park_model.dart';
import '../../../../core/services/mqtt_service.dart';

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
    final data = await repo.getParkVisualization(areaId);

    // Listen to MQTT Realtime Updates
    final subscription = ref.read(mqttServiceProvider.notifier).messages.listen((payload) {
      final topic = payload['_topic'] as String?;
      if (topic != null && topic.endsWith('/$areaId') && state.hasValue) {
        final subareaId = payload['parkSubareaId'] as int?;
        final newStatus = payload['status'] as String?;
        
        if (subareaId != null && newStatus != null) {
          final currentData = state.value!;
          
          final newSubareas = currentData.subareas.map((sub) {
            if (sub.id == subareaId) {
              return ParkSubareaVisual(
                id: sub.id,
                name: sub.name,
                polygonPoints: sub.polygonPoints,
                status: newStatus,
                amenities: sub.amenities,
                commentCount: sub.commentCount,
              );
            }
            return sub;
          }).toList();

          state = AsyncData(ParkVisualData(
            areaId: currentData.areaId,
            areaName: currentData.areaName,
            areaCode: currentData.areaCode,
            cooldown: currentData.cooldown,
            subareas: newSubareas,
          ));

          // Jika subarea yang diperbarui sedang dipilih, perbarui juga state selectedSubarea
          final selected = ref.read(selectedSubareaProvider);
          if (selected != null && selected.id == subareaId) {
            final updatedSelected = newSubareas.firstWhere((s) => s.id == subareaId);
            ref.read(selectedSubareaProvider.notifier).set(updatedSelected);
          }
        }
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return data;
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
