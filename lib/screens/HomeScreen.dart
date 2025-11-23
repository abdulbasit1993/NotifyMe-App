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

  Future<void> _loadReminders() async {
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

  Future<void> _deleteReminder(Reminder reminder) async {
    await NotificationService().cancelNotification(reminder.notificationId);

    await DatabaseService().deleteReminder(reminder.id);

    _loadReminders();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: const Text('Reminder deleted'),
        backgroundColor: Colors.red,
      ),
    );
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
      body: RefreshIndicator(
        onRefresh: _loadReminders,
        child: FutureBuilder(future: _remindersFuture, builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
        
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading reminders: ${snapshot.error}'),
            );
          }
        
          final reminders = snapshot.data ?? [];
        
          reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400]
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No reminders yet!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600]
                    ),
                  ),
                   const SizedBox(height: 10),
                   Text(
                    'Tap + to add your first reminder.',
                    style: TextStyle(
                      color: Colors.grey[500]
                    ),
                   ),
                ],
              ),
            );
          }
        
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final isPast = reminder.dateTime.isBefore(DateTime.now());
        
              return Dismissible(key: Key(reminder.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
              ),
               onDismissed: (_) => _deleteReminder(reminder),
               child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isPast ? Colors.grey : primaryColor,
                    child: Icon(
                      isPast ? Icons.check : Icons.notifications_active,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      decoration: isPast ? TextDecoration.lineThrough : null,
                      color: isPast ? Colors.grey[600] : null,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateTime(reminder.dateTime),
                          style: TextStyle(
                            color: isPast ? Colors.grey[500] : Colors.black87,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                    trailing: isPast 
                    ? const Icon(Icons.done, color: Colors.green)
                    : null,
                  ),
                 ),
                );
              },
            );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
          _loadReminders();
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
