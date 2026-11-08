import 'dart:ui';

import 'package:flutter/foundation.dart';

abstract final class ErrorHandler {
  /// Installs global Flutter + platform error hooks.
  static void install() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      report(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      report(error, stack);
      return true;
    };
  }

  /// Single place to forward errors to a crash reporter later.
  static void report(Object error, StackTrace? stack) {
    debugPrint('[PlaceStack][error] $error');
    if (stack != null && kDebugMode) debugPrint('$stack');
  }
}
