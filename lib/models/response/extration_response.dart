class ExtractionResponse {
  final String id;
  final String title;
  final String author;
  final int duration;
  final String thumbnailUrl;
  final String downloadUrl;
  final int contentLength;

  ExtractionResponse({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
    required this.downloadUrl,
    required this.contentLength,
  });

  /// Factory to construct from YouTubeExplode objects directly
  factory ExtractionResponse.fromClientStream({
    required String id,
    required String title,
    required String author,
    required int duration,
    required String thumbnailUrl,
    required String downloadUrl,
    required int contentLength,
  }) {
    return ExtractionResponse(
      id: id,
      title: title,
      author: author,
      duration: duration,
      thumbnailUrl: thumbnailUrl,
      downloadUrl: downloadUrl,
      contentLength: contentLength,
    );
  }

  /// Construct from JSON (if ever needed for API response caching)
  factory ExtractionResponse.fromJson(Map<String, dynamic> json) {
    return ExtractionResponse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      duration: json['duration'] ?? 0,
      thumbnailUrl: json['thumbnail_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      contentLength: json['content_length'] ?? 0,
    );
  }

  /// Convert model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
      'download_url': downloadUrl,
      'content_length': contentLength,
    };
  }
}
