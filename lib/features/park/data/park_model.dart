import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'park_model.g.dart';

@JsonSerializable()
class ParkAreaItem {
  final int id;
  final String name;
  final String code;
  @JsonKey(defaultValue: "Area parkir mahasiswa")
  final String description;

  ParkAreaItem({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory ParkAreaItem.fromJson(Map<String, dynamic> json) =>
      _$ParkAreaItemFromJson(json);
  Map<String, dynamic> toJson() => _$ParkAreaItemToJson(this);
}

@JsonSerializable()
class ParkVisualData {
  @JsonKey(name: 'area_id')
  final int areaId;

  @JsonKey(name: 'area_name')
  final String areaName;

  @JsonKey(name: 'area_code')
  final String areaCode;

  @JsonKey(name: 'validation_cooldown')
  final ValidationCooldown? cooldown;

  final List<ParkSubareaVisual> subareas;

  ParkVisualData({
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    this.cooldown,
    required this.subareas,
  });

  ParkVisualData copyWith({
    int? areaId,
    String? areaName,
    String? areaCode,
    ValidationCooldown? cooldown,
    List<ParkSubareaVisual>? subareas,
  }) {
    return ParkVisualData(
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      areaCode: areaCode ?? this.areaCode,
      cooldown: cooldown ?? this.cooldown,
      subareas: subareas ?? this.subareas,
    );
  }

  factory ParkVisualData.fromJson(Map<String, dynamic> json) =>
      _$ParkVisualDataFromJson(json);
  Map<String, dynamic> toJson() => _$ParkVisualDataToJson(this);
}

@JsonSerializable()
class ParkSubareaVisual {
  final int id;
  final String name;

  @JsonKey(name: 'polygon', fromJson: _polygonFromJson, toJson: _polygonToJson)
  final List<LatLng> polygonPoints;

  @JsonKey(defaultValue: 'banyak')
  final String status;

  @JsonKey(defaultValue: [])
  final List<String> amenities;

  @JsonKey(name: 'comment_count', defaultValue: 0)
  final int commentCount;

  @JsonKey(name: 'is_validated', defaultValue: false)
  final bool isValidated;

  @JsonKey(name: 'has_user_report', defaultValue: false)
  final bool hasUserReport;

  @JsonKey(name: 'current_count', defaultValue: 0)
  final int currentCount;

  @JsonKey(name: 'max_slots', defaultValue: 0)
  final int maxSlots;

  @JsonKey(name: 'validation_expires_at')
  final String? validationExpiresAt;

  @JsonKey(name: 'last_validation_time')
  final String? lastValidationTime;

  @JsonKey(name: 'validation_remaining_seconds', defaultValue: 0)
  final int validationRemainingSeconds;

  @JsonKey(name: 'fallback_status', defaultValue: 'banyak')
  final String fallbackStatus;

  @JsonKey(name: 'fallback_status_color', defaultValue: '#31ce36')
  final String fallbackStatusColor;

  ParkSubareaVisual({
    required this.id,
    required this.name,
    required this.polygonPoints,
    required this.status,
    required this.amenities,
    required this.commentCount,
    this.isValidated = false,
    this.hasUserReport = false,
    this.currentCount = 0,
    this.maxSlots = 0,
    this.validationExpiresAt,
    this.lastValidationTime,
    this.validationRemainingSeconds = 0,
    this.fallbackStatus = 'banyak',
    this.fallbackStatusColor = '#31ce36',
  });

  ParkSubareaVisual copyWith({
    int? id,
    String? name,
    List<LatLng>? polygonPoints,
    String? status,
    List<String>? amenities,
    int? commentCount,
    bool? isValidated,
    bool? hasUserReport,
    int? currentCount,
    int? maxSlots,
    String? validationExpiresAt,
    String? lastValidationTime,
    int? validationRemainingSeconds,
    String? fallbackStatus,
    String? fallbackStatusColor,
  }) {
    return ParkSubareaVisual(
      id: id ?? this.id,
      name: name ?? this.name,
      polygonPoints: polygonPoints ?? this.polygonPoints,
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      commentCount: commentCount ?? this.commentCount,
      isValidated: isValidated ?? this.isValidated,
      hasUserReport: hasUserReport ?? this.hasUserReport,
      currentCount: currentCount ?? this.currentCount,
      maxSlots: maxSlots ?? this.maxSlots,
      validationExpiresAt: validationExpiresAt ?? this.validationExpiresAt,
      lastValidationTime: lastValidationTime ?? this.lastValidationTime,
      validationRemainingSeconds: validationRemainingSeconds ?? this.validationRemainingSeconds,
      fallbackStatus: fallbackStatus ?? this.fallbackStatus,
      fallbackStatusColor: fallbackStatusColor ?? this.fallbackStatusColor,
    );
  }

  factory ParkSubareaVisual.fromJson(Map<String, dynamic> json) =>
      _$ParkSubareaVisualFromJson(json);
  Map<String, dynamic> toJson() => _$ParkSubareaVisualToJson(this);

  // Helper untuk mencari titik tengah polygon (Centroid)
  LatLng get center {
    if (polygonPoints.isEmpty) return const LatLng(0, 0);
    double latSum = 0;
    double lngSum = 0;
    for (var p in polygonPoints) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / polygonPoints.length, lngSum / polygonPoints.length);
  }
}

// Custom Conversion Functions
List<LatLng> _polygonFromJson(dynamic json) {
  List<LatLng> points = [];
  if (json is List) {
    for (var point in json) {
      if (point is Map) {
        // Handle potential string/number mismatch safely
        double lat = double.tryParse(point['lat'].toString()) ?? 0.0;
        double lng = double.tryParse(point['lng'].toString()) ?? 0.0;
        points.add(LatLng(lat, lng));
      }
    }
  }
  return points;
}

dynamic _polygonToJson(List<LatLng> points) {
  return points.map((e) => {'lat': e.latitude, 'lng': e.longitude}).toList();
}

@JsonSerializable()
class ValidationCooldown {
  @JsonKey(name: 'can_validate')
  final bool canValidate;

  @JsonKey(name: 'wait_minutes')
  final int waitMinutes;

  ValidationCooldown({required this.canValidate, required this.waitMinutes});

  factory ValidationCooldown.fromJson(Map<String, dynamic> json) =>
      _$ValidationCooldownFromJson(json);
  Map<String, dynamic> toJson() => _$ValidationCooldownToJson(this);
}
