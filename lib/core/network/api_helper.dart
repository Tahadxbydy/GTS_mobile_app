import 'dart:convert';
import 'package:gts/utill/CP.dart';
import 'package:http/http.dart' as http;
import 'package:gts/core/constants/endpoints.dart';
import 'package:gts/models/base_class/base_request.dart';
import 'package:gts/models/base_class/base_response.dart';
import 'package:gts/models/errors/app_exception.dart';

import '../../services/network_services.dart';

class ApiHelper {
  final NetworkService _networkService;

  ApiHelper({NetworkService? networkService})
    : _networkService = networkService ?? NetworkService();

  // static const String baseUrl =
  //     "http://localhost:8080"; // Android Emulator host IP
  static const String baseUrl = "https://gts-backend-si1h.onrender.com";

  Map<String, String> _generateHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// Wraps API requests safely, executing error checks and standard JSON conversions
  Future<BaseResponse<T>> _runSafely<T>(
    Future<http.Response> Function() requestCall,
    T Function(dynamic json)? fromJson,
  ) async {
    try {
      final hasInternetConnection = await _networkService
          .hasInternetConnection();
      if (!hasInternetConnection) {
        throw NoInternetException();
      }
      final response = await requestCall();
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      final baseResponse = BaseResponse<T>.fromJson(decoded, fromJson);

      // Check if backend flagged failure or returned a non-200 level code
      if (!baseResponse.success) {
        throw ApiException(
          baseResponse.message,
          statusCode: baseResponse.statusCode,
        );
      }

      return baseResponse;
    } on ApiException {
      rethrow;
    } catch (e) {
      CP.error(e.toString());
      throw ApiException("Network connection error: ${e.toString()}");
    }
  }

  /// Sends a POST request to the specified endpoint
  Future<BaseResponse<T>> post<T>({
    required ApiEndpoints endpoint,
    required BaseRequest req,
    T Function(dynamic json)? fromJson,
  }) async {
    CP.network("POST API ENDPOINT: ${endpoint.path}");
    CP.network("REQ BODY: ${req.toJson()}");
    return _runSafely<T>(
      () => http.post(
        Uri.parse('$baseUrl${endpoint.path}'),
        headers: _generateHeaders(),
        body: jsonEncode(req.toJson()),
      ),
      fromJson,
    );
  }

  /// Sends a GET request to the specified endpoint
  Future<BaseResponse<T>> get<T>({
    required ApiEndpoints endpoint,
    T Function(dynamic json)? fromJson,
  }) async {
    CP.network("GET API ENDPOINT: ${endpoint.path}");

    return _runSafely<T>(
      () => http.get(
        Uri.parse('$baseUrl${endpoint.path}'),
        headers: _generateHeaders(),
      ),
      fromJson,
    );
  }

  /// Sends a streamed GET request for binary file downloads (e.g., MP3 audio)
  Future<http.StreamedResponse> downloadStream({
    required ApiEndpoints endpoint,
  }) async {
    final hasInternetConnection = await _networkService.hasInternetConnection();
    if (!hasInternetConnection) {
      throw NoInternetException();
    }

    final uri = Uri.parse('$baseUrl$endpoint');

    final request = http.Request('GET', uri);
    CP.network("GET STREAM API ENDPOINT: ${uri.toString()}");
    CP.network("REQ BODY: ${request.toString()}");
    final response = await request.send();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseBody = await response.stream.bytesToString();
      if (responseBody.isNotEmpty) {
        final Map<String, dynamic> errorJson = jsonDecode(responseBody);
        final res = BaseResponse.fromJson(errorJson, (_) {});
        throw ApiException(res.message, statusCode: res.statusCode);
      }
      throw ApiException(
        "Failed to download file from server.",
        statusCode: response.statusCode,
      );
    }

    return response;
  }
}
