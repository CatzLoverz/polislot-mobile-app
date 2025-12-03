import 'package:json_annotation/json_annotation.dart';

part 'info_board_model.g.dart';

@JsonSerializable()
class InfoBoard {
  @JsonKey(name: 'info_id')
  final int id;

  @JsonKey(name: 'info_title')
  final String title;

  @JsonKey(name: 'info_content')
  final String content;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  InfoBoard({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });

  factory InfoBoard.fromJson(Map<String, dynamic> json) => _$InfoBoardFromJson(json);
  Map<String, dynamic> toJson() => _$InfoBoardToJson(this);
}