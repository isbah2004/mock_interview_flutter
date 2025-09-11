import 'package:flutter/material.dart';

class HistoryStatModel {
  final String value;
  final String label;
  final IconData icon;
  final bool isPrimary;

  const HistoryStatModel({
    required this.value,
    required this.label,
    required this.icon,
    this.isPrimary = false,
  });

  factory HistoryStatModel.fromMap(Map<String, dynamic> map) {
    return HistoryStatModel(
      value: map['value']?.toString() ?? '',
      label: map['label'] ?? '',
      icon: _parseIcon(map['icon']),
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'label': label,
      'icon': icon.codePoint,
      'isPrimary': isPrimary,
    };
  }

  static IconData _parseIcon(dynamic icon) {
    if (icon is IconData) return icon;
    if (icon is int) return IconData(icon, fontFamily: 'MaterialIcons');

    // Default icon
    return Icons.analytics_outlined;
  }
}
