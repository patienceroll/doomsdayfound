import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: RadioGroup<ThemeMode>(
        groupValue: themeMode,
        onChanged: (value) {
          if (value != null) {
            ref.read(themeModeProvider.notifier).setMode(value);
          }
        },
        child: ListView(
          children: [
            ListTile(
              title: Text(l10n.themeSystem),
              leading: const Icon(Icons.brightness_auto),
              trailing: Radio<ThemeMode>(value: ThemeMode.system),
            ),
            ListTile(
              title: Text(l10n.themeLight),
              leading: const Icon(Icons.light_mode),
              trailing: Radio<ThemeMode>(value: ThemeMode.light),
            ),
            ListTile(
              title: Text(l10n.themeDark),
              leading: const Icon(Icons.dark_mode),
              trailing: Radio<ThemeMode>(value: ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}
