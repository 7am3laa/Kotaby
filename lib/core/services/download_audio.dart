import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AudioDownloader {
  static Dio dio = Dio();

  static Future<String?> getLocalPath(String fileName, String reciterId) async {
    try {
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        print("❌ لم يتم العثور على مجلد التخزين الخارجي");
        return null;
      }

      String folderPath =
          '${dir.path}/downloads/$reciterId'; // حفظ في Downloads
      String filePath = '$folderPath/$fileName';

      if (await File(filePath).exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      print("❌ خطأ أثناء التحقق من الملف: $e");
      return null;
    }
  }

  static Future<String?> downloadAudio(
      String url, String fileName, String reciterId) async {
    try {
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        print("❌ لم يتم العثور على مجلد التخزين الخارجي");
        return null;
      }

      String folderPath = '${dir.path}/downloads/$reciterId';
      await Directory(folderPath).create(recursive: true);

      String filePath = '$folderPath/$fileName';

      File file = File(filePath);
      if (await file.exists()) {
        print("⚡ الصوت موجود بالفعل: $filePath");
        return filePath;
      }

      print("🔄 تحميل الصوت...");
      await dio.download(url, filePath);
      print("✅ تم تنزيل الصوت إلى: $filePath");

      return filePath;
    } catch (e) {
      print("❌ خطأ أثناء تحميل الملف: $e");
      return null;
    }
  }
}
