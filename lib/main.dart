import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/app.dart';
import 'package:place_stack/core/ads/ad_service.dart';
import 'package:place_stack/core/error/error_handler.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/game/rendering/block_renderer.dart';
import 'package:place_stack/shared/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.install();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  BlockRenderer();
  await BlockRenderer.preloadTextures();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  unawaited(container.read(adServiceProvider).initialize());
  await container.read(storageServiceProvider).setSelectedSkin(AppConstants.defaultSkinId);

  runApp(UncontrolledProviderScope(container: container, child: const PlaceStackApp()));
}
