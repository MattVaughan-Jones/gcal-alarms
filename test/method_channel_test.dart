import 'package:flutter_test/flutter_test.dart';
import 'package:meetingguard/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI Basic Tests', () {
    testWidgets('Renders Meeting Guard and displays empty state', (WidgetTester tester) async {
      await tester.pumpWidget(const MeetingGuard());
      expect(find.text('Meeting Guard'), findsOneWidget);
      expect(find.text('No events found. Refresh to sign in.'), findsOneWidget);
    });
  });
}
