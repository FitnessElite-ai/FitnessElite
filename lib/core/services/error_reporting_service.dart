import 'package:flutter/foundation.dart';

/// Abstract ErrorReportingService capturing application exceptions safely without exposing sensitive biometrics.
abstract class ErrorReportingService {
  void recordError(dynamic error, StackTrace? stackTrace, {String? reason});
}

class LocalErrorReportingService implements ErrorReportingService {
  @override
  void recordError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    final msg = reason != null ? ' Reason: $reason' : '';
    debugPrint('[ErrorReporting] Error captured:$msg Error: $error');
  }
}
