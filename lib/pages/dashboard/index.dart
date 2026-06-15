import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doomsdayfound/database/db_helper.dart';
import 'package:doomsdayfound/database/database.dart';
import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/providers/balance_provider.dart';
import 'package:doomsdayfound/pages/dashboard/components/create_balance_sheet.dart';
import 'package:doomsdayfound/pages/dashboard/components/modify_balance_sheet.dart';
import 'package:doomsdayfound/pages/dashboard/components/spend_sheet.dart';
import 'package:doomsdayfound/pages/dashboard/components/earn_sheet.dart';
import 'package:doomsdayfound/components/count_up.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _openBalanceInput(BuildContext context, WidgetRef ref) async {
    final result = await showCreateBalanceSheet(context);
    if (result == null) return;

    await saveBalanceSnapshot(
      totalBalance: result.totalBalance,
      accounts: result.categories
          ?.map((c) => (name: c.name, balance: c.balance, type: c.type))
          .toList(),
    );

    ref.invalidate(balanceProvider);
  }

  Future<void> _openModifyBalance(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final newBalance = await showModifyBalanceSheet(context);
    if (newBalance == null) return;

    await saveBalanceSnapshot(totalBalance: newBalance);

    ref.invalidate(balanceProvider);
  }

  Future<void> _openEarn(
    BuildContext context,
    WidgetRef ref,
    BalanceSnapshot snapshot,
  ) async {
    final result = await showEarnSheet(context);
    if (result == null) return;

    final newBalance = snapshot.totalBalance + result.amount;
    await recordTransaction(
      snapshotId: snapshot.id,
      newBalance: newBalance,
      amount: result.amount,
      type: TransactionType.income,
      remark: result.remark,
    );

    ref.invalidate(balanceProvider);
  }

  Future<void> _openSpend(
    BuildContext context,
    WidgetRef ref,
    BalanceSnapshot snapshot,
  ) async {
    final result = await showSpendSheet(context);
    if (result == null) return;

    final newBalance = snapshot.totalBalance - result.amount;
    await recordTransaction(
      snapshotId: snapshot.id,
      newBalance: newBalance,
      amount: result.amount,
      type: TransactionType.cost,
      remark: result.remark,
    );

    ref.invalidate(balanceProvider);
  }

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
                    onPressed: () => _openBalanceInput(context, ref),
                  child: Text(l10n.dashboradCreateBank),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUp(value: snapshot.totalBalance),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              _openEarn(context, ref, snapshot),
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(l10n.dashboardEarnTitle),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              _openSpend(context, ref, snapshot),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: Text(l10n.dashboardSpendTitle),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              _openModifyBalance(context, ref),
                          icon: const Icon(Icons.edit),
                          label: Text(l10n.dashboardModifyBalance),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
