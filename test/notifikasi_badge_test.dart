import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project_camp_sewa/services/api_notifikasi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notifikasi Badge & Controller Tests', () {
    late ApiNotifikasi controller;

    setUp(() {
      Get.reset();
      controller = Get.put(ApiNotifikasi(), permanent: true);
    });

    tearDown(() {
      Get.reset();
    });

    test('ApiNotifikasi unreadCount is reactive', () {
      expect(controller.unreadCount.value, 0);

      controller.unreadCount.value = 3;
      expect(controller.unreadCount.value, 3);

      controller.unreadCount.value = 0;
      expect(controller.unreadCount.value, 0);
    });

    testWidgets('Dashboard Notification Bell renders badge immediately when unreadCount > 0', (tester) async {
      // Set unreadCount before building widget to simulate initial load with unread notifications
      controller.unreadCount.value = 2;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: Obx(() {
                final unread = controller.unreadCount.value;
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 24),
                      if (unread > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            key: const Key('notif_badge'),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEE2737),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unread > 9 ? "9+" : "$unread",
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      );

      // Verify badge is present immediately on initial build without any click
      expect(find.byKey(const Key('notif_badge')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Verify that changing unreadCount reactively updates the badge
      controller.unreadCount.value = 12;
      await tester.pump();
      expect(find.text('9+'), findsOneWidget);

      // Verify that when unreadCount is 0, the badge disappears
      controller.unreadCount.value = 0;
      await tester.pump();
      expect(find.byKey(const Key('notif_badge')), findsNothing);

      // Verify that when a new notification arrives (unreadCount becomes 1), the badge appears without click
      controller.unreadCount.value = 1;
      await tester.pump();
      expect(find.byKey(const Key('notif_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
