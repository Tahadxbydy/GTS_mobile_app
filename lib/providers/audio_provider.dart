import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/base_class/base_notifier.dart';
import '../models/base_class/base_response.dart';
import '../models/response/extration_response.dart';
import '../services/audio_services.dart';
import '../services/navigation_services.dart';

class AudioProvider extends BaseNotifier {
  ExtractionResponse? _extractionData;
  ExtractionResponse? get extractionData => _extractionData;

  bool _extractingData = false;
  bool get extractingData => _extractingData;

  bool _downloadingAudio = false;
  bool get downloadingAudio => _downloadingAudio;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  File? _savedFile;
  File? get savedFile => _savedFile;
  void clear() {
    _extractingData = false;

    _downloadProgress = 0.0;
    _downloadingAudio = false;
    _extractionData = null;
    _savedFile = null;
  }

  final AudioDirectoryService _directoryService = AudioDirectoryService();

  /// Extracts audio stream metadata directly on the client using YoutubeExplode
  Future<bool?> extractAudio(String youtubeUrl) async {
    if (_extractingData) return false;

    final response = await runSafely<ExtractionResponse>(
      () async {
        final yt = YoutubeExplode();

        try {
          // 1. Fetch metadata directly from device IP
          final video = await yt.videos.get(youtubeUrl);

          // 2. Fetch manifest & select highest bitrate audio stream
          final manifest = await yt.videos.streamsClient.getManifest(video.id);
          final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

          // 3. Construct ExtractionResponse locally
          final data = ExtractionResponse(
            id: video.id.value,
            title: video.title,
            author: video.author,
            duration: video.duration?.inSeconds ?? 0,
            thumbnailUrl: video.thumbnails.highResUrl,
            downloadUrl: audioStreamInfo.url.toString(),
            contentLength: audioStreamInfo.size.totalBytes,
          );

          return BaseResponse<ExtractionResponse>(
            success: true,
            data: data,
            message: "Stream extracted locally.",
            statusCode: 200,
          );
        } finally {
          yt.close(); // Clean up client connection
        }
      },
      onError: (error) {
        NavigationService.showError(
          title: "Extraction Failed",
          message: error.message,
        );
      },
      onLoading: () {
        _extractingData = true;
      },
      onComplete: () {
        _extractingData = false;
      },
      notify: true,
    );

    if (response?.success ?? false) {
      _extractionData = response?.data;
      return true;
    }

    return false;
  }

  /// Downloads the audio stream directly from YouTube CDN and tracks live progress
  Future<bool> downloadAudio() async {
    if (_downloadingAudio) return false;

    final title = _extractionData?.title;
    final videoId = _extractionData?.id;

    if (videoId == null || videoId.isEmpty) {
      NavigationService.showError(
        title: "Download Error",
        message: "No valid video metadata available.",
      );
      return false;
    }

    final response = await runSafely<bool>(
      () async {
        final yt = YoutubeExplode();
        final httpClient = http.Client();

        try {
          // 1. Get manifest to resolve direct CDN URL & actual container extension
          final manifest = await yt.videos.streamsClient.getManifest(videoId);
          final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

          // Normalize extension (e.g. mp4a -> m4a)
          var containerExt = audioStreamInfo.container.name.toLowerCase();
          if (containerExt == 'mp4a' || containerExt == 'mp4') {
            containerExt = 'm4a';
          }

          // Close YoutubeExplode instance before initiating binary stream fetch
          yt.close();

          // 2. Resolve safe target File path in local storage with true extension
          final file = await _directoryService.getTargetAudioFile(
            title ?? 'audio_${DateTime.now().millisecondsSinceEpoch}',
            extension: containerExt,
          );

          // 3. Initiate direct HTTP GET stream to YouTube's CDN
          final request = http.Request('GET', audioStreamInfo.url);
          final streamedResponse = await httpClient.send(request);

          final totalBytes =
              streamedResponse.contentLength ?? audioStreamInfo.size.totalBytes;
          int bytesReceived = 0;
          _downloadProgress = 0.0;

          // 4. Write stream chunks directly to disk and emit live progress updates
          final sink = file.openWrite();

          await for (final chunk in streamedResponse.stream) {
            sink.add(chunk);
            bytesReceived += chunk.length;

            if (totalBytes > 0) {
              _downloadProgress = bytesReceived / totalBytes;
              notifyListeners();
            }
          }

          await sink.flush();
          await sink.close();

          // 5. Trigger Android MediaScanner so local players detect the track
          await _directoryService.scanMediaFile(file.path);

          _savedFile = file;

          return BaseResponse<bool>(
            success: true,
            data: true,
            message: "Saved to Music folder.",
            statusCode: 200,
          );
        } finally {
          yt.close();
          httpClient.close();
        }
      },
      onError: (error) {
        NavigationService.showError(
          title: "Download Failed",
          message: error.message,
        );
      },
      onLoading: () {
        _downloadingAudio = true;
      },
      onSuccess: (message) {
        NavigationService.showMessage(title: "Success", message: message);
      },
      onComplete: () {
        _downloadingAudio = false;
      },
      notify: true,
    );

    return response?.success ?? false;
  }
}
