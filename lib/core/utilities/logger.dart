import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i(
        '--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}\n'
        'Headers: ${options.headers}\n'
        'QueryParameters: ${options.queryParameters}\n'
        'Body: ${options.data}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
        '<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}\n'
        'Headers: ${response.headers}\n'
        'Data: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
        '❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.path}\n'
        'Error: ${err.message}\n'
        'Response: ${err.response?.data}');
    return super.onError(err, handler);
  }
}
