abstract class Failure implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final Object? error;

  Failure({
    required this.message,
    this.stackTrace,
    this.error,
  });
}
