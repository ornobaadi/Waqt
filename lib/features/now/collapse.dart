import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';

/// Cards on Now that someone folded away. Every card opens again on the
/// next launch: what is happening now should be seen first.
class CollapsedCards extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }
}

final collapsedCardsProvider = NotifierProvider<CollapsedCards, Set<String>>(CollapsedCards.new);

/// The chevron in a card's header: points down when open, sideways when folded.
class FoldChevron extends StatelessWidget {
  const FoldChevron({super.key, required this.open, required this.color});
  final bool open;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedRotation(
    turns: open ? 0 : -0.25,
    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : WaqtMotion.ui,
    curve: WaqtMotion.ease,
    child: Icon(Icons.expand_more_rounded, size: 20, color: color),
  );
}

/// The body under a card's header, folding away smoothly.
class FoldBody extends StatelessWidget {
  const FoldBody({super.key, required this.open, required this.child});
  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : WaqtMotion.ui,
    curve: WaqtMotion.ease,
    alignment: Alignment.topCenter,
    child: open ? child : const SizedBox(width: double.infinity),
  );
}
