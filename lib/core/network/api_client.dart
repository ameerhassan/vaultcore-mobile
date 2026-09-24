import 'package:dio/dio.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({
    required this.tokenStorage,
    String baseUrl = 'https://api.banking-enterprise.internal/v1',
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStorage: tokenStorage,
      ),
    );
  }
}
