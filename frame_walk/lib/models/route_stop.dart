//can change this
class RouteStop {
  final String id;
  final String name;
  final String prompt;

  // Coordinates for displaying this stop on the map.
  final double latitude;
  final double longitude;

  const RouteStop({
    required this.id,
    required this.name,
    required this.prompt,
    required this.latitude,
    required this.longitude,
  });
}
