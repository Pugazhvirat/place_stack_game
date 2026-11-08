import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/core/storage/storage_service.dart';

class HapticService {
  HapticService(this._storage);
  final StorageService _storage;

  Future<void> _run(Future<void> Function() fn) async {
    if (!_storage.hapticsEnabled) return;
    try {
      await fn();
    } catch (_) {}
  }

  Future<void> placement() => _run(HapticFeedback.lightImpact);
  Future<void> perfect() => _run(HapticFeedback.mediumImpact);
  Future<void> gameOver() => _run(HapticFeedback.heavyImpact);
  Future<void> button() => _run(HapticFeedback.selectionClick);
}

final hapticServiceProvider = Provider<HapticService>(
  (ref) => HapticService(ref.watch(storageServiceProvider)),
);
