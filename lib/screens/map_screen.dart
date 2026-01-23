import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/config/supabase_config.dart';

class MapGeneralPage extends StatefulWidget {
  const MapGeneralPage({super.key});

  @override
  State<MapGeneralPage> createState() => _MapGeneralPageState();
}

class _MapGeneralPageState extends State<MapGeneralPage> {
  LatLng? _currentPosition;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadReportMarkers();
  }

  // Módulo 3.4: Obtener ubicación actual automáticamente
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  // Cargar reportes de Supabase y convertirlos en Marcadores
  Future<void> _loadReportMarkers() async {
    final data = await SupabaseConfig.client
        .from('reportes')
        .select()
        .neq('estado', 'resuelto'); // Solo reportes no resueltos

    for (var item in data) {
      _markers.add(
        Marker(
          point: LatLng(item['latitud'], item['longitud']),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showReportDetail(item),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        ),
      );
    }
    setState(() {});
  }

  void _showReportDetail(Map<String, dynamic> reporte) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reporte['titulo'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Categoría: ${reporte['categoria']}"),
            const SizedBox(height: 10),
            Text(reporte['descripcion'] ?? "Sin descripción"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(-0.1807, -78.4678), // Quito por defecto si falla el GPS
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tu_dominio.urbanreport',
                ),
                MarkerLayer(markers: _markers),
                // Marcador de la ubicación actual del usuario
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}