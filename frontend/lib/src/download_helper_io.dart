import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadBytes(List<int> bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);

  // Use share sheet so users can save/open the file on mobile
  try {
    await Share.shareXFiles([XFile(file.path)], text: 'Downloaded $filename');
  } catch (e) {
    // Fallback: do nothing if sharing fails
  }
}
