import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings {
  @HiveField(0)
  int id; // Tidak lagi late

  @HiveField(1)
  DateTime firstLaunchDate;

  AppSettings({
    required this.id,
    required this.firstLaunchDate,
  });

  // Factory method untuk membuat instance default
  factory AppSettings.createDefault() {
    return AppSettings(
      id: 0, // Atau gunakan ID unik jika diperlukan
      firstLaunchDate: DateTime.now(),
    );
  }
}
