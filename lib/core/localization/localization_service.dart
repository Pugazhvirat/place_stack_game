import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/core/storage/storage_service.dart';

abstract final class LocalizationService {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ko'),
    Locale('ja'),
    Locale('zh', 'TW'),
    Locale('zh', 'CN'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'pt': 'Português',
    'ko': '한국어',
    'ja': '日本語',
    'zh_TW': '中文繁體',
    'zh_CN': '中文简体',
  };

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> strings = {
    'en': {
      'tap_to_play': 'Tap to Play',
      'shop': 'Shop',
      'skin': 'Skin',
      'skins': 'Skins',
      'home': 'Home',
      'ranking': 'Ranking',
      'how_to_play': 'How to Play',
      'settings': 'Settings',
      'profile': 'Profile',
      'vibrate': 'Vibrate',
      'language': 'Language',
      'volume': 'Volume',
      'rate_us': 'Rate Us',
      'privacy_policy': 'Privacy Policy',
      'mail': 'Mail',
      'link_copied': 'Link copied to clipboard',
      'game_over': 'Game Over',
      'watch_video_continue': 'Watch a short video to continue!',
      'continue_q': 'Continue?',
      'your_score': 'Your Score',
      'best': 'Best',
      'continue_here': 'Continue here',
      'watch_ad_keep_playing': 'Watch Ad to keep playing',
      'use_coins': 'Use {n} Coins',
      'play_again': 'Play Again',
      'paused': 'Paused',
      'resume': 'Resume',
      'perfect': 'Perfect',
      'watch_ad': 'Watch Ad',
      'ad_not_ready': 'Ad not ready yet. Try again in a moment.',
      'not_enough_coins': 'Not enough coins',
      'coins_n': '{n} Coins',
      'get_n_coins': 'Get {n} coins',
      'remove_ads': 'Remove Ads',
      'remove_ads_sub': 'Enjoy ad-free experience forever!',
      'restore_purchases': 'Restore purchases',
      'purchase_unavailable': 'Purchases are not available right now.',
      'global': 'Global',
      'friends': 'Friends',
      'you': 'You',
      'default': 'Default',
      'player_name': 'Player name',
      'save': 'Save',
      'saved': 'Saved',
      'games_played': 'Games played',
      'coins': 'Coins',
      'htp_1_title': '1. Tap to Drop',
      'htp_1_body': 'A block slides left and right. Tap anywhere to drop it onto the stack.',
      'htp_2_title': '2. Stack Precisely',
      'htp_2_body': 'Only the part that overlaps the block below stays. The rest falls away.',
      'htp_3_title': '3. Go Perfect',
      'htp_3_body': 'Land exactly on top to keep the full width and earn bonus points and coins.',
      'htp_4_title': "4. Don't Miss",
      'htp_4_body': 'If a block misses the stack completely, the game ends. Beat your best score!',
    },

    'es': {
      'tap_to_play': 'Toca para jugar',
      'shop': 'Tienda',
      'skin': 'Aspecto',
      'skins': 'Aspectos',
      'home': 'Inicio',
      'ranking': 'Clasificación',
      'how_to_play': 'Cómo jugar',
      'settings': 'Ajustes',
      'profile': 'Perfil',
      'vibrate': 'Vibración',
      'language': 'Idioma',
      'volume': 'Volumen',
      'rate_us': 'Califícanos',
      'privacy_policy': 'Privacidad',
      'mail': 'Correo',
      'link_copied': 'Enlace copiado',
      'game_over': 'Fin del juego',
      'your_score': 'Tu puntuación',
      'best': 'Mejor',
      'continue_here': 'Continuar aquí',
      'watch_ad_keep_playing': 'Mira un anuncio para continuar',
      'use_coins': 'Usar {n} monedas',
      'play_again': 'Jugar de nuevo',
      'paused': 'En pausa',
      'resume': 'Reanudar',
      'perfect': 'Perfecto',
      'watch_ad': 'Ver anuncio',
      'ad_not_ready': 'El anuncio aún no está listo. Inténtalo de nuevo.',
      'not_enough_coins': 'No tienes suficientes monedas',
      'coins_n': '{n} monedas',
      'get_n_coins': 'Obtener {n} monedas',
      'remove_ads': 'Quitar anuncios',
      'remove_ads_sub': '¡Disfruta de una experiencia sin anuncios!',
      'restore_purchases': 'Restaurar compras',
      'purchase_unavailable': 'Las compras no están disponibles ahora.',
      'global': 'Global',
      'friends': 'Amigos',
      'you': 'Tú',
      'default': 'Predeterminado',
      'player_name': 'Nombre del jugador',
      'save': 'Guardar',
      'saved': 'Guardado',
      'games_played': 'Partidas jugadas',
      'coins': 'Monedas',
      'htp_1_title': '1. Toca para soltar',
      'htp_1_body': 'Toca para soltar el bloque sobre la pila.',
      'htp_2_title': '2. Apila con precisión',
      'htp_2_body': 'Solo permanece la parte que coincide con el bloque inferior.',
      'htp_3_title': '3. Acierta perfectamente',
      'htp_3_body': 'Acierta para conservar el ancho y ganar puntos extra.',
      'htp_4_title': '4. No falles',
      'htp_4_body': 'Si fallas la pila, la partida termina. ¡Supera tu récord!',
    },

    'fr': {
      'tap_to_play': 'Appuyez pour jouer',
      'shop': 'Boutique',
      'skin': 'Apparence',
      'skins': 'Apparences',
      'home': 'Accueil',
      'ranking': 'Classement',
      'how_to_play': 'Comment jouer',
      'settings': 'Paramètres',
      'profile': 'Profil',
      'vibrate': 'Vibration',
      'language': 'Langue',
      'volume': 'Volume',
      'rate_us': 'Notez-nous',
      'privacy_policy': 'Confidentialité',
      'mail': 'E-mail',
      'link_copied': 'Lien copié',
      'game_over': 'Fin de partie',
      'your_score': 'Votre score',
      'best': 'Record',
      'continue_here': 'Continuer ici',
      'watch_ad_keep_playing': 'Regardez une publicité pour continuer',
      'use_coins': 'Utiliser {n} pièces',
      'play_again': 'Rejouer',
      'paused': 'En pause',
      'resume': 'Reprendre',
      'perfect': 'Parfait',
      'watch_ad': 'Regarder une publicité',
      'ad_not_ready': 'Publicité indisponible. Réessayez.',
      'not_enough_coins': 'Pas assez de pièces',
      'coins_n': '{n} pièces',
      'get_n_coins': 'Obtenir {n} pièces',
      'remove_ads': 'Supprimer les publicités',
      'remove_ads_sub': 'Profitez d’une expérience sans publicité !',
      'restore_purchases': 'Restaurer les achats',
      'purchase_unavailable': 'Achats indisponibles pour le moment.',
      'global': 'Mondial',
      'friends': 'Amis',
      'you': 'Vous',
      'default': 'Par défaut',
      'player_name': 'Nom du joueur',
      'save': 'Enregistrer',
      'saved': 'Enregistré',
      'games_played': 'Parties jouées',
      'coins': 'Pièces',
      'htp_1_title': '1. Appuyez pour lâcher',
      'htp_1_body': 'Appuyez pour déposer le bloc sur la pile.',
      'htp_2_title': '2. Empilez avec précision',
      'htp_2_body': 'Seule la partie qui chevauche le bloc inférieur reste.',
      'htp_3_title': '3. Visez la perfection',
      'htp_3_body': 'Conservez toute la largeur et gagnez des bonus.',
      'htp_4_title': '4. Ne ratez pas',
      'htp_4_body': 'Si le bloc manque la pile, la partie se termine.',
    },

    'pt': {
      'tap_to_play': 'Toque para jogar',
      'shop': 'Loja',
      'skin': 'Visual',
      'skins': 'Visuais',
      'home': 'Início',
      'ranking': 'Classificação',
      'how_to_play': 'Como jogar',
      'settings': 'Configurações',
      'profile': 'Perfil',
      'vibrate': 'Vibração',
      'language': 'Idioma',
      'volume': 'Volume',
      'rate_us': 'Avalie-nos',
      'privacy_policy': 'Privacidade',
      'mail': 'E-mail',
      'link_copied': 'Link copiado',
      'game_over': 'Fim de jogo',
      'your_score': 'Sua pontuação',
      'best': 'Recorde',
      'continue_here': 'Continuar aqui',
      'watch_ad_keep_playing': 'Assista a um anúncio para continuar',
      'use_coins': 'Usar {n} moedas',
      'play_again': 'Jogar novamente',
      'paused': 'Pausado',
      'resume': 'Continuar',
      'perfect': 'Perfeito',
      'watch_ad': 'Assistir anúncio',
      'ad_not_ready': 'Anúncio indisponível. Tente novamente.',
      'not_enough_coins': 'Moedas insuficientes',
      'coins_n': '{n} moedas',
      'get_n_coins': 'Obter {n} moedas',
      'remove_ads': 'Remover anúncios',
      'remove_ads_sub': 'Aproveite sem anúncios!',
      'restore_purchases': 'Restaurar compras',
      'purchase_unavailable': 'Compras indisponíveis no momento.',
      'global': 'Global',
      'friends': 'Amigos',
      'you': 'Você',
      'default': 'Padrão',
      'player_name': 'Nome do jogador',
      'save': 'Salvar',
      'saved': 'Salvo',
      'games_played': 'Partidas jogadas',
      'coins': 'Moedas',
      'htp_1_title': '1. Toque para soltar',
      'htp_1_body': 'Toque para soltar o bloco na pilha.',
      'htp_2_title': '2. Empilhe com precisão',
      'htp_2_body': 'Apenas a parte sobreposta permanece.',
      'htp_3_title': '3. Acerte perfeitamente',
      'htp_3_body': 'Mantenha a largura e ganhe pontos extras.',
      'htp_4_title': '4. Não erre',
      'htp_4_body': 'Se errar a pilha, o jogo termina. Supere seu recorde!',
    },

    'ko': {
      'tap_to_play': '탭하여 플레이',
      'shop': '상점',
      'skin': '스킨',
      'skins': '스킨',
      'home': '홈',
      'ranking': '랭킹',
      'how_to_play': '게임 방법',
      'settings': '설정',
      'profile': '프로필',
      'vibrate': '진동',
      'language': '언어',
      'volume': '볼륨',
      'rate_us': '평가하기',
      'privacy_policy': '개인정보 처리방침',
      'mail': '메일',
      'link_copied': '링크가 복사되었습니다',
      'game_over': '게임 오버',
      'your_score': '점수',
      'best': '최고 기록',
      'continue_here': '여기서 계속하기',
      'watch_ad_keep_playing': '광고를 보고 계속하기',
      'use_coins': '코인 {n}개 사용',
      'play_again': '다시 플레이',
      'paused': '일시 정지',
      'resume': '계속하기',
      'perfect': '완벽해요',
      'watch_ad': '광고 보기',
      'ad_not_ready': '광고가 아직 준비되지 않았습니다.',
      'not_enough_coins': '코인이 부족합니다',
      'coins_n': '코인 {n}개',
      'get_n_coins': '코인 {n}개 받기',
      'remove_ads': '광고 제거',
      'remove_ads_sub': '광고 없이 즐기세요!',
      'restore_purchases': '구매 복원',
      'purchase_unavailable': '현재 구매할 수 없습니다.',
      'global': '전체',
      'friends': '친구',
      'you': '나',
      'default': '기본값',
      'player_name': '플레이어 이름',
      'save': '저장',
      'saved': '저장됨',
      'games_played': '플레이한 게임',
      'coins': '코인',
      'htp_1_title': '1. 탭하여 떨어뜨리기',
      'htp_1_body': '탭하여 블록을 아래에 쌓으세요.',
      'htp_2_title': '2. 정확하게 쌓기',
      'htp_2_body': '겹치는 부분만 남고 나머지는 떨어집니다.',
      'htp_3_title': '3. 완벽하게 맞추기',
      'htp_3_body': '정확히 맞추면 보너스 점수를 얻습니다.',
      'htp_4_title': '4. 놓치지 마세요',
      'htp_4_body': '블록을 놓치면 게임이 끝납니다.',
    },

    'ja': {
      'tap_to_play': 'タップしてプレイ',
      'shop': 'ショップ',
      'skin': 'スキン',
      'skins': 'スキン',
      'home': 'ホーム',
      'ranking': 'ランキング',
      'how_to_play': '遊び方',
      'settings': '設定',
      'profile': 'プロフィール',
      'vibrate': '振動',
      'language': '言語',
      'volume': '音量',
      'rate_us': '評価する',
      'privacy_policy': 'プライバシーポリシー',
      'mail': 'メール',
      'link_copied': 'リンクをコピーしました',
      'game_over': 'ゲームオーバー',
      'your_score': 'スコア',
      'best': 'ベスト',
      'continue_here': 'ここから続ける',
      'watch_ad_keep_playing': '広告を見て続ける',
      'use_coins': '{n} 枚のコインを使う',
      'play_again': 'もう一度プレイ',
      'paused': '一時停止中',
      'resume': '再開',
      'perfect': 'パーフェクト',
      'watch_ad': '広告を見る',
      'ad_not_ready': '広告を準備できません。後でもう一度お試しください。',
      'not_enough_coins': 'コインが足りません',
      'coins_n': '{n} 枚のコイン',
      'get_n_coins': '{n} 枚のコインを獲得',
      'remove_ads': '広告を削除',
      'remove_ads_sub': '広告なしで楽しもう！',
      'restore_purchases': '購入を復元',
      'purchase_unavailable': '現在購入できません。',
      'global': '世界',
      'friends': 'フレンド',
      'you': 'あなた',
      'default': 'デフォルト',
      'player_name': 'プレイヤー名',
      'save': '保存',
      'saved': '保存しました',
      'games_played': 'プレイ回数',
      'coins': 'コイン',
      'htp_1_title': '1. タップして落とす',
      'htp_1_body': 'タップしてブロックを積み重ねましょう。',
      'htp_2_title': '2. 正確に積み重ねる',
      'htp_2_body': '重なった部分だけが残ります。',
      'htp_3_title': '3. 完璧に合わせる',
      'htp_3_body': '正確に置いてボーナスポイントを獲得しましょう。',
      'htp_4_title': '4. 外さないで',
      'htp_4_body': 'ブロックを外すとゲーム終了です。',
    },

    'zh_TW': {
      'tap_to_play': '點擊開始遊戲',
      'shop': '商店',
      'skin': '造型',
      'skins': '造型',
      'home': '首頁',
      'ranking': '排行榜',
      'how_to_play': '遊戲玩法',
      'settings': '設定',
      'profile': '個人資料',
      'vibrate': '震動',
      'language': '語言',
      'volume': '音量',
      'rate_us': '為我們評分',
      'privacy_policy': '隱私權政策',
      'mail': '郵件',
      'link_copied': '連結已複製',
      'game_over': '遊戲結束',
      'your_score': '你的分數',
      'best': '最高分',
      'continue_here': '從這裡繼續',
      'watch_ad_keep_playing': '觀看廣告以繼續遊戲',
      'use_coins': '使用 {n} 枚金幣',
      'play_again': '再玩一次',
      'paused': '已暫停',
      'resume': '繼續',
      'perfect': '完美',
      'watch_ad': '觀看廣告',
      'ad_not_ready': '廣告尚未準備好，請稍後再試。',
      'not_enough_coins': '金幣不足',
      'coins_n': '{n} 枚金幣',
      'get_n_coins': '取得 {n} 枚金幣',
      'remove_ads': '移除廣告',
      'remove_ads_sub': '永久享受無廣告體驗！',
      'restore_purchases': '還原購買項目',
      'purchase_unavailable': '目前無法購買。',
      'global': '全球',
      'friends': '好友',
      'you': '你',
      'default': '預設',
      'player_name': '玩家名稱',
      'save': '儲存',
      'saved': '已儲存',
      'games_played': '遊戲次數',
      'coins': '金幣',
      'htp_1_title': '1. 點擊放下',
      'htp_1_body': '點擊螢幕，將方塊放到堆疊上。',
      'htp_2_title': '2. 精準堆疊',
      'htp_2_body': '只有與下方方塊重疊的部分會保留。',
      'htp_3_title': '3. 完美對齊',
      'htp_3_body': '精準放置可保留寬度並獲得額外分數。',
      'htp_4_title': '4. 不要錯過',
      'htp_4_body': '如果方塊完全錯過堆疊，遊戲就會結束。',
    },

    'zh_CN': {
      'tap_to_play': '点击开始游戏',
      'shop': '商店',
      'skin': '皮肤',
      'skins': '皮肤',
      'home': '主页',
      'ranking': '排行榜',
      'how_to_play': '游戏玩法',
      'settings': '设置',
      'profile': '个人资料',
      'vibrate': '振动',
      'language': '语言',
      'volume': '音量',
      'rate_us': '为我们评分',
      'privacy_policy': '隐私政策',
      'mail': '邮件',
      'link_copied': '链接已复制',
      'game_over': '游戏结束',
      'your_score': '你的分数',
      'best': '最高分',
      'continue_here': '从这里继续',
      'watch_ad_keep_playing': '观看广告继续游戏',
      'use_coins': '使用 {n} 枚金币',
      'play_again': '再玩一次',
      'paused': '已暂停',
      'resume': '继续',
      'perfect': '完美',
      'watch_ad': '观看广告',
      'ad_not_ready': '广告尚未准备好，请稍后重试。',
      'not_enough_coins': '金币不足',
      'coins_n': '{n} 枚金币',
      'get_n_coins': '获取 {n} 枚金币',
      'remove_ads': '移除广告',
      'remove_ads_sub': '永久享受无广告体验！',
      'restore_purchases': '恢复购买',
      'purchase_unavailable': '当前无法购买。',
      'global': '全球',
      'friends': '好友',
      'you': '你',
      'default': '默认',
      'player_name': '玩家名称',
      'save': '保存',
      'saved': '已保存',
      'games_played': '游戏次数',
      'coins': '金币',
      'htp_1_title': '1. 点击放下',
      'htp_1_body': '点击屏幕，将方块放到堆叠上。',
      'htp_2_title': '2. 精准堆叠',
      'htp_2_body': '只有与下方方块重叠的部分会保留。',
      'htp_3_title': '3. 完美对齐',
      'htp_3_body': '精准放置可保留完整宽度并获得额外分数和金币。',
      'htp_4_title': '4. 不要错过',
      'htp_4_body': '如果方块完全没有碰到堆叠，游戏就会结束。',
    },
  };
}

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  String tr(String key, {Map<String, Object>? args}) {
    final table = LocalizationService.strings;

    // Use language + region for Chinese, language code for others.
    final localeKey = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';

    var text =
        table[localeKey]?[key] ?? table[locale.languageCode]?[key] ?? table['en']?[key] ?? key;

    args?.forEach((name, value) {
      text = text.replaceAll('{$name}', value.toString());
    });

    return text;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationService.supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          (supported.countryCode == null || supported.countryCode == locale.countryCode),
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref.read(storageServiceProvider).languageCode;

    if (code == 'zh_TW') return const Locale('zh', 'TW');
    if (code == 'zh_CN') return const Locale('zh', 'CN');

    final supported = LocalizationService.supportedLocales.any(
      (locale) => locale.languageCode == code,
    );

    return Locale(supported ? code : 'en');
  }

  Future<void> setLanguage(String code) async {
    final locale = code == 'zh_TW'
        ? const Locale('zh', 'TW')
        : code == 'zh_CN'
        ? const Locale('zh', 'CN')
        : Locale(code);

    final supported = LocalizationService.supportedLocales.any(
      (item) => item.languageCode == locale.languageCode && item.countryCode == locale.countryCode,
    );

    if (!supported) {
      throw ArgumentError.value(code, 'code', 'Unsupported language');
    }

    await ref.read(storageServiceProvider).setLanguageCode(code);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:place_stack/core/storage/storage_service.dart';
//
// /// Add a language: append to [LocalizationService.strings] and
// /// [LocalizationService.languageNames]. Missing keys fall back to English.
// abstract final class LocalizationService {
//   static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es'), Locale('hi')];
//
//   static const Map<String, String> languageNames = <String, String>{
//     'en': 'English',
//     'es': 'Español',
//     'hi': 'हिन्दी',
//   };
//
//   static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
//
//   static const Map<String, Map<String, String>> strings = <String, Map<String, String>>{
//     'en': {
//       'tap_to_play': 'Tap to Play',
//       'shop': 'Shop',
//       'skin': 'Skin',
//       'skins': 'Skin',
//       'home': 'Home',
//       'ranking': 'Ranking',
//       'how_to_play': 'How to Play',
//       'settings': 'Settings',
//       'profile': 'Profile',
//       'vibrate': 'Vibrate',
//       'language': 'Language',
//       'volume': 'Volume',
//       'rate_us': 'Rate Us',
//       'privacy_policy': 'Privacy Policy',
//       'mail': 'Mail',
//       'link_copied': 'Link copied to clipboard',
//       'game_over': 'Game Over',
//       'your_score': 'Your Score',
//       'best': 'Best',
//       'continue_here': 'Continue here',
//       'watch_ad_keep_playing': 'Watch Ad to keep playing',
//       'use_coins': 'Use {n} Coins',
//       'play_again': 'Play Again',
//       'paused': 'Paused',
//       'resume': 'Resume',
//       'perfect': 'Perfect',
//       'watch_ad': 'Watch Ad',
//       'ad_not_ready': 'Ad not ready yet. Try again in a moment.',
//       'not_enough_coins': 'Not enough coins',
//       'coins_n': '{n} Coins',
//       'get_n_coins': 'Get {n} coins',
//       'remove_ads': 'Remove Ads',
//       'remove_ads_sub': 'Enjoy ad-free experience forever!',
//       'restore_purchases': 'Restore purchases',
//       'purchase_unavailable': 'Purchases are not available right now.',
//       'global': 'Global',
//       'friends': 'Friends',
//       'you': 'You',
//       'default': 'Default',
//       'player_name': 'Player name',
//       'save': 'Save',
//       'saved': 'Saved',
//       'games_played': 'Games played',
//       'coins': 'Coins',
//       'htp_1_title': '1. Tap to Drop',
//       'htp_1_body': 'A block slides left and right. Tap anywhere to drop it onto the stack.',
//       'htp_2_title': '2. Stack Precisely',
//       'htp_2_body': 'Only the part that overlaps the block below stays. The rest falls away.',
//       'htp_3_title': '3. Go Perfect',
//       'htp_3_body': 'Land exactly on top to keep the full width and earn bonus points and coins.',
//       'htp_4_title': "4. Don't Miss",
//       'htp_4_body': 'If a block misses the stack completely, the game ends. Beat your best score!',
//     },
//     'es': {
//       'tap_to_play': 'Toca para jugar',
//       'shop': 'Tienda',
//       'skin': 'Skin',
//       'skins': 'Skin',
//       'home': 'Inicio',
//       'ranking': 'Ranking',
//       'how_to_play': 'Cómo jugar',
//       'settings': 'Ajustes',
//       'profile': 'Perfil',
//       'vibrate': 'Vibración',
//       'language': 'Idioma',
//       'volume': 'Volumen',
//       'rate_us': 'Califícanos',
//       'privacy_policy': 'Privacidad',
//       'mail': 'Correo',
//       'game_over': 'Fin del juego',
//       'your_score': 'Tu puntuación',
//       'best': 'Mejor',
//       'continue_here': 'Continuar aquí',
//       'watch_ad_keep_playing': 'Mira un anuncio para seguir',
//       'use_coins': 'Usar {n} monedas',
//       'play_again': 'Jugar de nuevo',
//       'paused': 'En pausa',
//       'resume': 'Reanudar',
//       'watch_ad': 'Ver anuncio',
//       'remove_ads': 'Quitar anuncios',
//       'global': 'Global',
//       'friends': 'Amigos',
//       'you': 'Tú',
//       'default': 'Básico',
//       'coins': 'Monedas',
//     },
//     'hi': {
//       'tap_to_play': 'खेलने के लिए टैप करें',
//       'shop': 'दुकान',
//       'skin': 'स्किन',
//       'skins': 'स्किन',
//       'home': 'होम',
//       'ranking': 'रैंकिंग',
//       'how_to_play': 'कैसे खेलें',
//       'settings': 'सेटिंग्स',
//       'profile': 'प्रोफ़ाइल',
//       'vibrate': 'कंपन',
//       'language': 'भाषा',
//       'volume': 'आवाज़',
//       'game_over': 'गेम ओवर',
//       'your_score': 'आपका स्कोर',
//       'best': 'सर्वश्रेष्ठ',
//       'play_again': 'फिर खेलें',
//       'paused': 'रुका हुआ',
//       'resume': 'जारी रखें',
//       'watch_ad': 'विज्ञापन देखें',
//       'remove_ads': 'विज्ञापन हटाएँ',
//       'you': 'आप',
//       'coins': 'सिक्के',
//     },
//   };
// }
//
// class AppLocalizations {
//   const AppLocalizations(this.locale);
//   final Locale locale;
//
//   static AppLocalizations of(BuildContext context) =>
//       Localizations.of<AppLocalizations>(context, AppLocalizations) ??
//       const AppLocalizations(Locale('en'));
//
//   /// Translate [key]; `{n}` placeholders are replaced from [args].
//   String tr(String key, {Map<String, Object>? args}) {
//     final table = LocalizationService.strings;
//     var text = table[locale.languageCode]?[key] ?? table['en']?[key] ?? key;
//     args?.forEach((k, v) => text = text.replaceAll('{$k}', '$v'));
//     return text;
//   }
// }
//
// class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();
//
//   @override
//   bool isSupported(Locale locale) => LocalizationService.strings.containsKey(locale.languageCode);
//
//   @override
//   Future<AppLocalizations> load(Locale locale) =>
//       SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
//
//   @override
//   bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
// }
//
// class LocaleNotifier extends Notifier<Locale> {
//   @override
//   Locale build() => Locale(ref.read(storageServiceProvider).languageCode);
//
//   Future<void> setLanguage(String code) async {
//     await ref.read(storageServiceProvider).setLanguageCode(code);
//     state = Locale(code);
//   }
// }
//
// final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
