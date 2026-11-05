
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'route_stop.dart';

// mock route data to show when opening a route info page
class MockRouteData {
  // RED SQUARE WALK
  static const List<RouteStop> redSquareStops = [
    RouteStop(
      id: 'red_stop_1',
      name: 'Red Square',
      prompt: 'Capture an interesting pattern in the surrounding architecture.',
      latitude: 47.6559,
      longitude: -122.3078,
    ),
    RouteStop(
      id: 'red_stop_2',
      name: 'Suzzallo Library',
      prompt: 'Find an interesting contrast between light and shadow.',
      latitude: 47.6553,
      longitude: -122.3099,
    ),
    RouteStop(
      id: 'red_stop_3',
      name: 'Drumheller Fountain',
      prompt: 'Photograph a reflection or interesting interaction with water.',
      latitude: 47.6545,
      longitude: -122.3070,
    ),
    RouteStop(
      id: 'red_stop_4',
      name: 'Kane Hall',
      prompt: 'Find an everyday object that tells a story about campus life.',
      latitude: 47.6560,
      longitude: -122.3090,
    ),
  ];

  // UW NATURE WALK
  static const List<RouteStop> uwNatureStops = [
    RouteStop(
      id: 'nature_stop_1',
      name: 'Rainier Vista',
      prompt: 'Capture the relationship between nature and architecture.',
      latitude: 47.6534,
      longitude: -122.3075,
    ),
    RouteStop(
      id: 'nature_stop_2',
      name: 'Gould Hall Garden',
      prompt: 'Find an interesting leaf shape or natural pattern.',
      latitude: 47.6568,
      longitude: -122.3110,
    ),
    RouteStop(
      id: 'nature_stop_3',
      name: 'Quad',
      prompt: 'Photograph something that shows the changing seasons.',
      latitude: 47.6568,
      longitude: -122.3100,
    ),
    RouteStop(
      id: 'nature_stop_4',
      name: 'Sylvan Grove',
      prompt: 'Look for an interesting texture in the trees or landscape.',
      latitude: 47.6578,
      longitude: -122.3120,
    ),
  ];

  // WATERFRONT VIEWS
  static const List<RouteStop> waterfrontStops = [
    RouteStop(
      id: 'water_stop_1',
      name: 'Waterfront Activities Center',
      prompt: 'Capture the colors and movement of the water.',
      latitude: 47.6502,
      longitude: -122.3015,
    ),
    RouteStop(
      id: 'water_stop_2',
      name: 'Union Bay',
      prompt: 'Photograph a reflection on the water.',
      latitude: 47.6495,
      longitude: -122.3000,
    ),
    RouteStop(
      id: 'water_stop_3',
      name: 'Waterfront Path',
      prompt: 'Find an interesting natural shape or silhouette.',
      latitude: 47.6488,
      longitude: -122.3020,
    ),
    RouteStop(
      id: 'water_stop_4',
      name: 'Waterfront Overlook',
      prompt: 'Capture a wide-angle view that shows depth and perspective.',
      latitude: 47.6498,
      longitude: -122.3040,
    ),
  ];

  // ROUTE COORDINATES
  // These coordinates determine the line drawn on Google Maps.

  static const List<LatLng> redSquareRoutePoints = [
    LatLng(47.6559, -122.3078),
    LatLng(47.6553, -122.3099),
    LatLng(47.6545, -122.3070),
    LatLng(47.6560, -122.3090),
  ];

  static const List<LatLng> uwNatureRoutePoints = [
    LatLng(47.6534, -122.3075),
    LatLng(47.6568, -122.3110),
    LatLng(47.6568, -122.3100),
    LatLng(47.6578, -122.3120),
  ];

  static const List<LatLng> waterfrontRoutePoints = [
    LatLng(47.6502, -122.3015),
    LatLng(47.6495, -122.3000),
    LatLng(47.6488, -122.3020),
    LatLng(47.6498, -122.3040),
  ];

  // GET STOPS FOR A ROUTE
  static List<RouteStop> getStops(String routeId) {
    switch (routeId) {
      case '1':
        return redSquareStops;
      case '2':
        return uwNatureStops;
      case '3':
        return waterfrontStops;
      default:
        return [];
    }
  }

  // GET MAP COORDINATES FOR A ROUTE
  static List<LatLng> getRoutePoints(String routeId) {
    switch (routeId) {
      case '1':
        return redSquareRoutePoints;
      case '2':
        return uwNatureRoutePoints;
      case '3':
        return waterfrontRoutePoints;
      default:
        return [];
    }
  }
}
