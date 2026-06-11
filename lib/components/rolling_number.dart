import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RollingNumber extends StatelessWidget {
  final double value;
  final double initialValue;
  final String separator;
  final int decimals;
  final Duration duration;
  final TextStyle? style;
  final Curve curve;

  const RollingNumber({
    super.key,
    required this.value,
    this.initialValue = 0,
    this.separator = ',',
    this.decimals = 0,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: initialValue, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final locale = Localizations.localeOf(context);
        final formatted = _formatNumber(animatedValue, locale.toString());
        return Text(formatted, style: style);
      },
    );
  }

  String _formatNumber(double value, String locale) {
    final formatter = NumberFormat(
      '#,##0${decimals > 0 ? '.' : ''}${'0' * decimals}',
      locale,
    );
    return formatter.format(value);
  }
}
