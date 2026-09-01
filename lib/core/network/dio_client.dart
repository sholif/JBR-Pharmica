import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'api_interceptor.dart';
import 'network_info.dart';

class DioClient {
  final Dio dio;

  DioClient(Dio baseDio, NetworkInfo networkInfo) : dio = baseDio {
    dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = ApiEndpoints.connectTimeout
      ..options.receiveTimeout = ApiEndpoints.receiveTimeout
      ..interceptors.add(ApiInterceptor(networkInfo));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected network error: $e');
    }
  }
}
