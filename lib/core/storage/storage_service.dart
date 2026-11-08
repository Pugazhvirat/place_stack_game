import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/shared/constants/app_constants.dart';
import 'package:place_stack/shared/models/skin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._prefs);
  final SharedPreferences _prefs;

  static const _coins = 'coins';
  static const _best = 'best_score';
  static const _skin = 'selected_skin';
  static const _unlocked = 'unlocked_skins';
  static const _sound = 'sound_enabled';
  static const _volume = 'volume';
  static const _haptics = 'haptics_enabled';
  static const _language = 'language';
  static const _adsRemoved = 'ads_removed';
  static const _name = 'player_name';
  static const _games = 'games_played';

  int get coins => _prefs.getInt(_coins) ?? AppConstants.startingCoins;
  Future<void> setCoins(int v) => _prefs.setInt(_coins, v < 0 ? 0 : v);

  int get bestScore => _prefs.getInt(_best) ?? 0;
  Future<void> setBestScore(int v) => _prefs.setInt(_best, v);

  String get selectedSkin => _prefs.getString(_skin) ?? AppConstants.defaultSkinId;
  Future<void> setSelectedSkin(String id) => _prefs.setString(_skin, id);

  Set<String> get unlockedSkins =>
      (_prefs.getStringList(_unlocked) ?? <String>[AppConstants.defaultSkinId]).toSet();

  Future<void> advanceSkin() {
    final i = Skin.all.indexWhere((s) => s.id == selectedSkin);
    final next = Skin.all[(i + 1) % Skin.all.length];
    return setSelectedSkin(next.id);
  }

  Future<void> unlockSkin(String id) =>
      _prefs.setStringList(_unlocked, <String>{...unlockedSkins, id}.toList());

  bool get soundEnabled => _prefs.getBool(_sound) ?? true;
  Future<void> setSoundEnabled(bool v) => _prefs.setBool(_sound, v);

  double get volume => _prefs.getDouble(_volume) ?? AppConstants.defaultVolume;
  Future<void> setVolume(double v) => _prefs.setDouble(_volume, v);

  bool get hapticsEnabled => _prefs.getBool(_haptics) ?? true;
  Future<void> setHapticsEnabled(bool v) => _prefs.setBool(_haptics, v);

  String get languageCode => _prefs.getString(_language) ?? AppConstants.defaultLanguage;
  Future<void> setLanguageCode(String v) => _prefs.setString(_language, v);

  bool get adsRemoved => _prefs.getBool(_adsRemoved) ?? false;
  Future<void> setAdsRemoved(bool v) => _prefs.setBool(_adsRemoved, v);

  String get playerName => _prefs.getString(_name) ?? AppConstants.defaultPlayerName;
  Future<void> setPlayerName(String v) => _prefs.setString(_name, v);

  int get gamesPlayed => _prefs.getInt(_games) ?? 0;
  Future<void> incrementGamesPlayed() => _prefs.setInt(_games, gamesPlayed + 1);
}

/// Overridden in main() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.watch(sharedPreferencesProvider)),
);
