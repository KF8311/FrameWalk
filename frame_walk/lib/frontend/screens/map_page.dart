import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/photo_route.dart';
import '../theme/app_theme.dart';
import '../widgets/route_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  static const LatLng uwCampus = LatLng(47.6553, -122.3035);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _routeColor = Color(0xFF7966FF);
  final _searchController = TextEditingController();
  final _bookmarkedIds = <String>{};
  GoogleMapController? _mapController;
  BitmapDescriptor? _cameraIcon;
  String _query = '';
  int? _duration;
  _CampusRoute? _selected;

  // UI fixtures only: replace with the team's curated route coordinates.
  // These paths are illustrative, not verified walking directions.
  static const _routes = [
    _CampusRoute(
      route: PhotoRoute(
        id: 'map-burke',
        title: 'Burke Museum Loop',
        durationMinutes: 12,
        distanceMiles: 0.5,
        sceneryTags: ['Architecture', 'Urban'],
      ),
      points: [
        LatLng(47.6605, -122.3115),
        LatLng(47.6604, -122.3095),
        LatLng(47.6597, -122.3088),
        LatLng(47.6586, -122.3090),
        LatLng(47.6583, -122.3108),
        LatLng(47.6592, -122.3117),
        LatLng(47.6605, -122.3115),
      ],
    ),
    _CampusRoute(
      route: PhotoRoute(
        id: 'map-quad',
        title: 'UW Quad Walk',
        durationMinutes: 15,
        distanceMiles: 0.6,
        sceneryTags: ['Nature', 'Architecture'],
      ),
      points: [
        LatLng(47.6584, -122.3078),
        LatLng(47.6588, -122.3063),
        LatLng(47.6582, -122.3053),
        LatLng(47.6569, -122.3055),
        LatLng(47.6566, -122.3067),
        LatLng(47.6572, -122.3080),
        LatLng(47.6584, -122.3078),
      ],
    ),
    _CampusRoute(
      route: PhotoRoute(
        id: 'map-drumheller',
        title: 'Drumheller Fountain Loop',
        durationMinutes: 25,
        distanceMiles: 1.0,
        sceneryTags: ['Water', 'Nature'],
      ),
      points: [
        LatLng(47.6540, -122.3070),
        LatLng(47.6541, -122.3055),
        LatLng(47.6536, -122.3043),
        LatLng(47.6524, -122.3042),
        LatLng(47.6518, -122.3056),
        LatLng(47.6523, -122.3071),
        LatLng(47.6540, -122.3070),
      ],
    ),
  ];

  List<_CampusRoute> get _visibleRoutes => _routes.where((item) {
    final route = item.route;
    final text = '${route.title} ${route.sceneryTags.join(' ')}'.toLowerCase();
    final matchesDuration =
        _duration == null ||
        (_duration == 15 &&
            route.durationMinutes >= 10 &&
            route.durationMinutes <= 15) ||
        (_duration == 30 &&
            route.durationMinutes > 15 &&
            route.durationMinutes <= 30);
    return text.contains(_query.trim().toLowerCase()) && matchesDuration;
  }).toList();

  @override
  void initState() {
    super.initState();
    _createCameraIcon();
  }

  // Draw the camera badges without requiring image assets or a new package.
  Future<void> _createCameraIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(const Offset(36, 36), 33, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(36, 36), 29, Paint()..color = _routeColor);
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 25, 36, 25),
        const Radius.circular(4),
      ),
      outline,
    );
    canvas.drawCircle(const Offset(36, 37), 7, outline);
    canvas.drawLine(const Offset(24, 24), const Offset(30, 20), outline);
    canvas.drawLine(const Offset(30, 20), const Offset(42, 20), outline);
    canvas.drawLine(const Offset(42, 20), const Offset(48, 24), outline);
    final picture = recorder.endRecording();
    final image = await picture.toImage(72, 72);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (!mounted || bytes == null) return;
    setState(() {
      _cameraIcon = BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        width: 36,
        height: 36,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateFilters({String? query, int? duration, bool reset = false}) {
    setState(() {
      if (query != null) _query = query;
      if (reset) {
        _duration = null;
      } else if (duration != null) {
        _duration = _duration == duration ? null : duration;
      }
      if (!_visibleRoutes.contains(_selected)) _selected = null;
    });
  }

  Future<void> _selectRoute(_CampusRoute item) async {
    FocusScope.of(context).unfocus();
    setState(() => _selected = item);
    // Allow the detail card to lay out before fitting the route to the map.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    var south = item.points.first.latitude;
    var north = south;
    var west = item.points.first.longitude;
    var east = west;
    for (final point in item.points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        44,
      ),
    );
  }

  void _toggleBookmark(_CampusRoute item) {
    setState(() {
      if (!_bookmarkedIds.remove(item.route.id)) {
        _bookmarkedIds.add(item.route.id);
      }
    });
  }

  Widget _routeCard(_CampusRoute item, VoidCallback onTap) => RouteCard(
    route: item.route.copyWith(
      isBookmarked: _bookmarkedIds.contains(item.route.id),
    ),
    onTap: onTap,
    onBookmarkTap: () => _toggleBookmark(item),
  );

  Future<void> _showRouteList() async {
    FocusScope.of(context).unfocus();
    final routes = _visibleRoutes;
    final chosen = await showModalBottomSheet<_CampusRoute>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.65,
        child: StatefulBuilder(
          builder: (context, updateSheet) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Campus routes (${routes.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close routes',
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: routes.isEmpty
                      ? const Center(
                          child: Text(
                            'No routes match your search or filters.',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: routes.length,
                          itemBuilder: (context, index) {
                            final item = routes[index];
                            return RouteCard(
                              route: item.route.copyWith(
                                isBookmarked: _bookmarkedIds.contains(
                                  item.route.id,
                                ),
                              ),
                              onTap: () => Navigator.pop(sheetContext, item),
                              onBookmarkTap: () {
                                _toggleBookmark(item);
                                updateSheet(() {});
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
    if (mounted && chosen != null) await _selectRoute(chosen);
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppTheme.teal,
      backgroundColor: const Color(0xFFE2E9DF),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.black),
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = _visibleRoutes;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'FrameWalk',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _updateFilters(query: value),
              onSubmitted: (_) => _showRouteList(),
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search routes',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppTheme.teal,
                prefixIcon: IconButton(
                  tooltip: 'Browse matching routes',
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: _showRouteList,
                ),
                suffixIcon: IconButton(
                  tooltip: _query.isEmpty ? 'Search routes' : 'Clear search',
                  icon: Icon(
                    _query.isEmpty ? Icons.search : Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_query.isEmpty) {
                      _showRouteList();
                    } else {
                      _searchController.clear();
                      _updateFilters(query: '');
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                _filterChip('Near UW', _duration == null, () {
                  _updateFilters(reset: true);
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      const CameraPosition(target: MapPage.uwCampus, zoom: 15),
                    ),
                  );
                }),
                const SizedBox(width: 10),
                _filterChip(
                  '10–15 min',
                  _duration == 15,
                  () => _updateFilters(duration: 15),
                ),
                const SizedBox(width: 10),
                _filterChip(
                  '15–30 min',
                  _duration == 30,
                  () => _updateFilters(duration: 30),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: MapPage.uwCampus,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (_) {
                    FocusScope.of(context).unfocus();
                    setState(() => _selected = null);
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: true,
                  padding: const EdgeInsets.only(top: 44, bottom: 8),
                  polylines: {
                    for (final item in routes)
                      Polyline(
                        polylineId: PolylineId(item.route.id),
                        points: item.points,
                        color: _selected == item ? AppTheme.teal : _routeColor,
                        width: _selected == item ? 6 : 3,
                        zIndex: _selected == item ? 2 : 1,
                        consumeTapEvents: true,
                        onTap: () => _selectRoute(item),
                      ),
                  },
                  markers: {
                    for (final item in routes)
                      Marker(
                        markerId: MarkerId(item.route.id),
                        position: item.points.first,
                        anchor: const Offset(0.5, 0.5),
                        icon:
                            _cameraIcon ??
                            BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueViolet,
                            ),
                        onTap: () => _selectRoute(item),
                      ),
                  },
                  circles: {
                    for (final item in routes)
                      for (var i = 1; i < item.points.length - 1; i++)
                        Circle(
                          circleId: CircleId('${item.route.id}-$i'),
                          center: item.points[i],
                          radius: 7,
                          fillColor: Colors.white,
                          strokeColor: _selected == item
                              ? AppTheme.teal
                              : _routeColor,
                          strokeWidth: 2,
                          consumeTapEvents: true,
                          onTap: () => _selectRoute(item),
                        ),
                  },
                ),
                Positioned(
                  top: 8,
                  left: 12,
                  child: Material(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        routes.isEmpty
                            ? 'No matching routes'
                            : '${routes.length} sample routes · Tap to explore',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selected != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.3,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Close route details',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selected = null),
                      ),
                    ),
                    _routeCard(_selected!, () => _selectRoute(_selected!)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CampusRoute {
  const _CampusRoute({required this.route, required this.points});

  final PhotoRoute route;
  final List<LatLng> points;
}
