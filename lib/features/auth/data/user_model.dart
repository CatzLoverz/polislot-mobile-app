import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id') 
  final int id;

  final String name;
  final String email;
  final String? role; 
  final String? avatar;

  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.avatar,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // --- ✅ HELPER METHODS: AUTO JOIN URL ---
  
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