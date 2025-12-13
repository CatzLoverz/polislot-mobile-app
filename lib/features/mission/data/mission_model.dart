import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'mission_model.g.dart';

@JsonSerializable()
class MissionScreenData {
  final UserStats stats;
  final List<MissionItem> missions;
  final List<LeaderboardItem> leaderboard;
  
  @JsonKey(name: 'user_rank')
  final LeaderboardItem userRank;

  MissionScreenData({
    required this.stats,
    required this.missions,
    required this.leaderboard,
    required this.userRank,
  });

  factory MissionScreenData.fromJson(Map<String, dynamic> json) => _$MissionScreenDataFromJson(json);
  Map<String, dynamic> toJson() => _$MissionScreenDataToJson(this);
}

@JsonSerializable()
class UserStats {
  @JsonKey(name: 'total_completed')
  final int totalCompleted;
  
  @JsonKey(name: 'lifetime_points')
  final int lifetimePoints;

  UserStats({
    required this.totalCompleted, 
    required this.lifetimePoints
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class MissionItem {
  @JsonKey(name: 'mission_id')
  final int id;
  
  final String title;
  final String description;
  final int points;
  
  @JsonKey(name: 'metric_code')
  final String metricCode;
  
  final double percentage;
  
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  
  @JsonKey(name: 'completed_at')
  final String? completedAt;

  MissionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.metricCode,
    required this.percentage,
    required this.isCompleted,
    this.completedAt,
  });

  factory MissionItem.fromJson(Map<String, dynamic> json) => _$MissionItemFromJson(json);
  Map<String, dynamic> toJson() => _$MissionItemToJson(this);
}

@JsonSerializable()
class LeaderboardItem {
  final int rank;
  final String name;
  final String? avatar;
  final int points;
  
  @JsonKey(name: 'is_current_user')
  final bool isCurrentUser;

  LeaderboardItem({
    required this.rank,
    required this.name,
    this.avatar,
    required this.points,
    this.isCurrentUser = false,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) => _$LeaderboardItemFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardItemToJson(this);

  // --- Helper Custom (Tidak masuk JSON) ---
  String get fullAvatarUrl {
    if (avatar == null || avatar!.isEmpty) return '';
    if (avatar!.startsWith('http')) return avatar!;

    String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    baseUrl = baseUrl.replaceAll('/api', '');
    
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    String cleanAvatar = avatar!;
    if (cleanAvatar.startsWith('/')) {
      cleanAvatar = cleanAvatar.substring(1);
    }

    return '$baseUrl/storage/$cleanAvatar';
  }
}