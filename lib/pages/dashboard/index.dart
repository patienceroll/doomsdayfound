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

    return balanceAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (value) {
        if (value.balanceSnapshots == null) {
          return _buildEmptyState(context, ref, l10n);
        }
        return _buildDashboard(context, ref, l10n, value);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.dashboradCreateBank,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openBalanceInput(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.dashboradCreateBank),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, AppLocalizations l10n, BalanceProviderValue value) {
    final theme = Theme.of(context);
    final snapshot = value.balanceSnapshots!;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _buildBalanceCard(context, ref, theme, l10n, value),
        const SizedBox(height: 20),
        _buildActionCards(context, ref, l10n, value),
        const SizedBox(height: 20),
        if (value.hasAccounts) _buildCategoryBreakdown(context, theme, l10n, snapshot.id),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, ThemeData theme, AppLocalizations l10n, BalanceProviderValue value) {
    final colorScheme = theme.colorScheme;
    final snapshot = value.balanceSnapshots!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.dashboardTitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CountUp(
            value: snapshot.totalBalance,
            decimals: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
            duration: const Duration(milliseconds: 800),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _MiniAction(
                icon: Icons.add_circle_outline,
                label: l10n.dashboardEarnTitle,
                onTap: () => _openEarn(context, ref, value),
                foregroundColor: Colors.white,
              ),
              const SizedBox(width: 12),
              _MiniAction(
                icon: Icons.remove_circle_outline,
                label: l10n.dashboardSpendTitle,
                onTap: () => _openSpend(context, ref, value),
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, WidgetRef ref, AppLocalizations l10n, BalanceProviderValue value) {
    return Row(
      children: [
        Expanded(child: _ActionCard(
          icon: Icons.edit_outlined,
          label: l10n.dashboardModifyBalance,
          onTap: () => _openModifyBalance(context, ref),
        )),
        const SizedBox(width: 12),
        Expanded(child: _ActionCard(
          icon: Icons.account_tree_outlined,
          label: l10n.dashboardManageCategories,
          onTap: () => _openManageCategories(context, ref, value),
        )),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, ThemeData theme, AppLocalizations l10n, int snapshotId) {
    return FutureBuilder<List<Account>>(
      future: getAccountsForSnapshot(snapshotId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final accounts = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardManageCategories,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...accounts.map((a) => _CategoryTile(
              name: a.name,
              balance: a.balance,
              theme: theme,
            )),
          ],
        );
      },
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color foregroundColor;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: foregroundColor.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.onSecondaryContainer, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final double balance;
  final ThemeData theme;

  const _CategoryTile({
    required this.name,
    required this.balance,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(name, style: theme.textTheme.bodyLarge),
              const Spacer(),
              Text(
                '¥ ${balance.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
