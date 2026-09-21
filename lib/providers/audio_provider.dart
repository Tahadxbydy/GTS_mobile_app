import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gts/models/errors/app_exception.dart';
import 'package:gts/utill/CP.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gts/models/response/extration_response.dart';
import '../core/constants/endpoints.dart';
import '../core/network/api_helper.dart';
import '../models/base_class/base_notifier.dart';
import '../models/base_class/base_response.dart';
import '../models/request/extraction_request.dart';
import '../services/audio_services.dart';
import '../services/navigation_services.dart';

class AudioProvider extends BaseNotifier {
  final ApiHelper _apiHelper = ApiHelper();

  ExtractionResponse? _extractionData;
  ExtractionResponse? get extractionData => _extractionData;
  bool _extractingData = false;
  bool get extractingData => _extractingData;
  bool _downloadingAudio = false;
  bool get downloadingAudio => _downloadingAudio;

  Future<bool?> extractAudio(String youtubeUrl) async {
    if (_extractingData) return false;
    final response = await runSafely<ExtractionResponse>(
      () => _apiHelper.post<ExtractionResponse>(
        endpoint: ApiEndpoints.extract,
        req: ExtractionRequest(url: youtubeUrl),
        fromJson: (json) => ExtractionResponse.fromJson(json),
      ),
      onError: (error) {
        NavigationService.showError(title: "Error", message: error.message);
      },
      onLoading: () {
        // NavigationService.showLoading();
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

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  File? _savedFile;
  File? get savedFile => _savedFile;

  final AudioDirectoryService _directoryService = AudioDirectoryService();

  /// Downloads the audio stream via http.StreamedResponse and writes it directly to disk
  Future<bool> downloadAudio() async {
    if (_downloadingAudio) return false;
    final title = _extractionData?.title;
    final audioId = _extractionData?.id;

    if (audioId == null || audioId.isEmpty) {
      NavigationService.showError(
        title: "Download Error",
        message: "No valid download ID available.",
      );
      return false;
    }

    final response = await runSafely<bool>(
      () async {
        // 1. Resolve safe target File object in Music folder
        final file = await _directoryService.getTargetAudioFile(
          title ?? 'audio_${DateTime.now().millisecondsSinceEpoch}',
        );

        // 2. Fetch network stream from ApiHelper
        final streamedResponse = await _apiHelper.downloadStream(
          endpoint: ApiEndpoints.download(audioId),
        );

        final contentLength = streamedResponse.contentLength ?? 0;
        int bytesReceived = 0;
        _downloadProgress = 0.0;

        // 3. Write binary stream directly to disk
        final sink = file.openWrite();

        await for (final chunk in streamedResponse.stream) {
          sink.add(chunk);
          bytesReceived += chunk.length;

          if (contentLength > 0) {
            _downloadProgress = bytesReceived / contentLength;
            notifyListeners();
          }
        }

        await sink.flush();
        await sink.close();

        // 4. Trigger system scanner so the file appears in media players
        await _directoryService.scanMediaFile(file.path);

        _savedFile = file;

        return BaseResponse<bool>(
          success: true,
          data: true,
          message: "Saved to Music folder.",
          statusCode: 200,
        );
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
