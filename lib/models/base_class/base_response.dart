import 'dart:io';

class BaseResponse<T> {
  final bool success;
  final String message;
  final int statusCode;
  final T? data;

  BaseResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['status_code'] ?? 500,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
