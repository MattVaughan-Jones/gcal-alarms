import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'calendar_service.dart';

void main() {
  runApp(const MeetingGuard());
}

class MeetingGuard extends StatelessWidget {
  const MeetingGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Guard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  static const platform = MethodChannel('meeting_guard/alarm');
  final CalendarService _calendarService = CalendarService();
  List<calendar.Event> _events = [];
  bool _isLoading = false;

  // Map to store alarm lead times (minutes before event) keyed by event ID
  final Map<String, int> activeAlarms = {};

  Future<void> fetchEvents() async {
    setState(() => _isLoading = true);
    final events = await _calendarService.getUpcomingEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  // Helper to get a stable integer ID from a string event ID for Android PendingIntent
  int getAlarmId(String eventId) {
    return eventId.hashCode.abs();
  }

  Future<void> scheduleAlarm(calendar.Event event, int minutesBefore) async {
    final startTime = event.start?.dateTime ?? event.start?.date;
    final eventId = event.id;
    if (startTime == null || eventId == null) return;

    final alarmTime = startTime.subtract(Duration(minutes: minutesBefore));
    final diff = alarmTime.difference(DateTime.now()).inSeconds;

    if (diff <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm time is in the past!')),
        );
      }
      return;
    }

    try {
      await platform.invokeMethod('scheduleAlarm', {
        "seconds": diff,
        "id": getAlarmId(eventId),
      });
      if (mounted) {
        setState(() {
          activeAlarms[eventId] = minutesBefore;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Alarm set for ${event.summary} ($minutesBefore min before)'),
          ),
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

  Future<void> deleteAlarm(calendar.Event event) async {
    final eventId = event.id;
    if (eventId == null) return;

    try {
      await platform.invokeMethod('cancelAlarm', {
        "id": getAlarmId(eventId),
      });
      setState(() {
        activeAlarms.remove(eventId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm deleted for ${event.summary}')),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete alarm: ${e.message}')),
        );
      }
    }
  }

  void showEditModal(calendar.Event event) {
    final eventId = event.id;
    if (eventId == null) return;

    final initialMinutes = activeAlarms[eventId] ?? 0;
    final textController = TextEditingController(text: initialMinutes.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Alarm for ${event.summary}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Minutes before event:'),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (activeAlarms.containsKey(eventId))
            TextButton(
              onPressed: () {
                deleteAlarm(event);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final mins = int.tryParse(textController.text) ?? 0;
              scheduleAlarm(event, mins);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Guard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchEvents,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _calendarService.signOut();
              setState(() {
                _events = [];
                activeAlarms.clear();
              });
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
                    final eventId = event.id;
                    final hasAlarm = eventId != null && activeAlarms.containsKey(eventId);
                    final alarmMins = hasAlarm ? activeAlarms[eventId] : null;

                    return ListTile(
                      title: Text(event.summary ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (event.start?.dateTime?.toLocal() ?? event.start?.date)
                                .toString(),
                          ),
                          if (hasAlarm)
                            Row(
                              children: [
                                const Icon(Icons.alarm, size: 16, color: Colors.deepPurple),
                                const SizedBox(width: 4),
                                Text(
                                  'Alarm: $alarmMins min before',
                                  style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: hasAlarm
                          ? IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showEditModal(event),
                            )
                          : PopupMenuButton<int>(
                              icon: const Icon(Icons.alarm_add),
                              onSelected: (minutes) {
                                if (minutes == -1) {
                                  showEditModal(event);
                                } else {
                                  scheduleAlarm(event, minutes);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 3, child: Text('3 min before')),
                                const PopupMenuItem(value: 20, child: Text('20 min before')),
                                const PopupMenuItem(value: -1, child: Text('Custom...')),
                              ],
                            ),
                    );
                  },
                ),
    );
  }
}
