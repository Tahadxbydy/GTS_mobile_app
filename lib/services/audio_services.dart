import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioDirectoryService {
  static const MethodChannel _mediaScannerChannel = MethodChannel(
    'com.example.gts/media_scanner',
  );

  /// Requests storage/media permissions based on OS platform and version
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Handles Android 13+ (API 33+) granular media permission
      final audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;

      if (await Permission.audio.request().isGranted) {
        return true;
      }

      // Fallback for Android 12 and below
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;

      return (await Permission.storage.request()).isGranted;
    } else if (Platform.isIOS) {
      return true; // iOS uses app documents directory by default
    }

    return false;
  }

  /// Resolves the target directory for audio files
  /// Returns `/storage/emulated/0/Music` on Android, or Documents directory on iOS
  Future<Directory> getMusicDirectory() async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      throw Exception("Storage permission was denied.");
    }

    if (Platform.isAndroid) {
      // Primary target: Public Android Music directory
      final musicDir = Directory('/storage/emulated/0/Music');

      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      return musicDir;
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }

    // Default fallback
    final fallbackDir = await getApplicationDocumentsDirectory();
    return fallbackDir;
  }

  /// Sanitizes track titles to prevent invalid file path characters
  String sanitizeFileName(String title) {
    if (title.trim().isEmpty) {
      return 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
    }

    // Replace illegal filesystem characters (\ / : * ? " < > |) with underscores
    final cleaned = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.endsWith('.mp3') ? cleaned : '$cleaned.mp3';
  }

  /// Resolves a full, safe File object inside the Music directory
  Future<File> getTargetAudioFile(String rawTitle) async {
    final directory = await getMusicDirectory();
    final fileName = sanitizeFileName(rawTitle);
    return File('${directory.path}/$fileName');
  }

  /// Triggers Android's MediaScanner so downloaded tracks appear instantly in local music players
  Future<void> scanMediaFile(String filePath) async {
    if (!Platform.isAndroid) return;

    try {
      await _mediaScannerChannel.invokeMethod('scanFile', {'path': filePath});
    } on PlatformException catch (_) {
      // Ignores platform channel errors if native Android side is not registered
    }
  }
}
