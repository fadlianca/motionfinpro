import 'package:hive/hive.dart';

part 'jurnal.g.dart'; // Generated file for Hive code generation

@HiveType(typeId: 2)
class Journal extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  late final String title;

  @HiveField(2)
  late String content;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  String? imagePath; // Changed from final to var so it can be updated

  @override
  @HiveField(5)
  int? key;

  Journal({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imagePath,
  });

  factory Journal.create(String title, String content, {String? imagePath}) {
    return Journal(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
      content: content.trim(),
      date: DateTime.now(),
      imagePath: imagePath,
    );
  }

  Journal copyWith({
    String? title,
    String? content,
    DateTime? date,
    String? imagePath,
  }) {
    return Journal(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
