import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'network_exceptions.dart';
import 'network_info.dart';

class ApiInterceptor extends Interceptor {
  final NetworkInfo networkInfo;

  ApiInterceptor(this.networkInfo);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NoInternetException(),
        ),
      );
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    if (kDebugMode) {
      debugPrint('[Dio Request] ${options.method} -> ${options.uri}');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[Dio Response] ${response.statusCode} <- ${response.requestOptions.uri}');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[Dio Error] ${err.type} -> ${err.message}');
    }
    final customException = NetworkExceptionMapper.fromDioError(err);
    final modifiedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: customException,
    );
    return super.onError(modifiedError, handler);
  }
}
