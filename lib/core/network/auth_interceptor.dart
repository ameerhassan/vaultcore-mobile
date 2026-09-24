import 'package:dio/dio.dart';

abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
}

class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken = 'initial_bearer_token_xyz123';
  String? _refreshToken = 'initial_refresh_token_ref456';

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

/// Enterprise queued interceptor: Prevents multiple concurrent 401 refresh token race conditions
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final Future<String> Function(String refreshToken)? onRefreshToken;

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    this.onRefreshToken,
  });

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Client-Platform'] = 'Flutter-Enterprise';
    options.headers['X-Client-Version'] = '1.0.0';
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final newAccessToken = onRefreshToken != null
              ? await onRefreshToken!(refreshToken)
              : 'refreshed_bearer_token_${DateTime.now().millisecondsSinceEpoch}';

          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );

          // Retry original failed request with renewed authorization header
          final reqOptions = err.requestOptions;
          reqOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedResponse = await dio.fetch(reqOptions);
          return handler.resolve(clonedResponse);
        } catch (_) {
          await tokenStorage.clearTokens();
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
