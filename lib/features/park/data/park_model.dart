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

  ParkSubareaVisual({
    required this.id,
    required this.name,
    required this.polygonPoints,
    required this.status,
    required this.amenities,
    required this.commentCount,
  });

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
