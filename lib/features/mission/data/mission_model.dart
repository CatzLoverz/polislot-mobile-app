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

  /// Tipe misi dari backend: 'TARGET', 'SEQUENCE', atau 'SEQUENCE_STREAK'
  @JsonKey(name: 'mission_type')
  final String missionType;

  final double percentage;

  @JsonKey(name: 'threshold')
  final int threshold;

  @JsonKey(name: 'current_value')
  final int currentValue;

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
    required this.missionType,
    required this.percentage,
    required this.threshold,
    required this.currentValue,
    required this.isCompleted,
    this.completedAt,
  });

  factory MissionItem.fromJson(Map<String, dynamic> json) => _$MissionItemFromJson(json);
  Map<String, dynamic> toJson() => _$MissionItemToJson(this);

  // --- Helper: apakah tipe ini berbasis hari (sequence)? ---
  bool get isSequenceType =>
      missionType == 'SEQUENCE' || missionType == 'SEQUENCE_STREAK';

  // --- Helper: apakah tipe ini streak (harus berturut-turut)? ---
  bool get isStreakType => missionType == 'SEQUENCE_STREAK';

  // --- Helper: label singkat untuk badge di UI ---
  String get missionTypeLabel {
    switch (missionType) {
      case 'SEQUENCE':
        return 'Sequence';
      case 'SEQUENCE_STREAK':
        return 'Streak';
      default:
        return 'Target';
    }
  }

  // --- Helper: unit progress (hari untuk sequence, kali untuk target) ---
  String get unitLabel => isSequenceType ? 'hari' : 'kali';

  // --- Helper: pesan aksi pre-determined sesuai metric + type ---
  String get actionMessage {
    switch (metricCode.toUpperCase()) {
      case 'VALIDATION_ACTION':
        if (missionType == 'SEQUENCE_STREAK') {
          return 'Lakukan validasi parkir setiap hari berturut-turut';
        }
        if (missionType == 'SEQUENCE') {
          return 'Lakukan validasi parkir tiap hari';
        }
        return 'Lakukan validasi parkir sebanyak mungkin';
      case 'LOGIN_ACTION':
        if (missionType == 'SEQUENCE_STREAK') {
          return 'Buka aplikasi setiap hari berturut-turut';
        }
        return 'buka aplikasi secara rutin';
      case 'PROFILE_UPDATE':
        return 'Perbarui foto profil atau avatar kamu';
      default:
        return 'Selesaikan misi ini untuk mendapatkan koin';
    }
  }
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