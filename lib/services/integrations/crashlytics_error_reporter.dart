import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'error_reporter.dart';

class CrashlyticsErrorReporter implements ErrorReporter {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  @override
  void reportError(dynamic error, StackTrace? stackTrace, {String? message, Map<String, dynamic>? metadata}) {
    // Attach metadata if available
    metadata?.forEach((key, value) {
      _crashlytics.setCustomKey(key, value.toString());
    });

    // Log custom message if provided
    if (message != null) {
      _crashlytics.log(message);
    }

    // Report the error
    _crashlytics.recordError(error, stackTrace);
  }
}
