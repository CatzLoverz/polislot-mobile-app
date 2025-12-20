import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import 'reward_model.dart';

part 'reward_repository.g.dart';

@Riverpod(keepAlive: true)
class RewardRepositoryInstance extends _$RewardRepositoryInstance {
  @override
  RewardRepository build() {
    return RewardRepository(ref.watch(dioClientServiceProvider));
  }
}

class RewardRepository {
  final Dio _dio;
  RewardRepository(this._dio);

  Future<RewardScreenData> getRewards() async {
    try {
      final response = await _dio.get('/rewards');
      final data = response.data;
      if ((response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300 &&
          data['status'] == 'success') {
        return RewardScreenData.fromJson(data['data']);
      }
      throw Exception("Gagal memuat data reward.");
    } catch (e) {
      rethrow;
    }
  }

  Future<String> redeemReward(int rewardId) async {
    try {
      final response = await _dio.post(
        '/rewards/redeem',
        data: {'reward_id': rewardId},
      );
      final data = response.data;
      if ((response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300 &&
          data['status'] == 'success') {
        return data['data']['voucher_code'];
      }
      throw Exception(data['message'] ?? "Gagal menukar reward.");
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? "Terjadi kesalahan.");
      }
      rethrow;
    }
  }

  Future<List<UserRewardHistoryItem>> getHistory() async {
    try {
      final response = await _dio.get('/rewards/history');
      final data = response.data;
      if ((response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300 &&
          data['status'] == 'success') {
        return (data['data'] as List)
            .map((e) => UserRewardHistoryItem.fromJson(e))
            .toList();
      }
      throw Exception("Gagal memuat riwayat.");
    } catch (e) {
      rethrow;
    }
  }
}
