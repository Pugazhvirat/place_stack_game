import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/shared/constants/game_constants.dart';
import 'package:place_stack/shared/models/skin.dart';

const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xFF000000);

class BlockRenderer {
  BlockRenderer({List<Color> palette = AppColors.defaultBlockPalette}) : _palette = palette;

  List<Color> _palette;
  void setPalette(List<Color> p) => _palette = p;
  final Paint _paint = Paint();

  /// When set, every block uses this single color instead of the palette.
  Color? solidColor;
  SkinStyle style = SkinStyle.brick;

  /// Rock picture used by the Stone skin (loaded once at app start).
  static ui.Image? stoneTexture;

  /// Pictures per skin (loaded once at app start).
  static final Map<SkinStyle, ui.Image> textures = <SkinStyle, ui.Image>{};

  static const Map<SkinStyle, String> _texturePaths = <SkinStyle, String>{
    SkinStyle.stone: 'assets/skins/rock.png',
    SkinStyle.brick: 'assets/skins/default.png',
    SkinStyle.ice: 'assets/skins/ice.png',
    SkinStyle.concrete: 'assets/skins/concrete.png',
    SkinStyle.wall: 'assets/skins/wall.png',
    SkinStyle.wood: 'assets/skins/wood.png',
  };

  static Future<void> preloadTextures() async {
    for (final entry in _texturePaths.entries) {
      try {
        final data = await rootBundle.load(entry.value);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        textures[entry.key] = frame.image;
      } catch (_) {
        // Picture missing: that skin uses its drawn look.
      }
    }
  }

  /// Width of the rock picture in game units. Bigger = larger rock pattern.
  static const double _textureWorldWidth = 260;

  /// Height of one brick row. Bigger number = bigger bricks.
  static const double rowHeight = 15;

  /// Approximate width of one brick.
  static const double brickWidth = 44;

  set palette(List<Color> value) =>
      _palette = value.isEmpty ? AppColors.defaultBlockPalette : value;

  Color colorFor(int index) {
    final solid = solidColor;
    if (solid != null) return solid;
    final n = _palette.length;
    final t = index * GameConstants.colorStep;
    final i = t.floor();
    final f = t - i;
    return Color.lerp(_palette[i % n], _palette[(i + 1) % n], f)!;
  }

  void render(
    Canvas canvas,
    Block block, {
    double alpha = 1,
    double heightScale = 1,
    double rotation = 0,
  }) {
    final h = block.height * heightScale;
    final rect = Rect.fromLTWH(block.x, block.bottom - h, block.width, h);
    final base = colorFor(block.colorIndex);
    final outer = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(GameConstants.blockCornerRadius),
    );

    final mortar = Color.lerp(base, _black, 0.42)!.withValues(alpha: alpha);
    final outline = Color.lerp(base, _black, 0.6)!.withValues(alpha: alpha);

    canvas.save();
    if (rotation != 0) {
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(rotation);
      canvas.translate(-rect.center.dx, -rect.center.dy);
    }
    final tex = textures[style];
    if (tex != null) {
      _renderTextured(canvas, block, rect, tex, alpha, h);
      canvas.restore();
      return;
    }
    if (style != SkinStyle.brick) {
      switch (style) {
        case SkinStyle.stone:
          _renderStone(canvas, block, rect, base, alpha, h);
        case SkinStyle.cake:
          _renderCake(canvas, block, rect, alpha, h);
        case SkinStyle.ice:
          _renderIce(canvas, rect, alpha, h);
        case SkinStyle.concrete:
          _renderStone(canvas, block, rect, base, alpha, h);
        case SkinStyle.wall:
        case SkinStyle.wood:
          _renderStone(canvas, block, rect, base, alpha, h);
        case SkinStyle.brick:
          break;
      }
      canvas.restore();
      return;
    }

    // Everything inside the block is clipped to its outline.
    canvas.save();
    canvas.clipRRect(outer);

    // Mortar (the dark gaps between bricks).
    _paint
      ..style = PaintingStyle.fill
      ..color = mortar;
    canvas.drawRRect(outer, _paint);

    final rows = math.max(1, (h / rowHeight).round());
    final rowH = h / rows;
    final perRow = math.max(1, (rect.width / brickWidth).round());
    final bw = rect.width / perRow;
    const r = Radius.circular(3);

    for (var row = 0; row < rows; row++) {
      final top = rect.top + row * rowH;
      final odd = row.isOdd;
      final count = odd ? perRow + 1 : perRow;
      for (var k = 0; k < count; k++) {
        final left = rect.left + k * bw - (odd ? bw / 2 : 0);
        final brick = Rect.fromLTWH(left, top, bw, rowH).deflate(1.2);
        if (brick.width <= 0 || brick.height <= 0) continue;

        // Slight tone change per brick so the wall does not look flat.
        final v = (row * 7 + k * 13 + block.colorIndex * 5) % 3;
        final tone = v == 0
            ? base
            : v == 1
            ? Color.lerp(base, _white, 0.06)!
            : Color.lerp(base, _black, 0.06)!;

        // Brick body.
        _paint.color = tone.withValues(alpha: alpha);
        canvas.drawRRect(RRect.fromRectAndRadius(brick, r), _paint);

        // Bright top edge.
        _paint.color = Color.lerp(base, _white, 0.42)!.withValues(alpha: alpha * 0.85);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(brick.left, brick.top, brick.width, brick.height * 0.34),
            topLeft: r,
            topRight: r,
          ),
          _paint,
        );

        // Dark bottom edge.
        _paint.color = Color.lerp(base, _black, 0.22)!.withValues(alpha: alpha * 0.9);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
              brick.left,
              brick.bottom - brick.height * 0.2,
              brick.width,
              brick.height * 0.2,
            ),
            bottomLeft: r,
            bottomRight: r,
          ),
          _paint,
        );
      }
    }
    canvas.restore();

    // Dark outline around the whole block.
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = outline;
    canvas.drawRRect(outer.deflate(0.8), _paint);
    _paint.style = PaintingStyle.fill;

    canvas.restore();
  }

  /// Slab colors, bottom to top, like the reference picture.
  static const List<Color> _stonePalette = <Color>[
    Color(0xFF3B4559), // slate blue
    Color(0xFF3A3640), // charcoal
    Color(0xFF3A4A63), // blue
    Color(0xFF4B4136), // brown
    Color(0xFF3C4559), // slate blue
    Color(0xFF4A4A3F), // olive
    Color(0xFF38353D), // dark
    Color(0xFF4A4752), // gray
  ];

  void _renderStone(Canvas canvas, Block block, Rect rect, Color base, double alpha, double h) {
    const radius = Radius.circular(4);
    Color c(Color col, [double a = 1]) => col.withValues(alpha: alpha * a);

    // Soft shadow under the whole block.
    _paint
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = c(_black, 0.55);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius).shift(const Offset(0, 3)), _paint);
    _paint.maskFilter = null;

    // The tall first block is drawn as several slabs.
    final rows = math.max(1, (h / GameConstants.blockHeight).round());
    final rowH = h / rows;

    for (var row = 0; row < rows; row++) {
      final slab = Rect.fromLTWH(rect.left, rect.top + row * rowH, rect.width, rowH);
      final tone = _stonePalette[(block.colorIndex + rows - 1 - row) % _stonePalette.length];
      final body = RRect.fromRectAndRadius(slab.deflate(0.4), radius);

      // Slab body: slightly lighter at the top, darker at the bottom.
      _paint
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c(Color.lerp(tone, _white, 0.07)!), c(Color.lerp(tone, _black, 0.18)!)],
        ).createShader(slab);
      canvas.drawRRect(body, _paint);
      _paint.shader = null;

      canvas.save();
      canvas.clipRRect(body);

      // Faint diagonal grain.
      _paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = c(_white, 0.035);
      for (var x = slab.left - rowH; x < slab.right; x += 14) {
        canvas.drawLine(Offset(x, slab.top), Offset(x + rowH * 0.5, slab.bottom), _paint);
      }

      // Cracks: a light line under a dark line, so they look carved in.
      final rnd = math.Random(block.colorIndex * 7919 + row * 104729 + 13);
      final cracks = math.min(3, 1 + (slab.width / 90).floor());
      _paint.strokeCap = StrokeCap.round;
      _paint.strokeJoin = StrokeJoin.round;
      for (var k = 0; k < cracks; k++) {
        var x = slab.left + slab.width * (0.08 + rnd.nextDouble() * 0.6);
        var y = slab.top + rowH * (0.25 + rnd.nextDouble() * 0.45);
        final path = Path()..moveTo(x, y);
        final segs = 2 + rnd.nextInt(3);
        for (var i = 0; i < segs; i++) {
          x += slab.width * (0.05 + rnd.nextDouble() * 0.09);
          y += rowH * ((i.isEven ? 1 : -1) * (0.1 + rnd.nextDouble() * 0.18));
          x = math.max(slab.left + 1, math.min(slab.right - 1, x));
          y = math.max(slab.top + 1, math.min(slab.bottom - 1, y));
          path.lineTo(x, y);
        }
        _paint
          ..strokeWidth = 1.6
          ..color = c(_white, 0.10);
        canvas.drawPath(path.shift(const Offset(0, 1.2)), _paint);
        _paint
          ..strokeWidth = 1.5
          ..color = c(_black, 0.75);
        canvas.drawPath(path, _paint);
      }
      canvas.restore();

      // Bevel: light line on top, dark line at the bottom, thin outline.
      _paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = c(_white, 0.2);
      canvas.drawLine(
        Offset(slab.left + 3, slab.top + 1),
        Offset(slab.right - 3, slab.top + 1),
        _paint,
      );
      _paint.color = c(_black, 0.4);
      canvas.drawLine(
        Offset(slab.left + 3, slab.bottom - 1),
        Offset(slab.right - 3, slab.bottom - 1),
        _paint,
      );
      _paint
        ..strokeWidth = 1
        ..color = c(_black, 0.45);
      canvas.drawRRect(body, _paint);
    }
    _paint
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.butt;
  }

  void _renderTextured(
    Canvas canvas,
    Block block,
    Rect rect,
    ui.Image tex,
    double alpha,
    double h,
  ) {
    const radius = Radius.circular(4);
    final body = RRect.fromRectAndRadius(rect, radius);

    // Soft shadow under the block.
    _paint
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = _black.withValues(alpha: 0.5 * alpha);
    canvas.drawRRect(body.shift(const Offset(0, 3)), _paint);
    _paint.maskFilter = null;

    // Rock picture, fixed in the game world so cut pieces match the block.
    final s = _textureWorldWidth / tex.width.toDouble();
    final tx = rect.left - (block.colorIndex % 7) * 43.0;
    final ty = rect.top - (block.colorIndex % 5) * 61.0;
    final matrix = Float64List.fromList(<double>[s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1]);
    _paint
      ..shader = ImageShader(
        tex,
        TileMode.mirror,
        TileMode.mirror,
        matrix,
        filterQuality: FilterQuality.medium,
      )
      ..color = _white.withValues(alpha: alpha);
    canvas.drawRRect(body, _paint);
    _paint.shader = null;

    canvas.save();
    canvas.clipRRect(body);

    // Light shading: a little darker towards the bottom.
    _paint
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _white.withValues(alpha: 0.06 * alpha),
          _black.withValues(alpha: 0.28 * alpha),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, _paint);
    _paint.shader = null;

    // Bevel: light line on top, dark line at the bottom.
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _white.withValues(alpha: 0.3 * alpha);
    canvas.drawLine(
      Offset(rect.left + 2, rect.top + 1),
      Offset(rect.right - 2, rect.top + 1),
      _paint,
    );
    _paint.color = _black.withValues(alpha: 0.45 * alpha);
    canvas.drawLine(
      Offset(rect.left + 2, rect.bottom - 1),
      Offset(rect.right - 2, rect.bottom - 1),
      _paint,
    );
    canvas.restore();

    // Thin dark outline.
    _paint
      ..strokeWidth = 1.2
      ..color = _black.withValues(alpha: 0.5 * alpha);
    canvas.drawRRect(body.deflate(0.6), _paint);
    _paint.style = PaintingStyle.fill;
  }

  // void _renderStone(Canvas canvas, Block block, Rect rect, Color base, double alpha, double h) {
  //   //const corner = Radius.circular(6);
  //   const corner = Radius.zero;
  //   final outer = RRect.fromRectAndRadius(rect, corner);
  //   final dark = Color.lerp(base, _black, 0.6)!;
  //   final light = Color.lerp(base, _white, 0.4)!;
  //   final shade = Color.lerp(base, _black, 0.25)!;
  //
  //   final rows = math.max(1, (h / GameConstants.blockHeight).round());
  //   final rowH = h / rows;
  //
  //   canvas.save();
  //   canvas.clipRRect(outer);
  //   for (var row = 0; row < rows; row++) {
  //     final course = Rect.fromLTWH(rect.left, rect.top + row * rowH, rect.width, rowH);
  //     final body = RRect.fromRectAndRadius(course.deflate(0.8), corner);
  //     final rnd = math.Random(block.colorIndex * 7919 + row * 104729 + 17);
  //
  //     // Stone body, bright top edge, darker bottom edge.
  //     _paint
  //       ..style = PaintingStyle.fill
  //       ..color = base.withValues(alpha: alpha);
  //     canvas.drawRRect(body, _paint);
  //     _paint.color = light.withValues(alpha: alpha * 0.8);
  //     canvas.drawRRect(
  //       RRect.fromRectAndCorners(
  //         Rect.fromLTWH(course.left + 0.8, course.top + 0.8, course.width - 1.6, rowH * 0.26),
  //         topLeft: corner,
  //         topRight: corner,
  //       ),
  //       _paint,
  //     );
  //     _paint.color = shade.withValues(alpha: alpha * 0.85);
  //     canvas.drawRRect(
  //       RRect.fromRectAndCorners(
  //         Rect.fromLTWH(
  //           course.left + 0.8,
  //           course.bottom - rowH * 0.18 - 0.8,
  //           course.width - 1.6,
  //           rowH * 0.18,
  //         ),
  //         bottomLeft: corner,
  //         bottomRight: corner,
  //       ),
  //       _paint,
  //     );
  //
  //     _paint
  //       ..style = PaintingStyle.stroke
  //       ..strokeCap = StrokeCap.round
  //       ..strokeJoin = StrokeJoin.round;
  //
  //     // Jagged seams between the big stones.
  //     final seams = (course.width / 90).round();
  //     for (var s = 1; s <= seams; s++) {
  //       final x = course.left + course.width * s / (seams + 1) + (rnd.nextDouble() - 0.5) * 10;
  //       final path = Path()..moveTo(x, course.top + 1);
  //       for (var i = 1; i <= 3; i++) {
  //         path.lineTo(x + (rnd.nextDouble() - 0.5) * 7, course.top + rowH * i / 3);
  //       }
  //       _paint
  //         ..strokeWidth = 1.8
  //         ..color = dark.withValues(alpha: alpha * 0.9);
  //       canvas.drawPath(path, _paint);
  //     }
  //
  //     // Small cracks.
  //     final cracks = 1 + (course.width / 70).floor();
  //     _paint
  //       ..strokeWidth = 1.0
  //       ..color = dark.withValues(alpha: alpha * 0.55);
  //     for (var c = 0; c < cracks; c++) {
  //       var x = course.left + 6 + rnd.nextDouble() * (course.width - 12);
  //       var y = course.top + rowH * (0.15 + rnd.nextDouble() * 0.35);
  //       final path = Path()..moveTo(x, y);
  //       for (var i = 0; i < 3; i++) {
  //         x += (rnd.nextDouble() - 0.5) * 14;
  //         y += rowH * (0.12 + rnd.nextDouble() * 0.15);
  //         path.lineTo(x, y);
  //       }
  //       canvas.drawPath(path, _paint);
  //     }
  //
  //     // Dark outline of this course.
  //     _paint
  //       ..strokeWidth = 1.6
  //       ..color = dark.withValues(alpha: alpha);
  //     canvas.drawRRect(body, _paint);
  //   }
  //   canvas.restore();
  //
  //   // Dark outline of the whole block.
  //   _paint
  //     ..style = PaintingStyle.stroke
  //     ..strokeWidth = 2.2
  //     ..color = dark.withValues(alpha: alpha);
  //   canvas.drawRRect(outer.deflate(1.1), _paint);
  //   _paint.style = PaintingStyle.fill;
  // }

  /// Pink frosting with wavy drips over red sponge.
  void _renderCake(Canvas canvas, Block block, Rect rect, double alpha, double h) {
    Color c(int v, [double a = 1]) => Color(v).withValues(alpha: alpha * a);

    final outer = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    final rows = math.max(1, (h / GameConstants.blockHeight).round());
    final rowH = h / rows;

    canvas.save();
    canvas.clipRRect(outer);
    for (var row = 0; row < rows; row++) {
      final top = rect.top + row * rowH;
      final bottom = top + rowH;
      final rnd = math.Random(block.colorIndex * 7919 + row * 104729 + 31);

      // Sponge, darker towards the bottom, with a thin peach base line.
      _paint
        ..style = PaintingStyle.fill
        ..color = c(0xFFE8334F);
      canvas.drawRect(Rect.fromLTRB(rect.left, top, rect.right, bottom), _paint);
      _paint.color = c(0xFFC8203D);
      canvas.drawRect(Rect.fromLTRB(rect.left, top + rowH * 0.72, rect.right, bottom), _paint);
      _paint.color = c(0xFFFFD9C7);
      canvas.drawRect(Rect.fromLTRB(rect.left, bottom - rowH * 0.1, rect.right, bottom), _paint);

      // Sponge speckles.
      _paint.color = c(0xFFFF7088, 0.8);
      final specks = (rect.width / 14).floor();
      for (var i = 0; i < specks; i++) {
        canvas.drawCircle(
          Offset(
            rect.left + rnd.nextDouble() * rect.width,
            top + rowH * (0.55 + rnd.nextDouble() * 0.3),
          ),
          0.8 + rnd.nextDouble() * 0.8,
          _paint,
        );
      }

      // Frosting with a wavy lower edge.
      final fh = rowH * 0.5;
      final amp = rowH * 0.16;
      final n = math.max(2, (rect.width / 30).round());
      final seg = rect.width / n;

      Path wave(double dy) {
        final p = Path()
          ..moveTo(rect.left, top)
          ..lineTo(rect.right, top)
          ..lineTo(rect.right, top + fh + dy);
        for (var i = n - 1; i >= 0; i--) {
          final x1 = rect.left + i * seg;
          final x0 = x1 + seg;
          p.quadraticBezierTo(
            (x0 + x1) / 2,
            top + fh + dy + (i.isEven ? amp * 1.6 : -amp * 1.6),
            x1,
            top + fh + dy,
          );
        }
        p.close();
        return p;
      }

      _paint.color = c(0xFFE98CA3); // soft shadow under the drips
      canvas.drawPath(wave(2.2), _paint);
      final frost = wave(0);
      _paint.color = c(0xFFFFE4EA);
      canvas.drawPath(frost, _paint);

      canvas.save();
      canvas.clipPath(frost);
      _paint.color = c(0xFFFFFFFF, 0.75); // shiny top edge
      canvas.drawRect(Rect.fromLTRB(rect.left, top, rect.right, top + rowH * 0.16), _paint);
      _paint.color = c(0xFFFFB3C2, 0.9); // frosting dots
      final dots = (rect.width / 40).floor();
      for (var i = 0; i < dots; i++) {
        canvas.drawCircle(
          Offset(
            rect.left + rnd.nextDouble() * rect.width,
            top + rowH * (0.2 + rnd.nextDouble() * 0.25),
          ),
          0.9,
          _paint,
        );
      }
      canvas.restore();
    }
    canvas.restore();

    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = c(0xFFB01834, 0.8);
    canvas.drawRRect(outer.deflate(0.8), _paint);
    _paint.style = PaintingStyle.fill;
  }

  /// Glossy blue crystal with bevelled edges and a light glint.
  void _renderIce(Canvas canvas, Rect rect, double alpha, double h) {
    Color c(int v, [double a = 1]) => Color(v).withValues(alpha: alpha * a);

    final rows = math.max(1, (h / GameConstants.blockHeight).round());
    final rowH = h / rows;

    for (var row = 0; row < rows; row++) {
      final course = Rect.fromLTWH(rect.left, rect.top + row * rowH, rect.width, rowH).deflate(0.6);
      if (course.width <= 2 || course.height <= 2) continue;
      final body = RRect.fromRectAndRadius(course, const Radius.circular(2));
      final b = math.min(rowH * 0.2, course.width / 4);
      final inner = course.deflate(b);

      // Glass body.
      _paint
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c(0xFFC9F1FF), c(0xFF63C6FF), c(0xFF2F8DFF)],
        ).createShader(course);
      canvas.drawRRect(body, _paint);
      _paint.shader = null;

      canvas.save();
      canvas.clipRRect(body);

      // Bevels: light on top/left, dark on right/bottom.
      _paint.color = c(0xFFFFFFFF, 0.38);
      canvas.drawPath(
        Path()
          ..moveTo(course.left, course.top)
          ..lineTo(course.right, course.top)
          ..lineTo(inner.right, inner.top)
          ..lineTo(inner.left, inner.top)
          ..close(),
        _paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(course.left, course.top)
          ..lineTo(inner.left, inner.top)
          ..lineTo(inner.left, inner.bottom)
          ..lineTo(course.left, course.bottom)
          ..close(),
        _paint,
      );
      _paint.color = c(0xFF1C6CE0, 0.45);
      canvas.drawPath(
        Path()
          ..moveTo(course.right, course.top)
          ..lineTo(course.right, course.bottom)
          ..lineTo(inner.right, inner.bottom)
          ..lineTo(inner.right, inner.top)
          ..close(),
        _paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(course.left, course.bottom)
          ..lineTo(course.right, course.bottom)
          ..lineTo(inner.right, inner.bottom)
          ..lineTo(inner.left, inner.bottom)
          ..close(),
        _paint,
      );

      // Bright inner face with a diagonal glint.
      _paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c(0xFFE8FAFF, 0.55), c(0xFF8AD4FF, 0.15)],
      ).createShader(inner);
      canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(3)), _paint);
      _paint.shader = null;

      canvas.save();
      canvas.clipRect(inner);
      _paint.color = c(0xFFFFFFFF, 0.28);
      canvas.drawPath(
        Path()
          ..moveTo(inner.left + inner.width * 0.3, inner.bottom)
          ..lineTo(inner.left + inner.width * 0.45, inner.bottom)
          ..lineTo(inner.left + inner.width * 0.75, inner.top)
          ..lineTo(inner.left + inner.width * 0.6, inner.top)
          ..close(),
        _paint,
      );
      canvas.restore();

      // Edge lines: bevel corners and inner frame.
      _paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = c(0xFFFFFFFF, 0.6);
      canvas.drawLine(course.topLeft, inner.topLeft, _paint);
      canvas.drawLine(course.topRight, inner.topRight, _paint);
      canvas.drawLine(course.bottomLeft, inner.bottomLeft, _paint);
      canvas.drawLine(course.bottomRight, inner.bottomRight, _paint);
      canvas.drawRect(inner, _paint);
      canvas.restore();

      // Outer glassy outline.
      _paint
        ..strokeWidth = 1.5
        ..color = c(0xFFD6F3FF, 0.95);
      canvas.drawRRect(body, _paint);
      _paint.style = PaintingStyle.fill;
    }
  }
}

// import 'dart:ui';
//
// import 'package:place_stack/app/theme/colors.dart';
// import 'package:place_stack/game/entities/block.dart';
// import 'package:place_stack/shared/constants/game_constants.dart';
//
// const Color _white = Color(0xFFFFFFFF);
// const Color _black = Color(0xFF000000);
//
// class BlockRenderer {
//   BlockRenderer({List<Color> palette = AppColors.defaultBlockPalette}) : _palette = palette;
//
//   List<Color> _palette;
//   final Paint _paint = Paint();
//   Color? solidColor;
//
//   set palette(List<Color> value) =>
//       _palette = value.isEmpty ? AppColors.defaultBlockPalette : value;
//
//   /// Smoothly interpolated colour for the n-th block (rainbow-like progression).
//   Color colorFor(int index) {
//     final solid = solidColor;
//     if (solid != null) return solid;
//     final n = _palette.length;
//
//     final t = index * GameConstants.colorStep;
//     final i = t.floor();
//     final f = t - i;
//     return Color.lerp(_palette[i % n], _palette[(i + 1) % n], f)!;
//   }
//
//   void render(
//     Canvas canvas,
//     Block block, {
//     double alpha = 1,
//     double heightScale = 1,
//     double rotation = 0,
//   }) {
//     final h = block.height * heightScale;
//     final rect = Rect.fromLTWH(block.x, block.bottom - h, block.width, h);
//     final base = colorFor(block.colorIndex);
//     const r = Radius.circular(GameConstants.blockCornerRadius);
//
//     canvas.save();
//     if (rotation != 0) {
//       canvas.translate(rect.center.dx, rect.center.dy);
//       canvas.rotate(rotation);
//       canvas.translate(-rect.center.dx, -rect.center.dy);
//     }
//
//     _paint.color = base.withValues(alpha: alpha);
//     canvas.drawRRect(RRect.fromRectAndRadius(rect, r), _paint);
//     // Dark border only.
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(rect.deflate(0.75), r),
//       Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.5
//         ..color = Color.lerp(base, const Color(0xFF000000), 0.45)!.withValues(alpha: alpha),
//     );
//
//     canvas.restore();
//   }
// }
