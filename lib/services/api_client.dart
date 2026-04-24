import 'package:dio/dio.dart';

class ApiClient {
  static final Dio instance = Dio(
    BaseOptions(
      validateStatus: (_) => true,
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
