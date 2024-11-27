import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit {
  @HiveField(0)
  int id; // Tidak lagi late

  @HiveField(1)
  String name;

  @HiveField(2)
  List<DateTime> completedDays;

  Habit({
    required this.id,
    required this.name,
    List<DateTime>? completedDays,
  }) : completedDays = completedDays ?? [];

  // Factory method untuk membuat instance baru dengan ID unik
  factory Habit.create(String name) {
    return Habit(
      id: DateTime.now().hashCode, // Menggunakan hashCode sebagai alternatif
      name: name,
    );
  }
}
