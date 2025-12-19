import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkAreaItem {
  final int id;
  final String name;
  final String code;
  final String description;

  ParkAreaItem({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory ParkAreaItem.fromJson(Map<String, dynamic> json) {
    return ParkAreaItem(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'] ?? "Area parkir mahasiswa",
    );
  }
}

class ParkVisualData {
  final int areaId;
  final String areaName;
  final String areaCode; 
  final List<ParkSubareaVisual> subareas;

  ParkVisualData({
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    required this.subareas,
  });

  factory ParkVisualData.fromJson(Map<String, dynamic> json) {
    return ParkVisualData(
      areaId: json['area_id'],
      areaName: json['area_name'],
      areaCode: json['area_code'],
      subareas: (json['subareas'] as List)
          .map((e) => ParkSubareaVisual.fromJson(e))
          .toList(),
    );
  }
}

class ParkSubareaVisual {
  final int id;
  final String name;
  final List<LatLng> polygonPoints;
  final String status;
  final List<String> amenities;
  final int commentCount;

  ParkSubareaVisual({
    required this.id,
    required this.name,
    required this.polygonPoints,
    required this.status,
    required this.amenities,
    this.commentCount = 0,
  });

  factory ParkSubareaVisual.fromJson(Map<String, dynamic> json) {
    // Konversi JSON array polygon ke List<LatLng>
    // Asumsi format backend: [{'lat': -6.12, 'lng': 106.8}, ...]
    List<LatLng> points = [];
    if (json['polygon'] != null) {
      for (var point in json['polygon']) {
        // Handle parsing double aman
        double lat = double.parse(point['lat'].toString());
        double lng = double.parse(point['lng'].toString());
        points.add(LatLng(lat, lng));
      }
    }

    return ParkSubareaVisual(
      id: json['id'],
      name: json['name'],
      polygonPoints: points,
      status: json['status'] ?? 'banyak',
      amenities: List<String>.from(json['amenities'] ?? []),
      commentCount: json['comment_count'] ?? 0,
    );
  }
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