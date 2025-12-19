import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final CommentUser user;
  final String content;
  final String? image;
  final String date;
  final String time;

  Comment({
    required this.id,
    required this.user,
    required this.content,
    this.image,
    required this.date,
    required this.time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  // Helper Custom
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image!;

    // Get Base URL logic (duplicated from MissionModel helper logic)
    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.137.1';
    // Remove /api if present for storage URL
    baseUrl = baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    String cleanPath = image!;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '$baseUrl/storage/$cleanPath';
  }
}

@JsonSerializable()
class CommentUser {
  final int id; // Added ID
  final String name;
  final String? avatar;

  CommentUser({required this.id, required this.name, this.avatar});

  factory CommentUser.fromJson(Map<String, dynamic> json) =>
      _$CommentUserFromJson(json);
  Map<String, dynamic> toJson() => _$CommentUserToJson(this);

  // Helper Custom
  String? get fullAvatarUrl {
    if (avatar == null || avatar!.isEmpty) return null;
    if (avatar!.startsWith('http')) return avatar!;

    String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.137.1';
    baseUrl = baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    String cleanPath = avatar!;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '$baseUrl/storage/$cleanPath';
  }
}
