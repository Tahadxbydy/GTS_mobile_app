class HealthResponse {
  final String status;
  final String timeStamp;
  final String service;
  final String version;

  HealthResponse({
    required this.status,
    required this.timeStamp,
    required this.service,
    required this.version,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] ?? '',
      timeStamp: json['timestamp'] ?? '',
      service: json['service'] ?? 'mp3',
      version: json['version'] ?? '',
    );
  }
}
