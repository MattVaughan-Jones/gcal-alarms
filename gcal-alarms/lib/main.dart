import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MeetingGuardPOC());
}

class MeetingGuardPOC extends StatelessWidget {
  const MeetingGuardPOC({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Guard POC',
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

  Future<void> _scheduleTestAlarm() async {
    try {
      await platform.invokeMethod('scheduleAlarm', {"seconds": 10});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm scheduled for 10 seconds from now')),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule alarm: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Guard POC')),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleTestAlarm,
          child: const Text('Trigger Test Alarm (10s)'),
        ),
      ),
    );
  }
}
