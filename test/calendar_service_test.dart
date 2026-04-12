import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetingguard/calendar_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'calendar_service_test.mocks.dart';

@GenerateMocks([GoogleSignIn, GoogleSignInAccount])
void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late CalendarService calendarService;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    calendarService = CalendarService(googleSignIn: mockGoogleSignIn);
  });

  group('CalendarService', () {
    test('signOut calls GoogleSignIn.signOut', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      
      await calendarService.signOut();
      
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });
}
