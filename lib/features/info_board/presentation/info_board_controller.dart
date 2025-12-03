import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/info_board_model.dart';
import '../data/info_board_repository.dart';

part 'info_board_controller.g.dart';

@Riverpod(keepAlive: true)
class InfoBoardController extends _$InfoBoardController {

  @override
  Future<List<InfoBoard>> build() async {
    final repo = ref.read(infoBoardRepositoryInstanceProvider);
    return await repo.getInfoBoards();
  }
}