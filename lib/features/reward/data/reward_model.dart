import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'reward_model.g.dart';

@JsonSerializable()
class RewardScreenData {
  @JsonKey(name: 'current_points')
  final int currentPoints;
  
  final List<RewardItem> rewards;

  RewardScreenData({
    required this.currentPoints, 
    required this.rewards
  });

  factory RewardScreenData.fromJson(Map<String, dynamic> json) => _$RewardScreenDataFromJson(json);
  Map<String, dynamic> toJson() => _$RewardScreenDataToJson(this);
}

@JsonSerializable()
class RewardItem {
  @JsonKey(name: 'reward_id')
  final int id;
  
  final String name;
  final String type; 
  
  @JsonKey(name: 'points_required')
  final int pointsRequired;
  
  final String? image;

  RewardItem({
    required this.id,
    required this.name,
    required this.type,
    required this.pointsRequired,
    this.image,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) => _$RewardItemFromJson(json);
  Map<String, dynamic> toJson() => _$RewardItemToJson(this);

  // --- Helper Custom ---
  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'http://192.168.137.1';
    return '$baseUrl/storage/$image';
  }
}

@JsonSerializable()
class UserRewardHistoryItem {
  final int id;
  final String name;
  final String type;
  final String code;
  final String status;
  
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  UserRewardHistoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRewardHistoryItem.fromJson(Map<String, dynamic> json) => _$UserRewardHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$UserRewardHistoryItemToJson(this);
}