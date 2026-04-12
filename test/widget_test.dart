import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetingguard/main.dart';

void main() {
  testWidgets('Counter incremental smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MeetingGuardPOC());
    expect(find.text('Meeting Guard POC'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
