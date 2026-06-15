import 'package:flutter/material.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/util/money/input_formatter.dart';

Future<double?> showSpendSheet(BuildContext context) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _SpendSheet(),
  );
}

class _SpendSheet extends StatefulWidget {
  const _SpendSheet();

  @override
  State<_SpendSheet> createState() => _SpendSheetState();
}

class _SpendSheetState extends State<_SpendSheet> {
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text) ?? 0;
    Navigator.of(context).pop(amount);
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
                      l10n.dashboardSpendTitle,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.dashboardSpendHint,
                  prefixText: '¥ ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [AmountInputFormatter()],
                autofocus: true,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: l10n.dashboardSpendRemark,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: _confirm,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(l10n.dashboardBalanceInputConfirm),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
