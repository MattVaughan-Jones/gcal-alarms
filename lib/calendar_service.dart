import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

class CalendarService {
  final GoogleSignIn _googleSignIn;

  CalendarService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: <String>[
                calendar.CalendarApi.calendarReadonlyScope,
              ],
            );

  GoogleSignInAccount? _currentUser;

  Future<auth.AuthClient?> getAuthenticatedClient() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      _currentUser ??= await _googleSignIn.signIn();

      if (_currentUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await _currentUser!.authentication;

      return auth.authenticatedClient(
        http.Client(),
        auth.AccessCredentials(
          auth.AccessToken(
            'Bearer',
            googleAuth.accessToken!,
            DateTime.now().add(const Duration(hours: 1)).toUtc(), // Simplified expiry
          ),
          null,
          _googleSignIn.scopes,
        ),
      );
    } catch (e) {
      debugPrint('Error getting authenticated client: $e');
      return null;
    }
  }

  Future<List<calendar.Event>> getUpcomingEvents() async {
    final client = await getAuthenticatedClient();
    if (client == null) return [];

    try {
      final calendarApi = calendar.CalendarApi(client);
      final now = DateTime.now().toUtc();
      final fiveDaysFromNow = now.add(const Duration(days: 5));

      final events = await calendarApi.events.list(
        'primary',
        timeMin: now,
        timeMax: fiveDaysFromNow,
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    } finally {
      client.close();
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
