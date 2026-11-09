
import 'package:flutter/material.dart';
import 'package:frame_walk/backend/services/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../backend/services/route_manager.dart';
import '../../models/route_stop.dart';

class RouteInfoPage extends StatefulWidget {
  const RouteInfoPage({
    super.key,
    required this.route,
    required this.stops,
    required this.routePoints,
  });

  final WalkingRoute route;
  final List<RouteStop> stops;
  final List<LatLng> routePoints;

  @override
  State<RouteInfoPage> createState() => _RouteInfoPageState();
}

class _RouteInfoPageState extends State<RouteInfoPage> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.route.isBookmarked;
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // TODO: Save the bookmark state to your database.
  }

  Set<Marker> _buildMarkers() {
    return widget.stops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.id),
        position: LatLng(
          stop.latitude,
          stop.longitude,
        ),
        infoWindow: InfoWindow(
          title: stop.name,
          snippet: stop.prompt,
        ),
      );
    }).toSet();
  }

  Set<Polyline> _buildPolylines(Color routeColor) {
    if (widget.routePoints.isEmpty) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routePoints,
        color: routeColor,
        width: 5,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map with back and bookmark buttons.
              SizedBox(
                height: 210,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: widget.routePoints.isEmpty
                          ? const Center(
                              child: Text('Route map unavailable'),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: widget.routePoints.first,
                                zoom: 15,
                              ),
                              markers: _buildMarkers(),
                              polylines: _buildPolylines(
                                colorScheme.primary,
                              ),
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationButtonEnabled: false,
                              onMapCreated: (controller) {
                                // TODO: Adjust camera to show the
                                // entire route when needed.
                              },
                            ),
                    ),

                    // Back button.
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Bookmark button.
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: _toggleBookmark,
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Route information.
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.route.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),

                    const SizedBox(height: 12),

                    // Duration, number of stops, and tags.
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.route.estimatedMinutes} min',
                        ),

                        const SizedBox(width: 12),

                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text('${widget.stops.length} stops'),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: widget.route.sceneryTags
                                .take(2)
                                .map((tag) {
                              return Chip(
                                label: Text(tag),
                                visualDensity:
                                    VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Start Walk button.
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Start Walk'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Route Stops',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 12),

                    // Expandable stops.
                    ...widget.stops.asMap().entries.map((entry) {
                      final index = entry.key;
                      final stop = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  colorScheme.primary,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    stop.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  childrenPadding:
                                      const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  children: [
                                    Align(
                                      alignment:
                                          Alignment.centerLeft,
                                      child: Text(stop.prompt),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
