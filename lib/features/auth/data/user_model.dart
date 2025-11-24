import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/api_constants.dart'; // ✅ Import Constants

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
    // 1. Jika tidak ada avatar, return string kosong (nanti UI handle pakai default icon)
    if (avatar == null || avatar!.isEmpty) return ''; 
    
    // 2. Jika avatar sudah berupa URL lengkap (misal dari Google Login), kembalikan langsung
    if (avatar!.startsWith('http')) return avatar!;
    
    // 3. Jika avatar cuma nama file (misal "avatars/foto.jpg"), gabungkan dengan Base Storage URL
    // ApiConstants.storageUrl sudah berisi "http://.../storage/"
    return '${ApiConstants.storageUrl}$avatar'; 
  }
}