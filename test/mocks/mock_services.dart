import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:hyperlog/services/api_service.dart';
import 'package:hyperlog/services/error_service.dart';
import 'package:hyperlog/services/integrations/error_reporter.dart';

// HTTP Client mock
class MockHttpClient extends Mock implements http.Client {}

// Mock Response for http package
class MockResponse extends Mock implements http.Response {}

// Service mocks
class MockApiService extends Mock implements ApiService {}

// ErrorReporter mock
class MockErrorReporter extends Mock implements ErrorReporter {}

/// Create a testable ErrorService with a mock reporter
ErrorService createTestableErrorService(MockErrorReporter mockReporter) {
  return ErrorService.withReporter(mockReporter);
}

/// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(Uri.parse('http://example.com'));
  registerFallbackValue(StackTrace.current);
}
