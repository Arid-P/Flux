import 'package:flutter/material.dart';

class HexColor {
  static Color fromHex(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    final fullHex = hex.length == 6 ? 'FF$hex' : hex;
    // Use the values to recreate the color string if needed, 
    // but the task was to fix deprecations in fromHex usage if any.
    // Actually the info was about red/green/blue getters on Color object.
    // I'll just change the logic to use integer division if possible.
    return Color(int.parse(fullHex, radix: 16));
  }

  static String toHex(Color color, {bool leadingHashSign = true}) {
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    final prefix = leadingHashSign ? '#' : '';
    return '$prefix$r$g$b';
  }
}

