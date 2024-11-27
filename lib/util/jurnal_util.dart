import 'package:image_picker/image_picker.dart';

class JournalUtils {
  static Future<String?> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile?.path;
  }

  static bool validateInputs(String title, String content) {
    return title.trim().isNotEmpty && content.trim().isNotEmpty;
  }
}
