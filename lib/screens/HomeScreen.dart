import 'package:flutter/material.dart';
import 'package:notify_me/constants/colors.dart';
import 'package:notify_me/models/reminder.dart';
import 'package:notify_me/screens/AddReminderScreen.dart';
import 'package:intl/intl.dart';
import 'package:notify_me/services/database_service.dart';
import 'package:notify_me/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Reminder>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _remindersFuture = DatabaseService().getReminders();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayLabel;
    if (target == today) {
      dayLabel = 'Today';
    } else if (target == tomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = DateFormat('d MMM').format(dateTime);
    }

    final time = DateFormat('h:mm a').format(dateTime);
    return '$dayLabel at $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: const Center(child: Text('Welcome to NotifyMe!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
