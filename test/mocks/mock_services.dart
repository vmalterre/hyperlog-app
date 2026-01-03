import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:hyperlog/services/api_service.dart';
import 'package:hyperlog/services/auth_service.dart';
import 'package:hyperlog/services/pilot_service.dart';
import 'package:hyperlog/services/error_service.dart';
import 'package:hyperlog/services/integrations/error_reporter.dart';

// HTTP Client mock
class MockHttpClient extends Mock implements http.Client {}

// Mock Response for http package
class MockResponse extends Mock implements http.Response {}

// Service mocks
class MockApiService extends Mock implements ApiService {}
class MockAuthService extends Mock implements AuthService {}
class MockPilotService extends Mock implements PilotService {}

// ErrorReporter mock
class MockErrorReporter extends Mock implements ErrorReporter {}

/// Mock Firebase User for testing
/// Since we can't easily mock Firebase User, we create a simple abstraction
class MockFirebaseUser {
  final String? email;
  final String uid;

  MockFirebaseUser({this.email, this.uid = 'test-uid-123'});
}

/// Create a testable ErrorService with a mock reporter
ErrorService createTestableErrorService(MockErrorReporter mockReporter) {
  return ErrorService.withReporter(mockReporter);
}

/// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(Uri.parse('http://example.com'));
  registerFallbackValue(StackTrace.current);
}
