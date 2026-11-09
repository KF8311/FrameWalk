import 'package:flutter/foundation.dart';

import '../models/mock_route_data.dart';
import '../models/photo_route.dart';
import '../backend/services/route_manager.dart';

// Single source of truth for routes and bookmarks.
class RouteProvider extends ChangeNotifier {
  // Defaults must match the strings used by RouteFilterChips.
  static const anyDuration = 'Any duration';
  static const anyDistance = 'Any distance';
  static const anyScenery = 'Any scenery';

  RouteProvider({RouteManager? manager, bool seedMockData = true})
      : _manager = manager ?? RouteManager() {
    if (seedMockData) {
      for (final route in MockRouteData.routes) {
        _manager.addRoute(route);
      }
    }
  }

  final RouteManager _manager;

  List<WalkingRoute> get routes => _manager.getAllRoutes();

  List<WalkingRoute> get bookmarkedRoutes => _manager.getBookmarkedRoutes();

  WalkingRoute? byId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    return _manager.getRoute(id);
  }

  bool isBookmarked(String id) => byId(id)?.isBookmarked ?? false;

  /// Routes matching the search text and every selected filter.
  /// Each page keeps its own filter selections and passes them in.
  List<WalkingRoute> search({
    String query = '',
    String duration = anyDuration,
    String distance = anyDistance,
    String scenery = anyScenery,
  }) {
    final q = query.trim().toLowerCase();

    final sceneryMatches = _manager.filterBySceneryTags(
      scenery == anyScenery ? const [] : [scenery],
    );

    return sceneryMatches.where((route) {
      final matchesQuery = route.name.toLowerCase().contains(q);

      final minutes = route.estimatedMinutes;
      final matchesDuration = switch (duration) {
        '0-15 min' => minutes <= 15,
        '15-30 min' => minutes > 15 && minutes <= 30,
        '30+ min' => minutes > 30,
        _ => true,
      };

      final miles = route.distanceMiles;
      final matchesDistance = switch (distance) {
        'Under 1 mi' => miles < 1,
        '1-2 mi' => miles >= 1 && miles <= 2,
        '2+ mi' => miles > 2,
        _ => true,
      };

      return matchesQuery && matchesDuration && matchesDistance;
    }).toList();
  }

  void toggleBookmark(String routeId) {
    if (_manager.toggleBookmark(routeId)) notifyListeners();
  }

  void addRoute(WalkingRoute route) {
    _manager.addRoute(route);
    notifyListeners();
  }

  void removeRoute(String routeId) {
    if (_manager.removeRoute(routeId)) notifyListeners();
  }

  void updateRoute(WalkingRoute route) {
    if (_manager.updateRoute(route)) notifyListeners();
  }
}

/// Bridge so RouteCard / RouteInfoPage keep working with PhotoRoute until
/// they are migrated to WalkingRoute.
extension WalkingRouteUi on WalkingRoute {
  PhotoRoute toPhotoRoute() => PhotoRoute(
    id: id,
    title: name,
    durationMinutes: estimatedMinutes,
    distanceMiles: distanceMiles,
    sceneryTags: sceneryTags,
    isBookmarked: isBookmarked,
  );
}
