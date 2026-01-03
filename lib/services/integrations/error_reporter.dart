
abstract class ErrorReporter {
  void reportError(
    dynamic error, 
    StackTrace? stackTrace, 
    {String? message, Map<String, dynamic>? metadata}
  );
}