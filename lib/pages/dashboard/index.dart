import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final totalBalance = await showCreateBalanceSheet(context);
    if (totalBalance == null) return;

    await saveBalanceSnapshot(totalBalance: totalBalance);

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

  Future<void> _openManageCategories(
    BuildContext context,
    WidgetRef ref,
    BalanceProviderValue value,
  ) async {
    final snapshot = value.balanceSnapshots!;
    await context.push('/dashboard/categories', extra: {
      'currentBalance': snapshot.totalBalance,
      'snapshotId': snapshot.id,
    });
    ref.invalidate(balanceProvider);
  }

  Future<void> _openEarn(
    BuildContext context,
    WidgetRef ref,
    BalanceProviderValue value,
  ) async {
    final result = await showEarnSheet(context);
    if (result == null) return;

    final snapshot = value.balanceSnapshots!;
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
    BalanceProviderValue value,
  ) async {
    final result = await showSpendSheet(context);
    if (result == null) return;

    final snapshot = value.balanceSnapshots!;
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
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (value) {
          if (value.balanceSnapshots == null) {
            return Center(
              child: ElevatedButton(
                  onPressed: () => _openBalanceInput(context, ref),
                child: Text(l10n.dashboradCreateBank),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountUp(value: value.balanceSnapshots!.totalBalance),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          _openEarn(context, ref, value),
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(l10n.dashboardEarnTitle),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          _openSpend(context, ref, value),
                      icon: const Icon(Icons.remove_circle_outline),
                      label: Text(l10n.dashboardSpendTitle),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          _openModifyBalance(context, ref),
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.dashboardModifyBalance),
                    ),
                    const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () =>
                      _openManageCategories(context, ref, value),
                  icon: const Icon(Icons.category),
                  label: Text(l10n.dashboardManageCategories),
                ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
