import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: MapOptions(
        initialCenter: LatLng(51.509364, -0.128928), // Center the map over London
    initialZoom: 9.2,
    ),
    children: [TileLayer( // Display map tiles from any source
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
    userAgentPackageName: 'com.example.app',
    // And many more recommended properties!
    ),],
    );
  }
}
