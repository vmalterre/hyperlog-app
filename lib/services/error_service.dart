import 'integrations/error_reporter.dart';
import 'integrations/crashlytics_error_reporter.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;

  ErrorService._internal() : reporter = CrashlyticsErrorReporter();

  /// Testing constructor that accepts a custom reporter
  ErrorService.withReporter(this.reporter);

  final ErrorReporter reporter;
}

//last_used_abnormal_error = 002

/* example on how to throw an error
 ErrorService().reporter.reportError(
                    Exception("Home Made Error"), 
                    StackTrace.current,
                    message: "This is a custom error reported using the error service",
                    metadata: {"Hello":"World!"}
                  );
*/

