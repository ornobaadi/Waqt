import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/flavor.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../l10n/app_localizations.dart';

/// "Handcrafted by" with the maker's signature, at the foot of Settings, as in
/// his other apps. Here it takes the moment's ink, so it follows the sky from
/// dawn to night, and closes with a request for dua.
class CreatorFooter extends StatefulWidget {
  const CreatorFooter({super.key});

  @override
  State<CreatorFooter> createState() => _CreatorFooterState();
}

class _CreatorFooterState extends State<CreatorFooter> {
  static final Uri _portfolio = Uri.parse('https://ornobaadi.vercel.app');
  static const _taps = 5;
  static const _window = Duration(seconds: 3);

  int _count = 0;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  /// A hidden door: five quick taps on the signature open the portfolio.
  void _tap() {
    final now = DateTime.now();
    _count = now.difference(_last) > _window ? 1 : _count + 1;
    _last = now;
    if (_count >= _taps) {
      _count = 0;
      unawaited(launchUrl(_portfolio, mode: LaunchMode.externalApplication));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final caption = WaqtText.overline.copyWith(color: t.inkMuted, letterSpacing: 2.4);

    return Column(
      children: [
        const SizedBox(height: WaqtSpace.x12),
        const ArcMark(size: 30),
        const SizedBox(height: WaqtSpace.x5),
        Text(l.footerHandcrafted, textAlign: TextAlign.center, style: caption),
        const SizedBox(height: WaqtSpace.x2),
        Semantics(
          label: l.footerSignatureLabel,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tap,
            child: Padding(
              padding: const EdgeInsets.all(WaqtSpace.x3),
              // One drawing, tinted with the moment's ink.
              child: Image.asset(
                'assets/ornob-aadi-signature/ornob-aadi-signature-bold-dark.png',
                height: 64,
                color: t.ink,
                colorBlendMode: BlendMode.srcIn,
                // Missing art must never break the screen.
                errorBuilder: (_, _, _) => const SizedBox(height: 64),
              ),
            ),
          ),
        ),
        const SizedBox(height: WaqtSpace.x2),
        Text(l.footerVersion(AppConfig.version), textAlign: TextAlign.center, style: caption),
        const SizedBox(height: WaqtSpace.x2),
        Text(l.footerTagline, textAlign: TextAlign.center, style: caption),
        const SizedBox(height: WaqtSpace.x5),
        Text(
          l.footerDuaRequest,
          textAlign: TextAlign.center,
          style: WaqtText.label.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: WaqtSpace.x8),
      ],
    );
  }
}
