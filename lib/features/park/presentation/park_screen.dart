import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'park_controller.dart';
import '../data/park_model.dart';
import 'comment_screen.dart';

class ParkScreen extends ConsumerStatefulWidget {
  final String areaId;
  final String areaName;

  const ParkScreen({super.key, required this.areaId, required this.areaName});

  @override
  ConsumerState<ParkScreen> createState() => _ParkScreenState();
}

class _ParkScreenState extends ConsumerState<ParkScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? _controller;
  bool _isMyLocationEnabled = false;
  Future<Set<Marker>>? _markersFuture;
  List<ParkSubareaVisual>? _lastSubareas;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (mounted) setState(() => _isMyLocationEnabled = true);
    }
  }

  // State untuk Tipe Map (Normal/Satelit)
  MapType _currentMapType = MapType.normal;

  // Helper: Get Location
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        AppSnackBars.show(
          context,
          "Layanan lokasi tidak aktif.",
          isError: true,
        );
      }
      return null;
    }

    // 2. Cek Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          AppSnackBars.show(context, "Izin lokasi ditolak.", isError: true);
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        AppSnackBars.show(
          context,
          "Izin lokasi ditolak permanen. Cek pengaturan.",
          isError: true,
        );
      }
      return null;
    }

    // 3. Get Position
    // Use LocationSettings instead of deprecated timeLimit
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 5)),
    );
  }

  Future<void> _refreshMapData() async {
    final newData = await ref.refresh(
      parkVisualizationControllerProvider(widget.areaId).future,
    );

    // Update selected subarea jika sedang ada yang dipilih
    final currentSelected = ref.read(selectedSubareaProvider);
    if (currentSelected != null) {
      try {
        final updatedSubarea = newData.subareas.firstWhere(
          (element) => element.id == currentSelected.id,
          orElse: () => currentSelected,
        );
        ref.read(selectedSubareaProvider.notifier).set(updatedSubarea);
      } catch (_) {}
    }
  }

  // Warna Status
  final Color _colorFull = Colors.red.withValues(alpha: 0.6);
  final Color _colorLimited = Colors.amber.withValues(alpha: 0.6);
  final Color _colorAvailable = Colors.green.withValues(alpha: 0.6);
  final Color _colorNeutral = Colors.grey.withValues(alpha: 0.6);
  final Color _strokeColor = Colors.white;

  // Lokasi Default: Politeknik Negeri Batam
  static const CameraPosition _kPolibatam = CameraPosition(
    target: LatLng(1.118507, 104.048384),
    zoom: 17.5,
  );

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'penuh':
        return Colors.red;
      case 'terbatas':
        return Colors.amber;
      case 'banyak':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getStatusValue(String status) {
    switch (status.toLowerCase()) {
      case 'penuh':
        return 1.0;
      case 'terbatas':
        return 0.85;
      case 'banyak':
        return 0.3;
      default:
        return 0.0;
    }
  }

  Future<void> _launchMaps(LatLng destination) async {
    final googleMapsUrl = Uri.parse(
      "google.navigation:q=${destination.latitude},${destination.longitude}&mode=d",
    );
    final fallbackUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}",
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.show(
          context,
          "Tidak dapat membuka aplikasi peta.",
          isError: true,
        );
      }
    }
  }

  // FUNGSI UTAMA: Membuat Text Label Menjadi Marker Icon
  Future<BitmapDescriptor> _createCustomMarkerBitmap(String text) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 1. Konfigurasi Text (Ukuran Font 12, sebelumnya 30)
    const TextSpan textSpan = TextSpan(
      style: TextStyle(
        color: Colors.black,
        fontSize: 13, // Ubah ke 12-14 agar pas
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textSpan.style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // 2. Konfigurasi Background Box (Padding 8, sebelumnya 20)
    final double padding = 5.0;
    final double width = textPainter.width + (padding * 2);
    final double height = textPainter.height + (padding * 2);

    final Paint paint = Paint()..color = Colors.white;
    // Shadow diperhalus
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Radius diperkecil (8, sebelumnya 15)
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(8.0),
    );

    // Gambar Shadow & Box
    canvas.drawRRect(rRect.shift(const Offset(1, 1)), shadowPaint);
    canvas.drawRRect(rRect, paint);

    // Gambar Text di tengah
    textPainter.paint(canvas, Offset(padding, padding));

    // Convert ke Image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt() + 2,
      height.toInt() + 2,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  // Generate Set Marker secara Async
  Future<Set<Marker>> _generateMarkers(List<ParkSubareaVisual> subareas) async {
    Set<Marker> markers = {};
    for (var sub in subareas) {
      final icon = await _createCustomMarkerBitmap(sub.name);
      markers.add(
        Marker(
          markerId: MarkerId("label_${sub.id}"),
          position: sub.center,
          icon: icon,
          anchor: const Offset(0.5, 0.5), // Center anchor
          // Saat label diklik, lakukan hal yang sama seperti polygon diklik
          onTap: () => ref.read(selectedSubareaProvider.notifier).set(sub),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final parkDataAsync = ref.watch(
      parkVisualizationControllerProvider(widget.areaId),
    );
    final selectedSubarea = ref.watch(selectedSubareaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          widget.areaName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _refreshMapData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: parkDataAsync.when(
        data: (data) {
          // Cache Future to prevent infinite rebuild loop
          if (_markersFuture == null || _lastSubareas != data.subareas) {
            _lastSubareas = data.subareas;
            _markersFuture = _generateMarkers(data.subareas);
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // REVERTED: Using FutureBuilder as requested by user
                    FutureBuilder<Set<Marker>>(
                      future: _markersFuture,
                      builder: (context, snapshot) {
                        return GoogleMap(
                          mapType: _currentMapType,
                          initialCameraPosition: _kPolibatam,
                          polygons: _buildPolygons(data.subareas),
                          markers: snapshot.data ?? {},
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationEnabled: _isMyLocationEnabled,
                          myLocationButtonEnabled: false,
                          padding: const EdgeInsets.only(bottom: 20),
                          onMapCreated: (c) {
                            _controller = c;
                            // CRITICAL FIX: Prevent crash on rebuild
                            if (!_mapController.isCompleted) {
                              _mapController.complete(c);
                            }

                            if (data.subareas.isNotEmpty &&
                                data.subareas.first.polygonPoints.isNotEmpty) {
                              c.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  data.subareas.first.polygonPoints.first,
                                  18,
                                ),
                              );
                            }
                          },

                          onTap: (_) => ref
                              .read(selectedSubareaProvider.notifier)
                              .set(null),
                        );
                      },
                    ),

                    // A. Switch Tampilan (Satelit/Biasa)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        heroTag: "mapTypeBtn",
                        backgroundColor: Colors.white,
                        child: Icon(
                          _currentMapType == MapType.normal
                              ? Icons.satellite_alt
                              : Icons.map,
                          color: const Color(0xFF1565C0),
                        ),
                        onPressed: () {
                          setState(() {
                            _currentMapType = _currentMapType == MapType.normal
                                ? MapType.hybrid
                                : MapType.normal;
                          });
                        },
                      ),
                    ),

                    // B. Code Area Label
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          "AREA ${data.areaCode}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    // C. Action Buttons (Recenter & Info)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Button: Center to User Location
                          FloatingActionButton.small(
                            heroTag: "userLocBtn",
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              final controller = _controller;
                              if (controller == null) return;

                              final position = await _determinePosition();
                              if (position != null) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(
                                      position.latitude,
                                      position.longitude,
                                    ),
                                    17.5,
                                  ),
                                );
                              }
                            },
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Button: Center to Area
                          FloatingActionButton.small(
                            heroTag: "centerAreaBtn",
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              final controller = _controller;
                              if (controller == null) return;

                              if (data.subareas.isNotEmpty &&
                                  data
                                      .subareas
                                      .first
                                      .polygonPoints
                                      .isNotEmpty) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    data.subareas.first.polygonPoints.first,
                                    18,
                                  ),
                                );
                              } else {
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(_kPolibatam),
                                );
                              }
                            },
                            child: const Icon(
                              Icons.center_focus_strong,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Info Button (Existing)
                          FloatingActionButton.small(
                            heroTag: "infoBtn",
                            backgroundColor: Colors.white,
                            onPressed: () => _showLegendDialog(context),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Detail Section (Card di bawah) dengan SafeArea
              _buildDetailSection(selectedSubarea, data.cooldown),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Set<Polygon> _buildPolygons(List<ParkSubareaVisual> subareas) {
    return subareas.map((sub) {
      Color fillColor;
      switch (sub.status.toLowerCase()) {
        case 'penuh':
          fillColor = _colorFull;
          break;
        case 'terbatas':
          fillColor = _colorLimited;
          break;
        case 'banyak':
          fillColor = _colorAvailable;
          break;
        default:
          fillColor = _colorNeutral;
      }

      return Polygon(
        polygonId: PolygonId(sub.id.toString()),
        points: sub.polygonPoints,
        fillColor: fillColor,
        strokeColor: _strokeColor,
        strokeWidth: 2,
        consumeTapEvents: true,
        onTap: () => ref.read(selectedSubareaProvider.notifier).set(sub),
      );
    }).toSet();
  }

  Widget _buildDetailSection(
    ParkSubareaVisual? subarea,
    ValidationCooldown? cooldown,
  ) {
    if (subarea == null) {
      // ✅ Gunakan Container dengan tinggi minimal agar tidak fullscreen
      return Container(
        width: double.infinity,
        color: Colors.white, // Background putih agar nav bar menyatu
        child: SafeArea(
          // ✅ SafeArea di dalam bottomNavigationBar
          top: false,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // ✅ Penting: Hanya ambil tinggi konten
              children: [
                Icon(Icons.touch_app, size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                const Text(
                  "Pilih area pada peta untuk melihat detail",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final statusColor = _getStatusColor(subarea.status);
    final statusValue = _getStatusValue(subarea.status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        // ✅ Tambahkan SafeArea agar tidak tertutup nav bar
        top: false,
        child: Column(
          // ✅ Column mengambil height min secara default di dalam bottomNavBar (biasanya)
          mainAxisSize: MainAxisSize.min, // ✅ Paksa Minimum Height
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subarea.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A253A),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _launchMaps(subarea.center),
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text("Rute"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: const Color(0xFF1565C0),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ketersediaan:",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            subarea.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: statusValue,
                          backgroundColor: Colors.grey.shade200,
                          color: statusColor,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Fasilitas:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            subarea.amenities.isEmpty
                                ? const Text(
                                    "-",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : SizedBox(
                                    height: 32,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: subarea.amenities.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 6),
                                      itemBuilder: (ctx, i) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            subarea.amenities[i],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentScreen(
                                subareaId: subarea.id,
                                subareaName: subarea.name,
                              ),
                            ),
                          ).then((_) {
                            _refreshMapData();
                          });
                        },
                        child: Column(
                          children: [
                            Badge(
                              label: Text(subarea.commentCount.toString()),
                              backgroundColor: const Color(0xFF1565C0),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Color(0xFF1565C0),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Komentar",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    final canValidate = cooldown?.canValidate ?? true;
                    final waitTime = cooldown?.waitMinutes ?? 0;
                    return ElevatedButton.icon(
                      onPressed: canValidate
                          ? () => _showValidationSheet(
                              context,
                              subarea.id,
                              subarea.name,
                            )
                          : null,
                      icon: const Icon(
                        Icons.add_location_alt_outlined,
                        size: 18,
                      ),
                      label: Text(
                        canValidate
                            ? "Validasi Kondisi Area Ini"
                            : "Tunggu $waitTime menit lagi",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canValidate
                            ? const Color(0xFF1565C0)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationSheet(
    BuildContext context,
    int subareaId,
    String subareaName,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ValidationSheet(
        subareaId: subareaId,
        subareaName: subareaName,
        parentContext: context,
        areaId: widget.areaId,
      ),
    );
  }

  // ✅ UPDATE: Legend Dialog Sesuai Gambar Referensi
  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Keterangan Status SubArea",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItemDetail(
              color: Colors.red,
              title: "Merah (Penuh)",
              desc:
                  "SubArea parkir hampir/sudah penuh. Disarankan mencari area lain.",
            ),
            const Divider(height: 24),
            _legendItemDetail(
              color: Colors.amber,
              title: "Kuning (Terbatas)",
              desc:
                  "SubArea mulai terbatas. Prioritaskan jika dekat dengan tujuan.",
            ),
            const Divider(height: 24),
            _legendItemDetail(
              color: Colors.green,
              title: "Hijau (Banyak Tersedia)",
              desc: "SubArea parkir masih banyak tersedia. Aman untuk parkir.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Legend per item sesuai gambar
  Widget _legendItemDetail({
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: CircleAvatar(backgroundColor: color, radius: 6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// _ValidationSheet tidak ada perubahan dari sebelumnya, tetap disertakan agar file lengkap
class _ValidationSheet extends ConsumerStatefulWidget {
  final int subareaId;
  final String subareaName;
  final BuildContext parentContext;
  final String areaId;

  const _ValidationSheet({
    required this.subareaId,
    required this.subareaName,
    required this.parentContext,
    required this.areaId,
  });

  @override
  ConsumerState<_ValidationSheet> createState() => _ValidationSheetState();
}

class _ValidationSheetState extends ConsumerState<_ValidationSheet> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(validationActionControllerProvider);
    final isLoading = actionState.isLoading;

    return SafeArea(
      top: false, // Hanya butuh padding bawah untuk nav bar
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Validasi: ${widget.subareaName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text("Bagaimana kondisi parkiran saat ini?"),
            const SizedBox(height: 16),

            _optionTile("penuh", "Merah (Penuh)", Colors.red),
            _optionTile("terbatas", "Kuning (Terbatas)", Colors.amber),
            _optionTile("banyak", "Hijau (Banyak Tersedia)", Colors.green),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isLoading || _selectedStatus == null)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Kirim"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(String value, String label, Color color) {
    final isSelected = _selectedStatus == value;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, color: color, size: 16),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Try get location (fails silently if no permission/service)
    double? lat;
    double? lng;
    try {
      // Cek permission sekilas
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            timeLimit: Duration(seconds: 5),
          ),
        );
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (_) {}

    final (success, message) = await ref
        .read(validationActionControllerProvider.notifier)
        .submitValidation(
          widget.subareaId,
          _selectedStatus!,
          lat: lat,
          lng: lng,
        );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        AppSnackBars.show(context, message);
        ref.invalidate(parkVisualizationControllerProvider(widget.areaId));
      } else {
        AppSnackBars.show(context, message, isError: true);
      }
    }
  }
}
