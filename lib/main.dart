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
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const platform = MethodChannel('meeting_guard/alarm');
  final CalendarService _calendarService = CalendarService();
  List<calendar.Event> _events = [];
  bool _isLoading = false;

  // Map to store alarm lead times (minutes before event) keyed by event ID
  final Map<String, int> _activeAlarms = {};

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    final events = await _calendarService.getUpcomingEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _scheduleAlarm(calendar.Event event, int minutesBefore) async {
    final startTime = event.start?.dateTime ?? event.start?.date;
    if (startTime == null) return;

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
      await platform.invokeMethod('scheduleAlarm', {"seconds": diff});
      if (mounted) {
        setState(() {
          if (event.id != null) {
            _activeAlarms[event.id!] = minutesBefore;
          }
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

  Future<void> _deleteAlarm(calendar.Event event) async {
    // TODO: Implement platform method to cancel a specific alarm via AlarmManager.
    // This is critical for preventing ghost alarms if an event is canceled or lead time changed.
    setState(() {
      if (event.id != null) {
        _activeAlarms.remove(event.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm deleted for ${event.summary}')),
    );
  }

  void _showEditModal(calendar.Event event) {
    final eventId = event.id;
    if (eventId == null) return;

    final initialMinutes = _activeAlarms[eventId] ?? 0;
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
          if (_activeAlarms.containsKey(eventId))
            TextButton(
              onPressed: () {
                _deleteAlarm(event);
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
              _scheduleAlarm(event, mins);
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
            onPressed: _fetchEvents,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _calendarService.signOut();
              setState(() {
                _events = [];
                _activeAlarms.clear();
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
                    final hasAlarm = eventId != null && _activeAlarms.containsKey(eventId);
                    final alarmMins = hasAlarm ? _activeAlarms[eventId] : null;

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
                              onPressed: () => _showEditModal(event),
                            )
                          : PopupMenuButton<int>(
                              icon: const Icon(Icons.alarm_add),
                              onSelected: (minutes) {
                                if (minutes == -1) {
                                  _showEditModal(event);
                                } else {
                                  _scheduleAlarm(event, minutes);
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
