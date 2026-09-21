abstract class BaseRequest {
  const BaseRequest();

  /// Converts request model instance to JSON map for API payloads
  Map<String, dynamic> toJson();
}
