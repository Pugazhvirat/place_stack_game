import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/router.dart';
import 'package:place_stack/app/theme/app_theme.dart';
import 'package:place_stack/core/localization/localization_service.dart';
import 'package:place_stack/shared/constants/app_constants.dart';

class PlaceStackApp extends ConsumerWidget {
  const PlaceStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        LocalizationService.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
