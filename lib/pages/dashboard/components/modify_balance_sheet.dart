import 'package:flutter/material.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/util/money/input_formatter.dart';

Future<double?> showModifyBalanceSheet(BuildContext context) {
  return showDialog<double>(
    context: context,
    builder: (_) => const _ModifyBalanceSheet(),
  );
}

class _ModifyBalanceSheet extends StatefulWidget {
  const _ModifyBalanceSheet();

  @override
  State<_ModifyBalanceSheet> createState() => _ModifyBalanceSheetState();
}

class _ModifyBalanceSheetState extends State<_ModifyBalanceSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final value = double.tryParse(_controller.text) ?? 0;
    Navigator.of(context).pop(value);
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
                      l10n.dashboardModifyBalance,
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
                controller: _controller,
                decoration: InputDecoration(
                  labelText: l10n.dashboardBalanceInputTotalHint,
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
