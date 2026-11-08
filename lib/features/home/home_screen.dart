import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:place_stack/app/router.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/game/rendering/background_renderer.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runColor = ref.watch(runColorProvider);
    // final background = Color.lerp(
    //   const Color(0xFFFFFFFF),
    //   runColor,
    //   BackgroundRenderer.tintStrength,
    // )!;
    final background = runColor.computeLuminance() < 0.05
        ? const Color(0xFFF2F2F4)
        : Color.lerp(const Color(0xFFFFFFFF), runColor, BackgroundRenderer.tintStrength)!;

    final boxColor = runColor.computeLuminance() < 0.05 ? Colors.grey : runColor;

    return Column(
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = (c.maxWidth * 0.64).clamp(120.0, 340.0).toDouble();
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(AppRoutes.game),
                    child: SizedBox(
                      width: w,
                      height: c.maxHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CubePainter(
                                topHeight: w * 0.19,
                                color: boxColor,
                                background: background,
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, 0.05),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  context.tr('tap_to_play'),
                                  style: AppTypography.title.copyWith(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Block used as the "Tap to Play" button. Colored by the random run color.
class _CubePainter extends CustomPainter {
  const _CubePainter({required this.topHeight, required this.color, required this.background});

  final double topHeight;
  final Color color;
  final Color background;

  static const Color _white = Color(0xFFFFFFFF);
  static const Color _black = Color(0xFF000000);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final top = topHeight.clamp(0.0, h).toDouble();
    final inset = w * 0.15;

    // Front face: run color, darkening, then fading into the background.
    final front = Rect.fromLTWH(0, top, w, h - top);
    canvas.drawRect(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            Color.lerp(color, _black, 0.25)!,
            Color.lerp(color, _black, 0.4)!,
            background.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 0.8, 1],
        ).createShader(front),
    );

    // Left half slightly darker.
    final left = Rect.fromLTWH(0, top, w / 2, h - top);
    canvas.drawRect(
      left,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x26000000), Color(0x00000000)],
          stops: [0, 0.55, 1],
        ).createShader(left),
    );

    // Right half slightly lighter.
    final right = Rect.fromLTWH(w / 2, top, w / 2, h - top);
    canvas.drawRect(
      right,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0x1AFFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.55, 1],
        ).createShader(right),
    );

    // Top face: lighter version of the run color.
    final topRect = Rect.fromLTWH(0, 0, w, top);
    final path = Path()
      ..moveTo(inset, 0)
      ..lineTo(w - inset, 0)
      ..lineTo(w, top)
      ..lineTo(0, top)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, _white, 0.35)!, Color.lerp(color, _white, 0.2)!],
        ).createShader(topRect),
    );
  }

  @override
  bool shouldRepaint(covariant _CubePainter old) =>
      old.topHeight != topHeight || old.color != color || old.background != background;
}
