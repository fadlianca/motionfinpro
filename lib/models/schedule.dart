import 'package:hive/hive.dart';

part 'schedule.g.dart'; // This will generate the adapter

@HiveType(typeId: 0) // Make sure the typeId is unique
class Schedule extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime date;

  Schedule({required this.title, required this.date});
}
