import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/places/place_repository.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/location/place.dart';
import '../../l10n/app_localizations.dart';

/// Offline city search over the bundled GeoNames index.
class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pick(Place p) {
    ref.read(userPrefsProvider.notifier).setPlace(p);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/now');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final repo = ref.watch(placeRepositoryProvider).value;
    final results = repo?.search(_query) ?? const <Place>[];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: WaqtSpace.x4),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _query = v),
            style: WaqtText.body.copyWith(color: t.ink),
            cursorColor: t.ink,
            decoration: InputDecoration(
              hintText: l.citySearchHint,
              hintStyle: WaqtText.body.copyWith(color: t.inkMuted),
              filled: true,
              fillColor: t.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WaqtRadii.row),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: t.inkMuted),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                      icon: Icon(Icons.close_rounded, size: 18, color: t.inkMuted),
                      onPressed: () => setState(() {
                        _controller.clear();
                        _query = '';
                      }),
                    ),
            ),
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? const SizedBox.shrink()
          : results.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(WaqtSpace.screen),
              child: Text(l.cityNoResults(_query.trim()), style: WaqtText.body.copyWith(color: t.inkMuted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.x3, WaqtSpace.x2, WaqtSpace.x3, WaqtSpace.x8),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final p = results[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(WaqtRadii.row),
                  onTap: () => _pick(p),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                                Text(p.country ?? p.countryCode, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                              ],
                            ),
                          ),
                          Text(p.countryCode, style: WaqtText.overline.copyWith(color: t.inkMuted)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
