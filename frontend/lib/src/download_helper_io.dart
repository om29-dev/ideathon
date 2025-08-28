import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadBytes(List<int> bytes, String filename) async {
  try {
    // Get the Downloads directory (Android) or Documents directory (iOS)
    Directory? directory;

    if (Platform.isAndroid) {
      // Try to get external storage directory for Android
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    // Fallback to temporary directory
    directory ??= await getTemporaryDirectory();

    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    // For mobile platforms, also trigger the share sheet so users can save it where they want
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Downloaded $filename',
      subject: 'Expense Report',
    );
  } catch (e) {
    // Fallback: create file in temp directory and share
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([XFile(file.path)], text: 'Downloaded $filename');
  }
}
