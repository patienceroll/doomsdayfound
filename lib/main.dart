import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          final themeMode = ref.watch(themeModeProvider);
          return MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('zh'),
            ],
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.helloWorld, style: TextStyle(color: colors.textPrimary)),
            const SizedBox(height: 24),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ],
              selected: {ref.watch(themeModeProvider)},
              onSelectionChanged: (value) {
                ref.read(themeModeProvider.notifier).setMode(value.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
