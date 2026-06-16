import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doomsdayfound/database/db_helper.dart';
import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/providers/balance_provider.dart';
import 'package:doomsdayfound/util/money/input_formatter.dart';

class _CategoryRow {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _CategoryRow({String name = '', double amount = 0})
    : nameController = TextEditingController(text: name),
      amountController = TextEditingController(text: amount > 0 ? amount.toStringAsFixed(2) : '');

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class ManageCategoriesPage extends ConsumerStatefulWidget {
  final double currentBalance;
  final int snapshotId;

  const ManageCategoriesPage({
    super.key,
    required this.currentBalance,
    required this.snapshotId,
  });

  @override
  ConsumerState<ManageCategoriesPage> createState() => ManageCategoriesPageState();
}

class ManageCategoriesPageState extends ConsumerState<ManageCategoriesPage> {
  int _editingIndex = -1;
  List<_CategoryRow> _rows = [];

  double get _allocatedSum {
    double sum = 0;
    for (final row in _rows) {
      final amount = double.tryParse(row.amountController.text);
      if (amount != null && amount > 0) sum += amount;
    }
    return sum;
  }

  double get _remainingBalance => widget.currentBalance - _allocatedSum;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final accounts = await getAccountsForSnapshot(widget.snapshotId);
    if (!mounted) return;
    setState(() {
      _rows = accounts
          .map((a) => _CategoryRow(name: a.name, amount: a.balance))
          .toList();
    });
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    final index = _rows.length;
    setState(() {
      _rows.add(_CategoryRow());
      _editingIndex = index;
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
      if (_editingIndex == index) _editingIndex = -1;
    });
  }

  bool _validate() {
    for (final row in _rows) {
      if (row.nameController.text.trim().isEmpty) return false;
      final amount = double.tryParse(row.amountController.text);
      if (amount == null || amount <= 0) return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.prompt),
            content: Text(l10n.dashboardBalanceInputRequired),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
      }
      return;
    }

    final categories = _rows
        .where((r) => r.nameController.text.trim().isNotEmpty)
        .map((r) => (
          name: r.nameController.text.trim(),
          balance: double.tryParse(r.amountController.text) ?? 0,
          type: 0,
        ))
        .toList();

    if (categories.isNotEmpty) {
      await replaceAccountsForSnapshot(
        snapshotId: widget.snapshotId,
        accounts: categories,
      );
    }

    ref.invalidate(balanceProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardManageCategories),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _rows.isEmpty
                  ? Center(child: Text(l10n.dashboardBalanceInputAddCategory))
                  : ScrollConfiguration(
                      behavior: MaterialScrollBehavior().copyWith(overscroll: false),
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: _rows.length,
                        itemBuilder: (context, index) => _buildRow(index, l10n),
                      ),
                    ),
            ),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: Text(l10n.dashboardBalanceInputAddCategory),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dashboardUnallocated),
                Text(
                  '¥ ${_remainingBalance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _remainingBalance >= 0
                        ? null
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(l10n.dashboardBalanceInputConfirm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int index, AppLocalizations l10n) {
    final row = _rows[index];
    final isEditing = _editingIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: isEditing
                  ? TextFormField(
                      controller: row.nameController,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardBalanceInputCategoryName,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    )
                  : Text(
                      row.nameController.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: isEditing
                  ? TextFormField(
                      controller: row.amountController,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardBalanceInputAmount,
                        prefixText: '¥ ',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [AmountInputFormatter()],
                      onChanged: (_) => setState(() {}),
                    )
                  : Text(
                      '¥ ${double.tryParse(row.amountController.text)?.toStringAsFixed(2) ?? '0.00'}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.check, size: 20),
                onPressed: () => setState(() => _editingIndex = -1),
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => setState(() => _editingIndex = index),
              ),
              if (_rows.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error),
                  onPressed: () => _removeRow(index),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
