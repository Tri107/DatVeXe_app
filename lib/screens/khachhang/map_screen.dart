import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../themes/gradient.dart';

class MapScreen extends StatefulWidget {
  final String? startName;
  final String? endName;

  const MapScreen({super.key, this.startName, this.endName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //  Controller để điều khiển camera (zoom/fit)
  final MapController _mapController = MapController();

  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  List<LatLng> routePoints = [];
  LatLng? startPoint;
  LatLng? endPoint;
  String? _distance;
  String? _duration;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.startName != null && widget.endName != null) {
      _startCtrl.text = widget.startName!;
      _endCtrl.text = widget.endName!;
      _drawRoute();
    }
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  //  Lấy tọa độ từ tên địa điểm
  Future<LatLng?> _getCoordinates(String name) async {
    // Gọi Nominatim (dùng Uri.https để auto-encode query)
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': name,
      'format': 'json',
      'limit': '1',
    });

    final res = await http.get(
      url,
      headers: {'User-Agent': 'DatVeXeApp/1.0 (contact: you@example.com)'},
    );

    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    if (data is List && data.isNotEmpty) {
      return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
    }
    return null;
  }

  // Gọi OSRM để lấy tuyến, khoảng cách, thời gian
  Future<Map<String, dynamic>> _getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('OSRM đang bận hoặc không phản hồi');
    }
    final data = jsonDecode(res.body);
    if (data['routes'] == null || (data['routes'] as List).isEmpty) {
      throw Exception('Không tìm thấy tuyến đường phù hợp');
    }

    final route = data['routes'][0];
    final coords = route['geometry']['coordinates'] as List;

    final points = coords.map((c) => LatLng(c[1], c[0])).toList();
    final distance = (route['distance'] / 1000).toStringAsFixed(1); // km
    final totalMinutes = (route['duration'] / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final duration = hours > 0 ? '${hours}h ${minutes}p' : '$minutes phút';

    return {'points': points, 'distance': distance, 'duration': duration};
  }

  // Tìm & vẽ tuyến + auto-zoom vào tuyến
  Future<void> _drawRoute() async {
    setState(() => _loading = true);

    try {
      final start = await _getCoordinates(_startCtrl.text.trim());
      final end = await _getCoordinates(_endCtrl.text.trim());

      if (start == null || end == null) {
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy tọa độ bến xe.')),
        );
        return;
      }

      final result = await _getRoute(start, end);

      if (!mounted) return;
      setState(() {
        startPoint = start;
        endPoint = end;
        routePoints = (result['points'] as List<LatLng>);
        _distance = result['distance'];
        _duration = result['duration'];
        _loading = false;
      });

      // Auto-fit camera bao trọn tuyến (flutter_map v6)
      if (routePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(routePoints);
        // chờ map render xong trước khi fit
        await Future.delayed(const Duration(milliseconds: 300));
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tìm tuyến: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Bản đồ đường đi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(10.762622, 106.660172),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'flutter_map',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              if (startPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.green),
                    ),
                  ],
                ),
              if (endPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: endPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.flag, color: Colors.red),
                    ),
                  ],
                ),
            ],
          ),

          //  Panel thông tin + nhập bến
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_distance != null && _duration != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.route, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                '$_distance km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_duration',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Row(
                      children: [
                        // --- Cột Điểm đi ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.location_on, color: Colors.green, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Điểm đi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _startCtrl.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.visible,
                                maxLines: null,
                              ),
                            ],
                          ),
                        ),

                        // --- Dấu mũi tên ---
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.blueAccent,
                            size: 22,
                          ),
                        ),

                        // --- Cột Điểm đến ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.flag, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Điểm đến',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endCtrl.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.visible,
                                maxLines: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
