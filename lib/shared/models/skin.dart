import 'package:flutter/painting.dart';
import 'package:place_stack/app/theme/colors.dart';

enum SkinUnlock { free, coins, ad }

enum SkinStyle { brick, stone, cake, ice, concrete, wall, wood }

class Skin {
  const Skin({
    required this.id,
    required this.name,
    required this.unlock,
    required this.style,
    this.price = 0,
    this.palette = AppColors.defaultBlockPalette,
    this.fixedColor,
  });

  final String id;
  final String name;
  final SkinUnlock unlock;
  final SkinStyle style;
  final int price;
  final List<Color> palette;

  /// When set, the skin always uses this color.
  final Color? fixedColor;

  Color get preview => fixedColor ?? palette.first;

  static const List<Skin> all = <Skin>[
    Skin(
      id: 'default',
      name: 'Default',
      unlock: SkinUnlock.free,
      style: SkinStyle.brick,
      fixedColor: Color(0xFFE53935),
    ),
    Skin(
      id: 'stone',
      name: 'Stone',
      unlock: SkinUnlock.free,
      style: SkinStyle.stone,
      fixedColor: Color(0xFF13151B),
    ),
    Skin(
      id: 'ice',
      name: 'Ice',
      unlock: SkinUnlock.free,
      style: SkinStyle.ice,
      fixedColor: Color(0xFF3E9BFF),
    ),

    // NEW: Concrete skin
    Skin(
      id: 'concrete',
      name: 'Concrete',
      unlock: SkinUnlock.free,
      style: SkinStyle.concrete,
      fixedColor: Color(0xFFFFD84D),
    ),

    Skin(
      id: 'wall',
      name: 'wall',
      unlock: SkinUnlock.free,
      style: SkinStyle.wall,
      fixedColor: Color(0xFFFF8A80),
    ),
    Skin(
      id: 'wood',
      name: 'Wood',
      unlock: SkinUnlock.free,
      style: SkinStyle.wood,

      fixedColor: Color(0xFF8D5A2B),
    ),
  ];

  static Skin byId(String id) => all.firstWhere((s) => s.id == id, orElse: () => all.first);
}
// import 'package:flutter/painting.dart';
// import 'package:place_stack/app/theme/colors.dart';
//
// enum SkinUnlock { free, coins, ad }
//
// enum SkinStyle { brick, stone, cake, ice }
//
// class Skin {
//   const Skin({
//     required this.id,
//     required this.name,
//     required this.unlock,
//     required this.style,
//     this.price = 0,
//     this.palette = AppColors.defaultBlockPalette,
//     this.fixedColor,
//   });
//
//   final String id;
//   final String name;
//   final SkinUnlock unlock;
//   final SkinStyle style;
//   final int price;
//   final List<Color> palette;
//
//   /// When set, the skin always uses this color (boxes and background)
//   /// instead of the random color of each run.
//   final Color? fixedColor;
//
//   Color get preview => fixedColor ?? palette.first;
//
//   static const List<Skin> all = <Skin>[
//     Skin(
//       id: 'default',
//       name: 'Default',
//       unlock: SkinUnlock.free,
//       style: SkinStyle.brick,
//       fixedColor: Color(0xFFFFB26B),
//     ),
//     Skin(
//       id: 'stone',
//       name: 'Stone',
//       unlock: SkinUnlock.free,
//       style: SkinStyle.stone,
//       fixedColor: Color(0xFF13151B),
//     ),
//     Skin(
//       id: 'ice',
//       name: 'Ice',
//       unlock: SkinUnlock.free,
//       style: SkinStyle.ice,
//       fixedColor: Color(0xFF3E9BFF),
//     ),
//   ];
//
//   static Skin byId(String id) => all.firstWhere((s) => s.id == id, orElse: () => all.first);
// }

// import 'package:flutter/painting.dart';
// import 'package:place_stack/app/theme/colors.dart';
//
// enum SkinUnlock { free, coins, ad }
//
// enum SkinStyle { brick, stone }
//
// class Skin {
//   const Skin({
//     required this.id,
//     required this.name,
//     required this.unlock,
//     required this.style,
//     this.price = 0,
//     this.palette = AppColors.defaultBlockPalette,
//   });
//
//   final String id;
//   final String name;
//   final SkinUnlock unlock;
//   final SkinStyle style;
//   final int price;
//   final List<Color> palette;
//
//   Color get preview => palette.first;
//
//   static const List<Skin> all = <Skin>[
//     Skin(id: 'default', name: 'Default', unlock: SkinUnlock.free, style: SkinStyle.brick),
//     Skin(id: 'stone', name: 'Stone', unlock: SkinUnlock.free, style: SkinStyle.stone),
//   ];
//
//   static Skin byId(String id) => all.firstWhere((s) => s.id == id, orElse: () => all.first);
// }
