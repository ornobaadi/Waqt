import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user/user_prefs.dart';
import 'flavor.dart';

/// Test mode: the fake clock, scenario jumps and the reference checker, in
/// any build. Hidden until unlocked by tapping the version seven times.
class TestModeState {
  const TestModeState({this.unlocked = false, this.showUnchecked = false});
  final bool unlocked;

  /// Show draft (unchecked) content, marked as such. Off by default even in
  /// test mode, so what you see is what users see.
  final bool showUnchecked;
}

class TestMode extends Notifier<TestModeState> {
  static const _kUnlocked = 'testmode.unlocked.v1', _kUnchecked = 'testmode.unchecked.v1';

  @override
  TestModeState build() {
    final sp = ref.read(sharedPrefsProvider);
    return TestModeState(
      unlocked: AppConfig.debugTools || (sp.getBool(_kUnlocked) ?? false),
      showUnchecked: AppConfig.debugTools || (sp.getBool(_kUnchecked) ?? false),
    );
  }

  void unlock() {
    ref.read(sharedPrefsProvider).setBool(_kUnlocked, true);
    state = TestModeState(unlocked: true, showUnchecked: state.showUnchecked);
  }

  void lock() {
    final sp = ref.read(sharedPrefsProvider);
    sp.setBool(_kUnlocked, false);
    sp.setBool(_kUnchecked, false);
    state = const TestModeState();
  }

  void setShowUnchecked(bool on) {
    ref.read(sharedPrefsProvider).setBool(_kUnchecked, on);
    state = TestModeState(unlocked: state.unlocked, showUnchecked: on);
  }
}

final testModeProvider = NotifierProvider<TestMode, TestModeState>(TestMode.new);
