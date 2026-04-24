import 'package:json_annotation/json_annotation.dart';

part 'faq_model.g.dart';

@JsonSerializable()
class FaqModel {
  @JsonKey(name: 'faq_id')
  final int id;

  @JsonKey(name: 'faq_question')
  final String question;

  @JsonKey(name: 'faq_answer')
  final String answer;

  FaqModel({
    required this.id, 
    required this.question, 
    required this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) => _$FaqModelFromJson(json);
  Map<String, dynamic> toJson() => _$FaqModelToJson(this);
}