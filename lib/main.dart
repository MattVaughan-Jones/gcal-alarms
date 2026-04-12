import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'calendar_service.dart';

void main() {
  runApp(const MeetingGuardPOC());
}

class MeetingGuardPOC extends StatelessWidget {
  const MeetingGuardPOC({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Guard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const POCPage(),
    );
  }
}

class POCPage extends StatefulWidget {
  const POCPage({super.key});

  @override
  State<POCPage> createState() => _POCPageState();
}

class _POCPageState extends State<POCPage> {
  static const platform = MethodChannel('meeting_guard/alarm');
  final CalendarService _calendarService = CalendarService();
  List<calendar.Event> _events = [];
  bool _isLoading = false;

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    final events = await _calendarService.getUpcomingEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _scheduleAlarm(calendar.Event event) async {
    final startTime = event.start?.dateTime ?? event.start?.date;
    if (startTime == null) return;

    final diff = startTime.difference(DateTime.now()).inSeconds;
    if (diff <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event is already in the past!')),
      );
      return;
    }

    try {
      await platform.invokeMethod('scheduleAlarm', {"seconds": diff});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm set for ${event.summary}')),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Guard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEvents,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _calendarService.signOut();
              setState(() => _events = []);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No events found. Refresh to sign in.'))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return ListTile(
                      title: Text(event.summary ?? 'No Title'),
                      subtitle: Text(
                        (event.start?.dateTime?.toLocal() ?? event.start?.date)
                            .toString(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.alarm_add),
                        onPressed: () => _scheduleAlarm(event),
                      ),
                    );
                  },
                ),
    );
  }
}
