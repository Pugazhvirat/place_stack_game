import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/core/analytics/analytics_service.dart';
import 'package:place_stack/core/audio/audio_service.dart';
import 'package:place_stack/core/haptics/haptic_service.dart';
import 'package:place_stack/game/animation/block_animation.dart';
import 'package:place_stack/game/animation/camera_animation.dart';
import 'package:place_stack/game/animation/falling_animation.dart';
import 'package:place_stack/game/animation/perfect_animation.dart';
import 'package:place_stack/game/animation/score_animation.dart';
import 'package:place_stack/game/effects/glow_effect.dart';
import 'package:place_stack/game/effects/particle_effect.dart';
import 'package:place_stack/game/effects/screen_effect.dart';
import 'package:place_stack/game/effects/trail_effect.dart';
import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/game/entities/moving_block.dart';
import 'package:place_stack/game/entities/stack.dart';
import 'package:place_stack/game/mechanics/game_over.dart';
import 'package:place_stack/game/mechanics/movement.dart';
import 'package:place_stack/game/mechanics/placement.dart';
import 'package:place_stack/game/rendering/background_renderer.dart';
import 'package:place_stack/game/rendering/block_renderer.dart';
import 'package:place_stack/game/rendering/stack_renderer.dart';
import 'package:place_stack/game/scoring/coin_rewards.dart';
import 'package:place_stack/game/scoring/score_manager.dart';
import 'package:place_stack/game/state/game_session.dart';
import 'package:place_stack/game/state/game_status.dart';
import 'package:place_stack/shared/constants/game_constants.dart';
import 'package:place_stack/shared/models/skin.dart';

/// The continuous stacking game. All gameplay runs in a logical world that is
/// [GameConstants.worldWidth] units wide and scaled to the screen.
class StackGame extends FlameGame with TapCallbacks {
  StackGame({
    required this.audio,
    required this.haptics,
    required this.analytics,
    required this.onScoreChanged,
    required this.onCoinsEarned,
    required this.onStatusChanged,
    required this.runColor,
    required this.pickNextRunColor,
    List<Color>? palette,
    SkinStyle skinStyle = SkinStyle.brick,
    String? skinTexture,
  }) : _blockRenderer = BlockRenderer(palette: palette ?? AppColors.defaultBlockPalette) {
    _blockRenderer.style = skinStyle;

    _stackRenderer = StackRenderer(_blockRenderer);
  }

  final AudioService audio;
  final HapticService haptics;
  final AnalyticsService analytics;
  final void Function(int score) onScoreChanged;
  final void Function(int coins) onCoinsEarned;
  final void Function(GameStatus status) onStatusChanged;
  final Color Function() runColor;
  final void Function() pickNextRunColor;

  /// Replace `background.image` later to use artwork instead of the gradient.
  final BackgroundRenderer background = BackgroundRenderer();

  final math.Random _random = math.Random();
  final BlockStack _stack = BlockStack();
  final GameSession session = GameSession();
  final BlockRenderer _blockRenderer;
  late final StackRenderer _stackRenderer;

  final CameraAnimation _camera = CameraAnimation();
  final FallingAnimation _falling = FallingAnimation();
  final ScoreAnimation _popups = ScoreAnimation();
  final ParticleEffect _particles = ParticleEffect();
  final GlowEffect _glow = GlowEffect();
  final TrailEffect _trail = TrailEffect();
  final ScreenEffect _screen = ScreenEffect();
  final GameOverTracker _gameOver = GameOverTracker();

  PerfectAnimation? _perfect;
  BlockPlaceAnimation? _placeAnim;
  BlockDropAnimation? _drop;
  PlacementResult? _pending;
  MovingBlock? _moving;

  GameStatus _status = GameStatus.ready;
  bool _hasSize = false;
  bool _pendingReset = true;
  bool _firstRun = true;
  double _scale = 1;
  double _viewH = 800;
  double _time = 0;
  //late int _runColorIndex = _random.nextInt(AppColors.runColors.length);
  bool _zoomingOut = false;
  double _zoomT = 0;
  double _zoomTarget = 1;
  double _zoomTy = 0;
  double _zoomHold = 0;

  GameStatus get status => _status;
  static const double _gapAboveStack = 1;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _hasSize = size.x > 0 && size.y > 0;
    if (!_hasSize) return;
    _scale = size.x / GameConstants.worldWidth;
    _viewH = size.y / _scale;
  }

  void applySkin(Skin skin) {
    _blockRenderer.style = skin.style;
    _blockRenderer.setPalette(skin.palette);
  }

  /// Resets everything and starts a fresh run (Play Again).
  void restart() {
    if (!_firstRun) analytics.gameRestarted();
    if (paused) resumeEngine();
    pickNextRunColor();
    _pendingReset = true;
    if (_hasSize) _resetWorld();
  }

  /// Revives after a miss: keeps the stack and score, spawns a new moving block.
  void continueAfterGameOver() {
    if (_status != GameStatus.gameOver) return;
    _zoomT = 0;
    _zoomingOut = false;
    _zoomHold = 0;
    _gameOver.reset();
    _falling.clear();

    // Rebuild the last 4 blocks at a comfortable width, all centered
    // on the same line, so the tower top looks like fresh blocks.
    final list = _stack.blocks;
    final count = math.min(6, list.length);
    final center = list.last.centerX;
    final newWidth = math.max(list.last.width, GameConstants.reviveBlockWidth);
    final left = (center - newWidth / 2)
        .clamp(
          GameConstants.trackMargin,
          GameConstants.worldWidth - GameConstants.trackMargin - newWidth,
        )
        .toDouble();
    for (var i = list.length - count; i < list.length; i++) {
      list[i].width = newWidth;
      list[i].x = left;
    }

    _spawnMoving();
    _setStatus(GameStatus.playing);
  }

  void pauseGame() {
    if (_status != GameStatus.playing) return;
    _setStatus(GameStatus.paused);
    pauseEngine();
  }

  void resumeGame() {
    if (_status != GameStatus.paused) return;
    resumeEngine();
    _setStatus(GameStatus.playing);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _dropBlock();
  }

  void _dropBlock() {
    if (_status != GameStatus.playing) return;
    final moving = _moving;
    if (moving == null || _drop != null) return;

    final base = _stack.top;
    final targetY = base.y - GameConstants.blockHeight;
    final result = Placement.resolve(
      base: base,
      moving: moving.block,
      targetY: targetY,
      random: _random,
    );
    _trail.clear();
    //audio.play(SoundEffect.drop);

    if (GameOverRule.isGameOver(result)) {
      // Complete miss: the whole block falls, then the game ends.
      _moving = null;
      _falling.add(result.piece!);
      _gameOver.begin();
      //_screen.shake(intensity: 7);
      haptics.gameOver();
      audio.play(SoundEffect.gameOver);
      return;
    }
    _pending = result;
    _drop = BlockDropAnimation(block: moving.block, targetY: targetY);
  }

  void _resetWorld() {
    _pendingReset = false;

    // One color per run: boxes and background use the same color.
    final color = runColor();
    _blockRenderer.solidColor = color;
    background.tint = color;

    _zoomHold = 0;
    _zoomT = 0;
    _zoomingOut = false;
    _stack.clear();
    _falling.clear();
    _popups.clear();
    _particles.clear();
    _glow.clear();
    _trail.clear();
    _screen.clear();
    _gameOver.reset();
    _camera.reset();
    session.reset();
    _perfect = null;
    _placeAnim = null;
    _drop = null;
    _pending = null;

    const w = GameConstants.initialBlockWidth;
    final firstTop = _viewH * GameConstants.firstBlockTopFraction;
    _stack.push(
      Block(
        x: (GameConstants.worldWidth - w) / 2,
        y: firstTop,
        width: w,
        height: _viewH - firstTop,
        colorIndex: 0,
      ),
    );
    _spawnMoving();
    onScoreChanged(0);
    _setStatus(GameStatus.playing);
    if (_firstRun) analytics.gameStarted();
    _firstRun = false;
  }

  double get _movingWorldY => _stack.top.y - GameConstants.blockHeight - _gapAboveStack;

  void _spawnMoving() {
    final width = _stack.top.width;
    final fromLeft = session.blocksPlaced.isEven;
    final minX = GameConstants.trackMargin;
    final maxX = math.max(minX, GameConstants.worldWidth - GameConstants.trackMargin - width);
    _moving = MovingBlock(
      block: Block(
        x: fromLeft ? minX : maxX,
        y: _movingWorldY,
        width: width,
        height: GameConstants.blockHeight,
        colorIndex: _stack.length,
      ),
      direction: fromLeft ? 1 : -1,
      speed: Movement.speedFor(session.score),
      minX: minX,
      maxX: maxX,
    );
    _trail.clear();
  }

  void _land() {
    final result = _pending;
    _drop = null;
    _pending = null;
    final placed = result?.placed;
    if (result == null || placed == null) {
      _spawnMoving();
      return;
    }

    final perfect = result.type == PlacementType.perfect;
    _stack.push(placed);
    _moving = null;
    session.registerPlacement(perfect: perfect);

    final points = ScoreManager.pointsFor(perfect: perfect, streak: session.perfectStreak);
    session.score += points;
    final coins = CoinRewards.forPlacement(perfect: perfect, streak: session.perfectStreak);
    session.coinsEarned += coins;

    final color = _blockRenderer.colorFor(placed.colorIndex);
    // _placeAnim = BlockPlaceAnimation();
    audio.play(perfect ? SoundEffect.perfect : SoundEffect.drop);

    if (perfect) {
      // final bonus = ScoreManager.perfectBonus(session.perfectStreak);
      // _perfect = PerfectAnimation(bonus);
      // _glow.trigger(placed.rect, color);
      _glow.trigger(placed.rect, const Color(0xFFFFFFFF));
      //_particles.burst(x: placed.centerX, y: placed.top, color: color, random: _random);
      //_screen.flash(AppColors.cyan, strength: 0.12);
      //_popups.add('+$points', placed.centerX, placed.top - 8, AppColors.cyan);
      haptics.perfect();
      analytics.perfectLanding(session.perfectStreak);
      if (coins > 0) audio.play(SoundEffect.coin);
    } else {
      final piece = result.piece;
      if (piece != null) _falling.add(piece);
      //_screen.shake(intensity: 1, duration: 0.15);
      //_popups.add('+$points', placed.centerX, placed.top - 8, const Color(0xFFFFFFFF));
      haptics.placement();
      audio.play(SoundEffect.cutoff);
    }

    _camera.target = math.max(0, _viewH * GameConstants.cameraTopFraction - placed.y);
    onScoreChanged(session.score);
    if (coins > 0) onCoinsEarned(coins);
    analytics.blockPlaced(session.score);
    _spawnMoving();
  }

  void _startZoomOut() {
    final top = _stack.top.y - 20;
    final bottom = _stack.blocks.first.bottom;
    final towerH = math.max(1.0, bottom - top);
    _zoomTarget = math.min(1.0, _viewH * 0.8 / towerH);

    //_zoomTy = _zoomTarget >= 0.999 ? _camera.offset : _viewH * 0.22 - _zoomTarget * top;

    _zoomTy = _zoomTarget >= 0.999 ? _camera.offset : _viewH / 2 - _zoomTarget * (top + bottom) / 2;
    _zoomT = _zoomTarget >= 0.999 ? 1 : 0;
    _zoomingOut = true;
  }

  void _setStatus(GameStatus status) {
    if (_status == status) return;
    _status = status;
    onStatusChanged(status);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_hasSize) return;
    if (_pendingReset) _resetWorld();

    final step = math.min(dt, GameConstants.maxFrameStep);
    _time += step;
    _camera.update(step);

    if (_status == GameStatus.playing) {
      final moving = _moving;
      if (moving != null) {
        final drop = _drop;
        if (drop != null) {
          if (drop.update(step)) _land();
        } else {
          Movement.advance(moving, step);
          moving.block.y = _movingWorldY;
          _trail.record(moving.block.x);
        }
      }
    }

    _falling.update(step, removeBelowY: -_camera.offset + _viewH);
    _particles.update(step);
    _glow.update(step);
    _popups.update(step);
    _screen.update(step);
    _perfect?.update(step);
    if (_perfect?.isDone ?? false) _perfect = null;
    _placeAnim?.update(step);
    if (_placeAnim?.isDone ?? false) _placeAnim = null;

    // if (_gameOver.update(step)) {
    //   _drop = null;
    //   _setStatus(GameStatus.gameOver);
    // }
    // if (_gameOver.isActive && _falling.pieces.isEmpty) {
    //   _gameOver.reset();
    //   _drop = null;
    //   _setStatus(GameStatus.gameOver);
    // }

    if (_gameOver.isActive && _falling.pieces.isEmpty && !_zoomingOut) {
      _startZoomOut();
    }
    if (_zoomingOut) {
      _zoomT = math.min(1.0, _zoomT + step / 2.0);
      if (_zoomT >= 1) {
        _zoomHold += step;
        if (_zoomHold >= 1.5) {
          _zoomingOut = false;
          _gameOver.reset();
          _drop = null;
          _setStatus(GameStatus.gameOver);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_hasSize || _stack.isEmpty) return;

    final logical = Size(GameConstants.worldWidth, _viewH);
    canvas.save();
    canvas.scale(_scale);

    background.render(canvas, logical, _camera.offset, _time);

    // canvas.save();
    // final shake = _screen.offset;
    // canvas.translate(shake.dx, shake.dy + _camera.offset);
    // final viewTop = -_camera.offset;
    // final viewBottom = viewTop + _viewH;

    canvas.save();
    final shake = _screen.offset;

    final p = _zoomT * _zoomT * (3 - 2 * _zoomT);
    final zoom = 1 + (_zoomTarget - 1) * p;
    final ty = _camera.offset + (_zoomTy - _camera.offset) * p;
    canvas.translate(shake.dx + GameConstants.worldWidth / 2 * (1 - zoom), shake.dy + ty);
    canvas.scale(zoom);
    final viewTop = -ty / zoom;
    final viewBottom = viewTop + _viewH / zoom;

    _glow.render(canvas);
    _stackRenderer.renderStack(
      canvas,
      _stack,
      viewTop: viewTop,
      viewBottom: viewBottom,
      topHeightScale: _placeAnim?.heightScale ?? 1,
    );
    final moving = _moving;
    // if (moving != null) {
    //   _trail.render(canvas, moving.block, _blockRenderer.colorFor(moving.block.colorIndex));
    // }
    _stackRenderer.renderMoving(canvas, moving);
    _stackRenderer.renderPieces(canvas, _falling.pieces);
    _particles.render(canvas);
    _popups.render(canvas);
    canvas.restore();

    // Screen-space overlays.
    final trackY =
        _stack.top.y -
        GameConstants.blockHeight -
        _gapAboveStack +
        _camera.offset +
        GameConstants.blockHeight / 2;
    _perfect?.render(
      canvas,
      Offset(GameConstants.worldWidth / 2, trackY + GameConstants.blockHeight + 22),
    );
    _screen.renderFlash(canvas, logical);
    canvas.restore();
  }
}
