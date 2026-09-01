import 'package:dio/dio.dart';

abstract class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NoInternetException extends NetworkException {
  const NoInternetException([super.message = 'No internet connection available. Please check your network setting.']);
}

class ServerException extends NetworkException {
  const ServerException(super.message, {super.statusCode});
}

class TimeoutException extends NetworkException {
  const TimeoutException([super.message = 'Connection timeout with remote server. Please try again.']);
}

class InvalidDataException extends NetworkException {
  const InvalidDataException([super.message = 'Invalid API response format received from server.']);
}

class NetworkExceptionMapper {
  static NetworkException fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final statusMessage = dioException.response?.statusMessage;
        return ServerException(
          'Server Error ($statusCode): ${statusMessage ?? "Unexpected response"}',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const ServerException('Request to server was cancelled.');
      case DioExceptionType.connectionError:
        return const NoInternetException();
      case DioExceptionType.unknown:
        if (dioException.error != null &&
            dioException.error.toString().contains('SocketException')) {
          return const NoInternetException();
        }
        return ServerException(dioException.message ?? 'An unknown network error occurred.');
      default:
        return ServerException(dioException.message ?? 'Unexpected network error.');
    }
  }
}
