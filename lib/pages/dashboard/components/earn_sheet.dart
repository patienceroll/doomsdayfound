import 'package:flutter/material.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/util/money/input_formatter.dart';

Future<({double amount, String? remark})?> showEarnSheet(BuildContext context) {
  return showDialog<({double amount, String? remark})>(
    context: context,
    builder: (_) => const _EarnSheet(),
  );
}

class _EarnSheet extends StatefulWidget {
  const _EarnSheet();

  @override
  State<_EarnSheet> createState() => _EarnSheetState();
}

class _EarnSheetState extends State<_EarnSheet> {
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
    final remark = _remarkController.text.trim();
    Navigator.of(context).pop((amount: amount, remark: remark.isEmpty ? null : remark));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.dashboardEarnTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.dashboardEarnHint,
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: l10n.dashboardSpendRemark,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _confirm,
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
}
