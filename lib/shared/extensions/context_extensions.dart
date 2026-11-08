import 'package:flutter/widgets.dart';
import 'package:place_stack/core/localization/localization_service.dart';

extension ContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);

  /// Responsive scale factor relative to a 390dp wide phone.
  double get uiScale => (screenSize.width / 390).clamp(0.85, 1.3).toDouble();

  double sp(double value) => value * uiScale;

  String tr(String key, {Map<String, Object>? args}) =>
      AppLocalizations.of(this).tr(key, args: args);
}
