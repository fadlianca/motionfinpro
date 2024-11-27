// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:table_calendar/table_calendar.dart';
import '../models/schedule.dart'; // Ensure this is pointing to your Schedule model
import '../database/schedule_database.dart';
import '../services/notif_service.dart';

class JadwalPage extends StatefulWidget {
  final DateTime selectedDate;
  final bool
      isFromNotification; // Flag to check if it was opened from notification

  const JadwalPage({
    super.key,
    required this.selectedDate,
    this.isFromNotification = false, // Default is false
  });

  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late ScheduleDatabase _scheduleDatabase;
  late NotificationService notificationService;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _scheduleDatabase = ScheduleDatabase();
    notificationService = NotificationService();
    _selectedDate = widget.selectedDate;

    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _scheduleDatabase.openBox();
  }

  Future<void> saveSchedule(String title, DateTime date) async {
    try {
      await _scheduleDatabase.addSchedule(title, date);
      await notificationService.scheduleNotification(title, date);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Schedule saved and notification scheduled!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) {
              return isSameDay(day, _selectedDate);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Schedule>>(
              valueListenable: Hive.box<Schedule>('schedule').listenable(),
              builder: (context, box, _) {
                final schedules = box.values
                    .where((schedule) =>
                        schedule.date.year == _selectedDate.year &&
                        schedule.date.month == _selectedDate.month &&
                        schedule.date.day == _selectedDate.day)
                    .toList();

                return schedules.isEmpty
                    ? const Center(child: Text('Tidak ada jadwal'))
                    : ListView.builder(
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = schedules[index];
                          String scheduleTime = DateFormat('yyyy-MM-dd HH:mm')
                              .format(schedule.date);

                          return ListTile(
                            title: Text(schedule.title),
                            subtitle: Text('Jadwal: $scheduleTime'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _scheduleDatabase
                                    .deleteSchedule(schedule.key!);
                              },
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isFromNotification
          ? null // Hide the floating action button if coming from notification
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _showScheduleForm(context);
              },
            ),
    );
  }

  void _showScheduleForm(BuildContext context) {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Jadwal'),
              ),
              ElevatedButton(
                child: const Text('Simpan Jadwal'),
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await saveSchedule(titleController.text, _selectedDate);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lengkapi semua data')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
