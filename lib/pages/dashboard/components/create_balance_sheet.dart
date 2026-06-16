import 'package:flutter/material.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';
import 'package:doomsdayfound/util/money/input_formatter.dart';

Future<double?> showCreateBalanceSheet(BuildContext context) {
  return showDialog<double>(
    context: context,
    builder: (_) => const _CreateBalanceSheet(),
  );
}

class _CreateBalanceSheet extends StatefulWidget {
  const _CreateBalanceSheet();

  @override
  State<_CreateBalanceSheet> createState() => _CreateBalanceSheetState();
}

class _CreateBalanceSheetState extends State<_CreateBalanceSheet> {
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
              Padding(
                padding: const EdgeInsets.only(left: 12),
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
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
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
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.dashboardBalanceInputRequired
                      : null,
                  onFieldSubmitted: (_) => _confirm(),
                ),
              ),
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}
