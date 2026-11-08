import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/shared/constants/asset_constants.dart';

enum SoundEffect { drop, perfect, cutoff, coin, gameOver, button }

class AudioService {
  AudioService(this._storage);
  final StorageService _storage;
  bool _prepared = false;
  bool _musicPlaying = false;
  final Map<SoundEffect, AudioPool> _pools = <SoundEffect, AudioPool>{};
  Future<void>? _preloading;

  void _prepare() {
    if (_prepared) return;
    FlameAudio.audioCache.prefix = AssetConstants.soundsPrefix;
    _prepared = true;
  }

  static String _file(SoundEffect effect) => switch (effect) {
    SoundEffect.drop => AssetConstants.drop,
    SoundEffect.perfect => AssetConstants.perfect,
    SoundEffect.cutoff => AssetConstants.cutoff,
    SoundEffect.coin => AssetConstants.coin,
    SoundEffect.gameOver => AssetConstants.gameOver,
    SoundEffect.button => AssetConstants.button,
  };

  /// Loads every sound once so playing it later has no delay.
  Future<void> preload() {
    return _preloading ??= () async {
      _prepare();
      for (final effect in SoundEffect.values) {
        try {
          _pools[effect] = await FlameAudio.createPool(_file(effect), minPlayers: 1, maxPlayers: 4);
        } catch (_) {
          // File missing: that effect stays silent.
        }
      }
    }();
  }

  Future<void> play(SoundEffect effect) async {
    if (!_storage.soundEnabled) return;
    try {
      await preload();
      final pool = _pools[effect];
      if (pool != null) {
        await pool.start(volume: _storage.volume);
      } else if (effect == SoundEffect.button) {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {}
  }

  Future<void> startMusic() async {
    if (!_storage.soundEnabled || _musicPlaying) return;
    try {
      _prepare();
      await FlameAudio.bgm.initialize();
      await FlameAudio.bgm.play(AssetConstants.music, volume: _storage.volume * 0.5);
      _musicPlaying = true;
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {}
    _musicPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    await _storage.setVolume(volume);
    try {
      await FlameAudio.bgm.audioPlayer.setVolume(volume * 0.5);
    } catch (_) {}
  }
}

final audioServiceProvider = Provider<AudioService>(
  (ref) => AudioService(ref.watch(storageServiceProvider)),
);
