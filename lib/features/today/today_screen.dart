import 'package:flutter/material.dart';

import '../../core/widgets/waqt_widgets.dart';
import '../../l10n/app_localizations.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitle(l.navToday),
          Expanded(
            child: EmptyState(title: l.todayEmptyTitle, body: l.todayEmptyBody, progress: 0.35),
          ),
        ],
      ),
    );
  }
}
