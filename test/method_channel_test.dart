import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetingguard/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Alarm MethodChannel Tests', () {
    testWidgets('Tapping Trigger Test Alarm calls method channel', (WidgetTester tester) async {
      const channel = MethodChannel('meeting_guard/alarm');
      final List<MethodCall> log = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      await tester.pumpWidget(const MeetingGuardPOC());

      // Find and tap the button
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      await tester.tap(button);
      await tester.pump();

      // Verify the method was called with correct arguments
      expect(log, [
        isMethodCall('scheduleAlarm', arguments: {'seconds': 10}),
      ]);
    });
  });
}
