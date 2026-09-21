class ApiEndpoints {
  final String path;
  const ApiEndpoints._(this.path);

  // Static constant instances for fixed endpoints
  static const ApiEndpoints extract = ApiEndpoints._('/api/v1/extract');
  static const ApiEndpoints health = ApiEndpoints._('/health');
  // Factory methods for dynamic paths
  static ApiEndpoints download(String id) =>
      ApiEndpoints._('/api/v1/download/$id');
  static ApiEndpoints status(String id) => ApiEndpoints._('/api/v1/status/$id');

  @override
  String toString() => path;
}
