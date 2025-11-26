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
    // 1. Jika avatar kosong, return string kosong (UI akan pakai icon default)
    if (avatar == null || avatar!.isEmpty) return ''; 
    
    // 2. Jika sudah URL lengkap (misal dari Google), return langsung
    if (avatar!.startsWith('http')) return avatar!;
    
    // 3. Ambil Base URL dari .env
    // Default ke localhost jika .env gagal load (tapi ini pasti gagal di HP)
    String baseUrl = dotenv.env['API_STORAGE_URL'] ?? '';

    // 🛡️ FIX SLASH: Pastikan tidak ada double slash atau missing slash
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1); // Hapus slash akhir
    }
    
    String cleanAvatar = avatar!;
    if (cleanAvatar.startsWith('/')) {
      cleanAvatar = cleanAvatar.substring(1); // Hapus slash awal
    }

    // Gabungkan: http://192.168.1.x:8000/storage + / + avatars/file.jpg
    final finalUrl = '$baseUrl/$cleanAvatar';
    
    // 🔍 Debugging: Cek di console URL apa yang terbentuk
    // print("🖼️ Generated Image URL: $finalUrl"); 
    
    return finalUrl; 
  }
}