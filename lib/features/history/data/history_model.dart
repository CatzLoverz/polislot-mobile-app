import 'package:json_annotation/json_annotation.dart';

part 'history_model.g.dart';

@JsonSerializable()
class HistoryResponse {
  final List<HistoryItem> list;
  final PaginationMeta pagination;

  HistoryResponse({required this.list, required this.pagination});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) => _$HistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryResponseToJson(this);
}

@JsonSerializable()
class HistoryItem {
  final int id;
  final String type; // mission, validation, redeem
  final String title;
  final int? points;
  
  @JsonKey(name: 'is_negative')
  final bool isNegative;
  
  final String date;
  final String time;
  final String timestamp;

  HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    this.points,
    required this.isNegative,
    required this.date,
    required this.time,
    required this.timestamp,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) => _$HistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryItemToJson(this);
}

@JsonSerializable()
class PaginationMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  
  @JsonKey(name: 'last_page')
  final int lastPage;
  
  @JsonKey(name: 'per_page')
  final int perPage;
  
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => _$PaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}