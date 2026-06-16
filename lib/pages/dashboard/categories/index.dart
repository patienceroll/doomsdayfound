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
  final _formKey = GlobalKey<FormState>();
  List<_CategoryRow> _rows = [];

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
    setState(() => _rows.add(_CategoryRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

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
        child: Form(
          key: _formKey,
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
      ),
    );
  }

  Widget _buildRow(int index, AppLocalizations l10n) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row.nameController,
              decoration: InputDecoration(
                labelText: l10n.dashboardBalanceInputCategoryName,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.dashboardBalanceInputRequired
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row.amountController,
              decoration: InputDecoration(
                labelText: l10n.dashboardBalanceInputAmount,
                prefixText: '¥ ',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [AmountInputFormatter()],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.dashboardBalanceInputRequired;
                }
                final amount = double.tryParse(v);
                if (amount == null) {
                  return l10n.dashboardBalanceInputInvalidAmount;
                }
                return null;
              },
            ),
          ),
          if (_rows.length > 1)
            InkWell(
              onTap: () => _removeRow(index),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
