import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/reward_repository.dart';
import '../data/reward_model.dart';
import '../../history/presentation/history_controller.dart';

part 'reward_controller.g.dart';

// Controller untuk List Reward & Poin (Halaman Utama Reward)
@Riverpod(keepAlive: true)
class RewardController extends _$RewardController {
  @override
  Future<RewardScreenData> build() async {
    final repo = ref.read(rewardRepositoryInstanceProvider);
    return await repo.getRewards();
  }

  Future<String?> redeem(int rewardId) async {
    final repo = ref.read(rewardRepositoryInstanceProvider);
    try {
      final code = await repo.redeemReward(rewardId);
      // Refresh data poin setelah sukses redeem
      ref.invalidateSelf();
      // Silent refresh history agar transaksi baru muncul
      ref.invalidate(historyControllerProvider);
      return code;
    } catch (e) {
      rethrow;
    }
  }
}

// Controller terpisah untuk Riwayat (Halaman Profil)
@Riverpod(keepAlive: true)
class RewardHistoryController extends _$RewardHistoryController {
  @override
  Future<List<UserRewardHistoryItem>> build() async {
    final repo = ref.read(rewardRepositoryInstanceProvider);
    return await repo.getHistory();
  }
}

@Riverpod(keepAlive: true)
class RewardTabState extends _$RewardTabState {
  @override
  bool build() {
    return true; // Default: true (Toko Hadiah)
  }

  void setRewardTab() => state = true;
  void setHistoryTab() => state = false;
}
