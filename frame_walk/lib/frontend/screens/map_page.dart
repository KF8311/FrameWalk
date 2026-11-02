import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  static const LatLng uwCampus = LatLng(47.6553, -122.3035);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: uwCampus,
        zoom: 15,
      ),
      mapType: MapType.normal,
      myLocationEnabled: false,
      zoomControlsEnabled: true,
    );
  }
}
