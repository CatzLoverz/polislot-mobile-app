import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mission_repository.dart';
import '../data/mission_model.dart';

part 'mission_controller.g.dart';

@Riverpod(keepAlive: true)
class MissionController extends _$MissionController {
  @override
  Future<MissionScreenData> build() async {
    final repo = ref.read(missionRepositoryInstanceProvider);
    return await repo.getMissionData();
  }
}