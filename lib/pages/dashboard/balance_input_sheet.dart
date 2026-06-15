import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';

class BalanceInputResult {
  final double totalBalance;
  final List<CategoryEntry>? categories;

  const BalanceInputResult({required this.totalBalance, this.categories});
}

class CategoryEntry {
  final String name;
  final double balance;
  final int type;

  const CategoryEntry({
    required this.name,
    required this.balance,
    this.type = 0,
  });
}

Future<BalanceInputResult?> showBalanceInputSheet(BuildContext context) {
  return showModalBottomSheet<BalanceInputResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _BalanceInputSheet(),
  );
}

class _CategoryRow {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _CategoryRow() : nameController = TextEditingController(),
                   amountController = TextEditingController();

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final regex = RegExp(r'^\d+\.?\d{0,2}$');
    if (regex.hasMatch(text)) return newValue;

    final dotIndex = text.indexOf('.');
    if (dotIndex == -1) {
      return TextEditingValue(
        text: text.replaceAll(RegExp(r'[^\d]'), ''),
        selection: newValue.selection,
      );
    }

    final integerPart = text.substring(0, dotIndex).replaceAll(RegExp(r'[^\d]'), '');
    final decimalPart = text.substring(dotIndex + 1).replaceAll(RegExp(r'[^\d]'), '');
    final finalText = '$integerPart.${decimalPart.substring(0, decimalPart.length.clamp(0, 2))}';
    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}

class _BalanceInputSheet extends ConsumerStatefulWidget {
  const _BalanceInputSheet();

  @override
  ConsumerState<_BalanceInputSheet> createState() => _BalanceInputSheetState();
}

class _BalanceInputSheetState extends ConsumerState<_BalanceInputSheet> {
  int _mode = 0;
  final _totalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _rows = <_CategoryRow>[];

  @override
  void dispose() {
    _totalController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  double get _categorySum {
    double sum = 0;
    for (final row in _rows) {
      if (row.nameController.text.trim().isEmpty) continue;
      final amount = double.tryParse(row.amountController.text);
      if (amount != null && amount > 0) sum += amount;
    }
    return sum;
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

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == 0) {
      final total = double.tryParse(_totalController.text) ?? 0;
      Navigator.of(context).pop(BalanceInputResult(totalBalance: total));
    } else {
      if (_rows.isEmpty) return;
      final categories = _rows
          .where((r) => r.nameController.text.trim().isNotEmpty)
          .map((r) => CategoryEntry(
                name: r.nameController.text.trim(),
                balance: double.tryParse(r.amountController.text) ?? 0,
              ))
          .toList();
      final total = categories.fold<double>(
        0,
        (sum, c) => sum + c.balance,
      );
      Navigator.of(context).pop(
        BalanceInputResult(totalBalance: total, categories: categories),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.dashboardBalanceInputTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(l10n.dashboardBalanceInputModeTotal),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(l10n.dashboardBalanceInputModeCategory),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() => _mode = v.first),
              ),
            ),
            const SizedBox(height: 8),
            if (_mode == 0)
              _buildTotalMode(l10n)
            else
              _buildCategoryMode(l10n),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalMode(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _totalController,
        decoration: InputDecoration(
          labelText: l10n.dashboardBalanceInputTotalHint,
          prefixText: '¥ ',
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_AmountInputFormatter()],
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? l10n.dashboardBalanceInputRequired : null,
        autofocus: true,
        onFieldSubmitted: (_) => _confirm(),
      ),
    );
  }

  Widget _buildCategoryMode(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_rows.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _rows.length,
              itemBuilder: (context, index) => _buildCategoryRow(index, l10n),
            ),
          ),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add),
          label: Text(l10n.dashboardBalanceInputAddCategory),
        ),
        if (_rows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dashboardBalanceInputTotal,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '¥ ${_categorySum.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton(
            onPressed: (_rows.isNotEmpty) ? _confirm : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(l10n.dashboardBalanceInputConfirm),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(int index, AppLocalizations l10n) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: row.nameController,
              decoration: InputDecoration(
                labelText: l10n.dashboardBalanceInputCategoryName,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_AmountInputFormatter()],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.dashboardBalanceInputRequired;
                }
                final amount = double.tryParse(v);
                if (amount == null || amount <= 0) {
                  return l10n.dashboardBalanceInputInvalidAmount;
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_rows.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _removeRow(index),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
