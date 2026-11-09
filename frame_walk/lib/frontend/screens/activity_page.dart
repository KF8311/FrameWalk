
import 'package:flutter/material.dart';
import 'package:frame_walk/backend/services/route_manager.dart';

import '../../models/photo_route.dart';
import '../widgets/route_card.dart';
import '../../models/mock_route_data.dart';
import 'route_info_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // starts on the previous walks tab, which is 0. saved walks is 1
  int _selectedTab = 0;

 // Temporary saved-route data.
  // These should eventually be shared with HomePage.
  final List<PhotoRoute> _savedRoutes = [
    const PhotoRoute(
      id: '1',
      title: 'Red Square Walk',
      durationMinutes: 10,
      distanceMiles: 0.5,
      sceneryTags: ['Architecture', 'Urban'],
      isBookmarked: true,
    ),
    const PhotoRoute(
      id: '2',
      title: 'UW Nature Walk',
      durationMinutes: 20,
      distanceMiles: 1.2,
      sceneryTags: ['Nature', 'Urban'],
      isBookmarked: true,
    ),
    const PhotoRoute(
      id: '3',
      title: 'Waterfront Views',
      durationMinutes: 30,
      distanceMiles: 1.8,
      sceneryTags: ['Water', 'Nature'],
      isBookmarked: true,
    ),
  ];

  // for now replaces the route with a copy that isn't bookmarked - change in future
  void _toggleBookmark(PhotoRoute route) {
    setState(() {
      final index = _savedRoutes.indexWhere(
        (savedRoute) => savedRoute.id == route.id,
      );

      if (index != -1) {
        _savedRoutes[index] = _savedRoutes[index].copyWith(
          isBookmarked: !_savedRoutes[index].isBookmarked,
        );
      }
    });
  }

  void _openRoute(PhotoRoute route) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RouteInfoPage(
        route: route,
        stops: MockRouteData.getStops(route.id),
        routePoints: MockRouteData.getRoutePoints(route.id),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final savedRoutes = _savedRoutes
        .where((route) => route.isBookmarked)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'FrameWalk',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),

        // Previous Walks / Saved Walks tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E9DF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  label: 'Previous Walks',
                  index: 0,
                ),
                _buildTabButton(
                  label: 'Saved Walks',
                  index: 1,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Tab content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _selectedTab == 0 ? 'Previous Walks' : 'Saved Walks',
            style: Theme.of(context).textTheme.titleLarge
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: _selectedTab == 0
              // No previous walks yet. 
              ? const SizedBox.shrink()

              // Saved routes use the same cards as Home.
              : savedRoutes.isEmpty
                  ? const Center(
                      child: Text('No saved walks yet.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      itemCount: savedRoutes.length,
                      itemBuilder: (context, index) {
                        final route = savedRoutes[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            route: route,
                            onTap: () => _openRoute(route),
                            onBookmarkTap: () {
                              _toggleBookmark(route);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required int index,
  }) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF195B50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
