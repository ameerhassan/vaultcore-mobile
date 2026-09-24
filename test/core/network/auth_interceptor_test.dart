import 'package:dio/dio.dart';
import 'package:flutter_enterprise_clean_architecture/core/network/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockTokenStorage extends Mock implements TokenStorage {}
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockDio mockDio;
  late MockTokenStorage mockTokenStorage;
  late AuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockDio = MockDio();
    mockTokenStorage = MockTokenStorage();
    interceptor = AuthInterceptor(
      dio: mockDio,
      tokenStorage: mockTokenStorage,
    );
  });

  test('should append Bearer token and enterprise client headers to outgoing request', () async {
    // Arrange
    const testToken = 'secure_bearer_token_test_123';
    when(() => mockTokenStorage.getAccessToken()).thenAnswer((_) async => testToken);

    final options = RequestOptions(path: '/transactions');
    final handler = MockRequestInterceptorHandler();
    when(() => handler.next(any())).thenReturn(null);

    // Act
    await interceptor.onRequest(options, handler);

    // Assert
    expect(options.headers['Authorization'], 'Bearer $testToken');
    expect(options.headers['X-Client-Platform'], 'Flutter-Enterprise');
    verify(() => handler.next(options)).called(1);
  });
}
