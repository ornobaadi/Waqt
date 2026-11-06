import 'package:flutter/material.dart';

import '../../core/widgets/waqt_widgets.dart';
import '../../l10n/app_localizations.dart';

/// Content comes only from the reviewed content DB (Phase 3). Until then
/// this screen states the policy rather than showing placeholder text.
class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitle(l.navDuas),
          Expanded(
            child: EmptyState(title: l.duasEmptyTitle, body: l.duasEmptyBody, progress: 0.85),
          ),
        ],
      ),
    );
  }
}
