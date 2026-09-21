class ExtractionResponse {
  final String id;
  final String title;
  final String format;
  final String downloadUrl;
  final String createdAt;

  ExtractionResponse({
    required this.id,
    required this.title,
    required this.format,
    required this.downloadUrl,
    required this.createdAt,
  });

  factory ExtractionResponse.fromJson(Map<String, dynamic> json) {
    return ExtractionResponse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      format: json['format'] ?? 'mp3',
      downloadUrl: json['download_url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
