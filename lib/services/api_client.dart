import 'dart:io';

import 'package:dio/dio.dart';

class ApiClient {
  static final Dio instance = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}

String describeDioError(Object error) {
  if (error is SocketException) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  if (error is DioException) {
    final inner = error.error;
    if (inner is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi sedang bermasalah, silakan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        return 'Server mengembalikan kesalahan (${error.response?.statusCode}).';
      case DioExceptionType.unknown:
        return error.message ?? 'Terjadi kesalahan jaringan.';
    }
  }
  return error.toString();
}
