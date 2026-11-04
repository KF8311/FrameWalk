
import 'package:flutter/material.dart';

import '../../models/photo_route.dart';
import '../widgets/route_card.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // starts on the previous walks tab, which is 0. saved walks is 1
  int _selectedTab = 0;

  // Temporary saved-route data.
  // Replace this with shared route data later.
  final List<PhotoRoute> _savedRoutes = [
    const PhotoRoute(
      id: '1',
      title: 'Route 1',
      durationMinutes: 20,
      distanceMiles: 1.0,
      sceneryTags: ['Nature', 'Easy'],
      isBookmarked: true,
    ),
    const PhotoRoute(
      id: '2',
      title: 'Route 2',
      durationMinutes: 15,
      distanceMiles: 0.8,
      sceneryTags: ['Architecture', 'Easy'],
      isBookmarked: true,
    ),
    const PhotoRoute(
      id: '3',
      title: 'Route 3',
      durationMinutes: 30,
      distanceMiles: 1.5,
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
                            onTap: () {
                              // TODO: Open route details. this will be same as home page
                            },
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
