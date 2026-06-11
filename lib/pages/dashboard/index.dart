import 'dart:async';
import 'dart:math';

import 'package:doomsdayfound/components/rolling_number.dart';
import 'package:flutter/material.dart';

import 'package:doomsdayfound/l10n/app_localizations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _value = 0;
  Timer? _timer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _value = _random.nextDouble() * 1000000;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashborardTitle)),
      body: Center(
        child: RollingNumber(
          value: _value,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
