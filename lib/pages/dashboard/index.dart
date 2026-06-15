import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/providers/balance_provider.dart';
import 'package:doomsdayfound/pages/dashboard/balance_input_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final balanceAsync = ref.watch(balanceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (snapshot) => snapshot == null
            ? Center(
                child: ElevatedButton(
                  onPressed: () => showBalanceInputSheet(context),
                  child: Text(l10n.dashboradCreateBank),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Balance: ${snapshot.totalBalance}'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => showBalanceInputSheet(context),
                      child: Text(l10n.dashboardBalanceInputTitle),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
