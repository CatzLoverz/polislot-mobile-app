import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/mqtt_service.dart';
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
  List<ParkSubareaVisual>? _lastSubareasForMarkers;
  Set<Polygon>? _cachedPolygons;
  List<ParkSubareaVisual>? _lastSubareasForPolygons;
  bool _isManualRefresh = false; // Internal flag tracking manual refresh

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

  void _onSubareaTap(ParkSubareaVisual sub) {
    // 1. Set State
    ref.read(selectedSubareaProvider.notifier).set(sub);

    // 2. Trigger Silent Refresh
    ref.invalidate(parkVisualizationControllerProvider(widget.areaId));

    // 3. Animate Camera to Subarea Center
    if (_controller != null) {
      // Selalu gunakan sub.center agar fokus tepat di tengah area/icon
      _controller!.animateCamera(CameraUpdate.newLatLngZoom(sub.center, 19.0));
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
          // Saat label diklik, lakukan hal yang sama seperti polygon diklik
          onTap: () => _onSubareaTap(sub),
        ),
      );
    }
    return markers;
  }

  bool _shouldRebuildMarkers(
    List<ParkSubareaVisual> list1,
    List<ParkSubareaVisual> list2,
  ) {
    if (list1.length != list2.length) return true;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].name != list2[i].name ||
          !_areLatLngsEqual(list1[i].polygonPoints, list2[i].polygonPoints)) {
        return true;
      }
    }
    return false;
  }

  bool _shouldRebuildPolygons(
    List<ParkSubareaVisual> list1,
    List<ParkSubareaVisual> list2,
  ) {
    if (list1.length != list2.length) return true;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].status != list2[i].status ||
          !_areLatLngsEqual(list1[i].polygonPoints, list2[i].polygonPoints)) {
        return true;
      }
    }
    return false;
  }

  bool _areLatLngsEqual(List<LatLng> points1, List<LatLng> points2) {
    if (points1.length != points2.length) return false;
    for (int i = 0; i < points1.length; i++) {
      if (points1[i].latitude != points2[i].latitude ||
          points1[i].longitude != points2[i].longitude) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider
    final parkDataAsync = ref.watch(
      parkVisualizationControllerProvider(widget.areaId),
    );

    // Listener: Sync Selected Subarea with Fresh Data
    ref.listen<
      AsyncValue<ParkVisualData>
    >(parkVisualizationControllerProvider(widget.areaId), (_, next) {
      next.whenData((newData) {
        final current = ref.read(selectedSubareaProvider);
        if (current != null) {
          try {
            // Cari versi terbaru dari subarea yang sedang dipilih
            final updated = newData.subareas.firstWhere(
              (s) => s.id == current.id,
            );
            // Update state agar UI detail card berubah
            ref.read(selectedSubareaProvider.notifier).set(updated);
          } catch (_) {
            // Jika subarea hilang dari data baru (jarang terjadi), biarkan atau deselect via catch
          }
        }
      });
    });

    // Listener: Reset _isManualRefresh when loading finishes
    ref.listen<AsyncValue<ParkVisualData>>(
      parkVisualizationControllerProvider(widget.areaId),
      (_, next) {
        if (!next.isLoading && _isManualRefresh) {
          _isManualRefresh = false;
        }
      },
    );

    // Logic: Initial Loading (No Data yet)
    if (parkDataAsync.isLoading && !parkDataAsync.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Logic: Error (No Data)
    if (parkDataAsync.hasError && !parkDataAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: const Text("Gagal Memuat")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              DioErrorHandler.parse(parkDataAsync.error!),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Logic: Has Data (Maybe Loading/Refreshing silently)
    // If we have data, we render the screen.
    final data = parkDataAsync.value!;
    final isRefreshing = parkDataAsync.isLoading && _isManualRefresh;

    // Regenerate markers only if the subarea data has changed (e.g. name, count, or list changed)
    if (_lastSubareasForMarkers == null ||
        _shouldRebuildMarkers(_lastSubareasForMarkers!, data.subareas)) {
      _lastSubareasForMarkers = data.subareas;
      _markersFuture = _generateMarkers(data.subareas);
    }

    // Regenerate polygons only if status or list changed
    if (_lastSubareasForPolygons == null ||
        _cachedPolygons == null ||
        _shouldRebuildPolygons(_lastSubareasForPolygons!, data.subareas)) {
      _lastSubareasForPolygons = data.subareas;
      _cachedPolygons = _buildPolygons(data.subareas);
    }

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
          // Indikator status koneksi MQTT Realtime
          _MqttStatusIndicator(),
          IconButton(
            onPressed: () {
              // Manual Refresh triggers the spinner
              setState(() => _isManualRefresh = true);
              ref.invalidate(
                parkVisualizationControllerProvider(widget.areaId),
              );
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 1. Google Map
                FutureBuilder<Set<Marker>>(
                  future: _markersFuture,
                  builder: (context, snapshot) {
                    return GoogleMap(
                      mapType: _currentMapType,
                      initialCameraPosition: _kPolibatam,
                      polygons: _cachedPolygons ?? {},
                      markers: snapshot.data ?? {},
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationEnabled: _isMyLocationEnabled,
                      myLocationButtonEnabled: false,
                      padding: const EdgeInsets.only(bottom: 20),
                      onMapCreated: (c) {
                        _controller = c;
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
                      onTap: (_) =>
                          ref.read(selectedSubareaProvider.notifier).set(null),
                    );
                  },
                ),

                // 2. Map Type Button
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

                // 3. Loading Overlay (Spinner Only) - "Swipe Down" Style
                if (isRefreshing)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Memuat data...",
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 4. Area Label
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

                // 5. Action Buttons
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
                                LatLng(position.latitude, position.longitude),
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
                              data.subareas.first.polygonPoints.isNotEmpty) {
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

                      // Info Button
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

          // Detail Section
          _SubareaDetailPanel(
            areaId: widget.areaId,
            cooldown: data.cooldown,
            parentContext: context,
            launchMaps: _launchMaps,
            showValidationSheet: _showValidationSheet,
          ),
        ],
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
        onTap: () => _onSubareaTap(sub),
      );
    }).toSet();
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
        content: SingleChildScrollView(
          child: Column(
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
              const Divider(height: 24),
              _legendItemDetail(
                color: Colors.grey,
                title: "Abu-abu (Netral)",
                desc: "Perangkat IoT sedang offline atau SubArea belum dipasangi perangkat IoT.",
              ),
              const Divider(height: 24),
              _legendItemLabel(
                label: "Tervalidasi",
                color: Colors.green,
                title: "Tanda Tervalidasi",
                desc: "Status ketersediaan SubArea yang terdeteksi otomatis telah divalidasi oleh pengguna lain.",
              ),
              const Divider(height: 24),
              _legendItemLabel(
                label: "Laporan Berbeda",
                color: Colors.orange,
                title: "Tanda Laporan Berbeda",
                desc: "Terdapat laporan yang berbeda dari status SubArea yang terdeteksi otomatis.",
              ),
            ],
          ),
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
        Container(
          width: 65,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            width: 28,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
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
                textAlign: TextAlign.justify,
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

  // Widget untuk Legend label (seperti Tervalidasi/Laporan Berbeda)
  Widget _legendItemLabel({
    required String label,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 65,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 2.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
                textAlign: TextAlign.justify,
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

/// Widget indikator status koneksi MQTT Realtime di AppBar.
/// Menampilkan titik animasi: hijau (terhubung), kuning (menghubungkan), abu-abu (terputus).
class _MqttStatusIndicator extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MqttStatusIndicator> createState() =>
      _MqttStatusIndicatorState();
}

class _MqttStatusIndicatorState extends ConsumerState<_MqttStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(mqttServiceProvider) mengembalikan MqttConnectionStatus secara reaktif
    // karena state provider sekarang adalah MqttConnectionStatus (bukan void)
    final mqttStatus = ref.watch(mqttServiceProvider);

    Color dotColor;
    String tooltip;
    bool animate;

    switch (mqttStatus) {
      case MqttConnectionStatus.connected:
        dotColor = const Color(0xFF4CAF50); // Hijau
        tooltip = 'Realtime: Terhubung';
        animate = true;
        break;
      case MqttConnectionStatus.connecting:
        dotColor = const Color(0xFFFFC107); // Kuning
        tooltip = 'Realtime: Menghubungkan...';
        animate = true;
        break;
      case MqttConnectionStatus.error:
        dotColor = const Color(0xFFFF5252); // Merah
        tooltip = 'Realtime: Error koneksi';
        animate = false;
        break;
      default:
        dotColor = Colors.grey.shade400;
        tooltip = 'Realtime: Terputus';
        animate = false;
    }

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
        child: animate
            ? AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Opacity(
                  opacity: _pulseAnimation.value,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
      ),
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
        // Silent Refresh (memicu loading state di parent tanpa blank screen)
        ref.invalidate(parkVisualizationControllerProvider(widget.areaId));
      } else {
        AppSnackBars.show(context, message, isError: true);
      }
    }
  }
}

class _ValidationCountdownButton extends StatefulWidget {
  final ValidationCooldown? cooldown;
  final VoidCallback onPressed;

  const _ValidationCountdownButton({
    required this.cooldown,
    required this.onPressed,
  });

  @override
  State<_ValidationCountdownButton> createState() =>
      _ValidationCountdownButtonState();
}

class _ValidationCountdownButtonState
    extends State<_ValidationCountdownButton> {
  Timer? _timer;
  late DateTime _endTime;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void didUpdateWidget(covariant _ValidationCountdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cooldown != oldWidget.cooldown) {
      _timer?.cancel();
      _initTimer();
    }
  }

  void _initTimer() {
    _remainingSeconds = widget.cooldown?.remainingSeconds ?? 0;
    final canValidate = widget.cooldown?.canValidate ?? true;

    if (!canValidate && _remainingSeconds > 0) {
      _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        if (now.isAfter(_endTime)) {
          setState(() {
            _remainingSeconds = 0;
          });
          _timer?.cancel();
        } else {
          setState(() {
            _remainingSeconds = _endTime.difference(now).inSeconds;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canValidate =
        (widget.cooldown?.canValidate ?? true) || _remainingSeconds <= 0;

    String buttonLabel = "Validasi Kondisi Area Ini";
    if (!canValidate) {
      final m = _remainingSeconds ~/ 60;
      final s = _remainingSeconds % 60;
      buttonLabel = "Tunggu ${m}m ${s}s lagi";
    }

    return ElevatedButton.icon(
      onPressed: canValidate ? widget.onPressed : null,
      icon: const Icon(Icons.add_location_alt_outlined, size: 18),
      label: Text(buttonLabel),
      style: ElevatedButton.styleFrom(
        backgroundColor: canValidate ? const Color(0xFF1565C0) : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SubareaCountdownText extends StatefulWidget {
  final int validationRemainingSeconds;

  const _SubareaCountdownText({required this.validationRemainingSeconds});

  @override
  State<_SubareaCountdownText> createState() => _SubareaCountdownTextState();
}

class _SubareaCountdownTextState extends State<_SubareaCountdownText> {
  Timer? _timer;
  late DateTime _endTime;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void didUpdateWidget(covariant _SubareaCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.validationRemainingSeconds !=
        oldWidget.validationRemainingSeconds) {
      _timer?.cancel();
      _initTimer();
    }
  }

  void _initTimer() {
    _remainingSeconds = widget.validationRemainingSeconds;
    if (_remainingSeconds > 0) {
      _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        if (now.isAfter(_endTime)) {
          setState(() {
            _remainingSeconds = 0;
          });
          _timer?.cancel();
        } else {
          setState(() {
            _remainingSeconds = _endTime.difference(now).inSeconds;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds <= 0) return const SizedBox.shrink();

    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return Text(
      "(Sisa: ${m}m ${s}s)",
      style: const TextStyle(
        fontSize: 10,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SubareaDetailPanel extends ConsumerWidget {
  final ValidationCooldown? cooldown;
  final String areaId;
  final BuildContext parentContext;
  final Future<void> Function(LatLng destination) launchMaps;
  final void Function(BuildContext context, int subareaId, String subareaName)
  showValidationSheet;

  const _SubareaDetailPanel({
    required this.cooldown,
    required this.areaId,
    required this.parentContext,
    required this.launchMaps,
    required this.showValidationSheet,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subarea = ref.watch(selectedSubareaProvider);
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
    final hasCountdown = subarea.validationRemainingSeconds > 0;

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
                        onPressed: () => launchMaps(subarea.center),
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (subarea.status.toLowerCase() == 'banyak' ? 'Banyak Tersedia' : subarea.status).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              if (subarea.isValidated) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Tervalidasi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ] else if (subarea.hasUserReport) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Laporan Berbeda',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      if (subarea.lastValidationTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.history,
                                size: 10,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "Validasi Terakhir: ${() {
                                  try {
                                    final dt = DateTime.parse(subarea.lastValidationTime!).toLocal();
                                    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                                  } catch (_) {
                                    return subarea.lastValidationTime!;
                                  }
                                }()}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      if ((hasCountdown || subarea.maxSlots > 0) && subarea.status.toLowerCase() != 'netral' && subarea.fallbackStatus.toLowerCase() != 'netral')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (hasCountdown) const SizedBox.shrink(),
                            if (hasCountdown && subarea.maxSlots > 0)
                              const SizedBox(width: 8),
                            if (subarea.maxSlots > 0)
                              Text(
                                'Tersedia: ${subarea.maxSlots > subarea.currentCount ? subarea.maxSlots - subarea.currentCount : 0} | Terisi: ${subarea.currentCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
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
                                      separatorBuilder: (context, index) =>
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
                            parentContext,
                            MaterialPageRoute(
                              builder: (context) => CommentScreen(
                                subareaId: subarea.id,
                                subareaName: subarea.name,
                              ),
                            ),
                          ).then((_) {
                            // Silent Refresh saat kembali dari komentar
                            ref.invalidate(
                              parkVisualizationControllerProvider(areaId),
                            );
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
                child: _ValidationCountdownButton(
                  cooldown: cooldown,
                  onPressed: () => showValidationSheet(
                    parentContext,
                    subarea.id,
                    subarea.name,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
