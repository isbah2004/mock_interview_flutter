import 'package:flutter/material.dart';

/// Compatibility helpers to avoid deprecated Color APIs.
extension ColorCompat on Color {
  Color withOpacityCompat(double opacity) {
    // Use the explicit toARGB32 conversion to avoid deprecated accessors.
    final int v = toARGB32(); // ARGB 32-bit integer representation
    final int r = (v >> 16) & 0xFF;
    final int g = (v >> 8) & 0xFF;
    final int b = v & 0xFF;
    return Color.fromRGBO(r, g, b, opacity);
  }
}
