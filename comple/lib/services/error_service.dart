import 'package:flutter/foundation.dart';

void logError(Object error, StackTrace? stackTrace) {
  try {
    // Replace with Crashlytics/Sentry/etc. as needed.
    if (kDebugMode) {
      debugPrint('ERROR: $error');
      if (stackTrace != null) debugPrint('STACK: $stackTrace');
    } else {
      // In release, still print minimally so logs can be gathered if needed.
      debugPrint('ERROR: $error');
    }
  } catch (_) {
    // Swallow any errors from the logger itself.
  }
}
