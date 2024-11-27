import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import 'jadwal_page.dart'; // Ensure you're importing your JadwalPage

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ValueListenableBuilder<Box<Schedule>>(
        valueListenable: Hive.box<Schedule>('schedule').listenable(),
        builder: (context, box, _) {
          final schedules = box.values.toList();

          if (schedules.isEmpty) {
            return const Center(
              child: Text("Tidak ada notifikasi yang terjadwal.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];

              // Format the DateTime to a readable string
              String scheduleTime =
                  DateFormat('yyyy-MM-dd HH:mm').format(schedule.date);

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Colors.blue,
                  ),
                  title: Text(
                    schedule.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('Jadwal: $scheduleTime'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  tileColor: Colors.blue.shade50,
                  onTap: () {
                    // Navigate to JadwalPage and pass the selected schedule's date and the flag
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JadwalPage(
                          selectedDate: schedule.date,
                          isFromNotification: true, // Pass the flag
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
