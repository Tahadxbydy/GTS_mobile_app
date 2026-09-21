import '../base_class/base_request.dart';

class ExtractionRequest extends BaseRequest {
  final String url;
  final String? format;

  ExtractionRequest({required this.url, this.format});

  @override
  Map<String, dynamic> toJson() {
    return {'url': url, 'format': format};
  }
}
