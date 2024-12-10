import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CacheService {
  static const String _cacheDir = 'resource_cache';

  Future<String> getCachedFilePath(String url, String filename) async {
    final directory = await _getCacheDirectory();
    return '${directory.path}/$filename';
  }

  Future<File> cacheFile(String url, String filename) async {
    final directory = await _getCacheDirectory();
    final file = File('${directory.path}/$filename');

    if (await file.exists()) {
      return file;
    }

    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  Future<void> clearCache() async {
    final directory = await _getCacheDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
