import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:meetingguard/main.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Alarm Method Channel Tests', () {
    const channel = MethodChannel('meeting_guard/alarm');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    tearDown(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets('scheduleAlarm calls native with correct parameters', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CalendarPage()));
      final state = tester.state<CalendarPageState>(find.byType(CalendarPage));

      final event = calendar.Event(
        id: 'test-id-123',
        summary: 'Test Event',
        start: calendar.EventDateTime(dateTime: DateTime.now().add(const Duration(minutes: 60))),
      );

      // Using the public method name now
      await state.scheduleAlarm(event, 5);

      expect(log, hasLength(1));
      expect(log.first.method, 'scheduleAlarm');
      expect(log.first.arguments['seconds'], closeTo(3300, 10)); // ~55 mins
      expect(log.first.arguments['id'], isNotNull);
    });

    testWidgets('deleteAlarm calls cancelAlarm on native', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CalendarPage()));
      final state = tester.state<CalendarPageState>(find.byType(CalendarPage));

      final event = calendar.Event(id: 'test-id-123', summary: 'Test Event');
      
      state.setState(() {
        state.activeAlarms['test-id-123'] = 5;
      });

      await state.deleteAlarm(event);

      expect(log, hasLength(1));
      expect(log.first.method, 'cancelAlarm');
      expect(log.first.arguments['id'], isNotNull);
      expect(state.activeAlarms.containsKey('test-id-123'), isFalse);
    });
  });
}
