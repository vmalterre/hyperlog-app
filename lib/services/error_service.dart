import 'integrations/ErrorReporter.dart';
import 'integrations/crashlytics_error_reporter.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;

  ErrorService._internal();

  final ErrorReporter reporter = CrashlyticsErrorReporter();
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

