import 'package:json_annotation/json_annotation.dart';

part 'feedback_category_model.g.dart';

@JsonSerializable()
class FeedbackCategory {
  @JsonKey(name: 'fbk_category_id')
  final int id;

  @JsonKey(name: 'fbk_category_name')
  final String name;

  FeedbackCategory({required this.id, required this.name});

  factory FeedbackCategory.fromJson(Map<String, dynamic> json) => _$FeedbackCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackCategoryToJson(this);
}