import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A currency amount display using JetBrains Mono with optional color coding.
class AmountDisplay extends StatelessWidget {
  final double amount;
  final double? fontSize;
  final Color? color;
  final FontWeight fontWeight;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );

    // Format amount with 2 decimal places
    final formatted = amount.toStringAsFixed(2);

    return Text(formatted, style: textStyle);
  }
}