import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frame_walk/backend/services/location_source.dart';
import 'package:frame_walk/backend/services/walk_repository.dart';
import 'package:frame_walk/backend/services/walk_tracking_service.dart';
import 'package:frame_walk/frontend/screens/active_walk_page.dart';
import 'package:frame_walk/models/mock_route_data.dart';
import 'package:frame_walk/models/photo_route.dart';

import '../../backend/test/fakes/fake_location_source.dart';

void main() {
  const userId = 'user-1';
  const route = PhotoRoute(
    id: '1',
    title: 'Red Square Walk',
    durationMinutes: 30,
    distanceMiles: 1,
    sceneryTags: ['Architecture'],
  );

  late FakeFirebaseFirestore firestore;
  late FakeLocationSource location;
  late WalkTrackingService service;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    location = FakeLocationSource();
    await firestore.collection('users').doc(userId).set({
      'username': 'walker',
      'routesCompleted': 0,
    });
    service = WalkTrackingService(
      locationSource: location,
      repository: WalkRepository(firestore: firestore),
    );
  });

  tearDown(() => service.dispose());

  Future<void> openPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActiveWalkPage(
                  route: route,
                  stops: MockRouteData.getStops('1'),
                  routePoints: MockRouteData.getRoutePoints('1'),
                  trackingService: service,
                  userId: userId,
                  showMap: false,
                ),
              ),
            ),
            child: const Text('Root'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Root'));
    await tester.pumpAndSettle();
  }

  testWidgets('explains a denied permission and lets the user try again',
      (tester) async {
    location.permission = LocationPermissionStatus.denied;
    location.answerToRequest = LocationPermissionStatus.denied;
    await openPage(tester);

    expect(find.textContaining('needs your location'), findsOneWidget);
    expect(location.isStreaming, isFalse);

    location.answerToRequest = LocationPermissionStatus.granted;
    await tester.tap(find.text('Allow location'));
    await tester.pumpAndSettle();
    expect(find.text('0 of 4 stops reached'), findsOneWidget);
    expect(location.isStreaming, isTrue);

    // End the walk so its timers stop before the test finishes.
    await tester.runAsync(service.cancelWalk);
    await tester.pumpAndSettle();
  });

  testWidgets('sends the user to settings when GPS is off', (tester) async {
    location.serviceEnabled = false;
    await openPage(tester);

    expect(find.textContaining('Location services are turned off'),
        findsOneWidget);
    await tester.tap(find.text('Open location settings'));
    expect(location.locationSettingsOpened, 1);
  });

  testWidgets('shows progress and finishes the walk', (tester) async {
    await openPage(tester);
    expect(find.text('Finding your location...'), findsOneWidget);

    // At Red Square, the first stop.
    location.emit(sampleAt(47.6559, -122.3078, DateTime.now()));
    await tester.pump();
    expect(find.text('1 of 4 stops reached'), findsOneWidget);
    expect(find.textContaining('Next: Suzzallo Library'), findsOneWidget);
    expect(find.textContaining('You reached Red Square'), findsOneWidget);

    await tester.tap(find.text('Finish walk'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Walk complete!'), findsOneWidget);
    expect(location.isStreaming, isFalse);
  });

  testWidgets('asks before cancelling, then stops tracking', (tester) async {
    await openPage(tester);

    await tester.tap(find.text('Cancel walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep walking'));
    await tester.pumpAndSettle();
    expect(location.isStreaming, isTrue);

    await tester.tap(find.text('Cancel walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel walk').last);
    await tester.pumpAndSettle();

    expect(service.phase, WalkPhase.cancelled);
    expect(location.isStreaming, isFalse);
    expect(find.text('Root'), findsOneWidget, reason: 'page closed');
  });
}
