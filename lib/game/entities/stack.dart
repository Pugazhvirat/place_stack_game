import 'dart:collection';

import 'package:place_stack/game/entities/block.dart';

/// Placed blocks, bottom first. (Named BlockStack to avoid clashing with Flutter's Stack.)
class BlockStack {
  final List<Block> _blocks = <Block>[];

  List<Block> get blocks => UnmodifiableListView<Block>(_blocks);
  int get length => _blocks.length;
  bool get isEmpty => _blocks.isEmpty;
  Block get top => _blocks.last;

  void push(Block block) => _blocks.add(block);
  void clear() => _blocks.clear();
}
