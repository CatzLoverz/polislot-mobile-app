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

@Riverpod(keepAlive: true)
class MissionTabState extends _$MissionTabState {
  @override
  bool build() {
    return true; // Default: true (Tab Misi)
  }

  void setMission() => state = true;
  void setLeaderboard() => state = false;
}