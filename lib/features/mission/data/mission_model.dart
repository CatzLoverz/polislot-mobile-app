class MissionScreenData {
  final UserStats stats;
  final List<MissionItem> missions;
  final List<LeaderboardItem> leaderboard;
  final LeaderboardItem userRank;

  MissionScreenData({
    required this.stats,
    required this.missions,
    required this.leaderboard,
    required this.userRank,
  });

  factory MissionScreenData.fromJson(Map<String, dynamic> json) {
    return MissionScreenData(
      stats: UserStats.fromJson(json['stats']),
      missions: (json['missions'] as List).map((e) => MissionItem.fromJson(e)).toList(),
      leaderboard: (json['leaderboard'] as List).map((e) => LeaderboardItem.fromJson(e)).toList(),
      userRank: LeaderboardItem.fromJson(json['user_rank']),
    );
  }
}

class UserStats {
  final int totalCompleted;
  final int lifetimePoints;

  UserStats({required this.totalCompleted, required this.lifetimePoints});

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalCompleted: json['total_completed'] ?? 0,
      lifetimePoints: json['lifetime_points'] ?? 0,
    );
  }
}

class MissionItem {
  final int id;
  final String title;
  final String description;
  final int points;
  final String metricCode;
  final double percentage;
  final bool isCompleted;
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

  factory MissionItem.fromJson(Map<String, dynamic> json) {
    return MissionItem(
      id: json['mission_id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      metricCode: json['metric_code'],
      percentage: (json['percentage'] as num).toDouble(),
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      completedAt: json['completed_at'],
    );
  }
}

class LeaderboardItem {
  final int rank;
  final String name;
  final String? avatar;
  final int points;
  final bool isCurrentUser;

  LeaderboardItem({
    required this.rank,
    required this.name,
    this.avatar,
    required this.points,
    this.isCurrentUser = false,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      rank: json['rank'],
      name: json['name'],
      avatar: json['avatar'],
      points: json['points'],
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }
}