import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.error});

  final String message;
  final int? statusCode;
  final dynamic error;

  factory ApiException.fromDio(DioException exception) {
    final responseData = exception.response?.data;

    if (responseData is Map) {
      return ApiException(
        statusCode: exception.response?.statusCode,
        message: responseData['message']?.toString() ?? 'Error de red',
        error: responseData['error'],
      );
    }

    final message = switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'El servidor está tardando en responder (posible arranque en frío). Por favor, presiona Reintentar.',
      DioExceptionType.connectionError =>
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      _ => exception.message ?? 'No se pudo conectar con el servidor',
    };

    return ApiException(
      statusCode: exception.response?.statusCode,
      message: message,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
