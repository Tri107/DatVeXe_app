import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String? startName;
  final String? endName;

  const MapScreen({
    super.key,
    this.startName,
    this.endName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

  // Lấy tọa độ từ Nominatim (tên địa điểm → lat/lon)
  Future<LatLng?> _getCoordinates(String name) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$name&format=json&limit=1');
    final res = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
    final data = jsonDecode(res.body);
    if (data.isEmpty) return null;
    return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
  }

  //  Gọi OSRM để lấy tuyến đường, khoảng cách và thời gian
  Future<Map<String, dynamic>> _getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    final route = data['routes'][0];
    final coords = route['geometry']['coordinates'] as List;

    final points = coords.map((c) => LatLng(c[1], c[0])).toList();
    final distance = (route['distance'] / 1000).toStringAsFixed(1); // km
    final totalMinutes = (route['duration'] / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String duration;
    if (hours > 0) {
      duration = '${hours}h ${minutes}p';
    } else {
      duration = '${minutes} phút';
    }

    return {
      'points': points,
      'distance': distance,
      'duration': duration,
    };
  }

  // Tìm và vẽ đường đi
  Future<void> _drawRoute() async {
    setState(() => _loading = true);

    final start = await _getCoordinates(_startCtrl.text);
    final end = await _getCoordinates(_endCtrl.text);
    if (start == null || end == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy tọa độ địa điểm')),
      );
      return;
    }

    final result = await _getRoute(start, end);
    setState(() {
      startPoint = start;
      endPoint = end;
      routePoints = result['points'];
      _distance = result['distance'];
      _duration = result['duration'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ đường đi')),
      body: Stack(
        children: [
          //  Bản đồ
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(10.762622, 106.660172),
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
                MarkerLayer(markers: [
                  Marker(
                    point: startPoint!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.green),
                  ),
                ]),
              if (endPoint != null)
                MarkerLayer(markers: [
                  Marker(
                    point: endPoint!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.flag, color: Colors.red),
                  ),
                ]),
            ],
          ),


          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2), blurRadius: 8),
                ],
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
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
                          Row(children: [
                            const Icon(Icons.route, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('$_distance km',
                                style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          Row(children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('$_duration ',
                                style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Điểm đi',
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Điểm đến',
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
