import 'package:hive/hive.dart';
import '../models/schedule.dart';

class ScheduleDatabase {
  late Box<Schedule> _scheduleBox;

  // Opening the Hive box when the app starts
  Future<void> openBox() async {
    _scheduleBox = await Hive.openBox<Schedule>('schedule');
  }

  // Add a schedule to the database
  Future<void> addSchedule(String title, DateTime date) async {
    final schedule = Schedule(title: title, date: date);
    await _scheduleBox.add(schedule);
  }

  // Fetch all schedules
  List<Schedule> getSchedules() {
    return _scheduleBox.values.toList();
  }

  // Delete a schedule
  Future<void> deleteSchedule(int key) async {
    await _scheduleBox.delete(key);
  }
}
