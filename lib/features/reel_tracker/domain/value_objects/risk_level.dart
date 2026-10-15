import 'package:flutter/material.dart';

enum RiskLevel {
  low,
  moderate,
  high,
  extreme;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Mindful';
      case RiskLevel.moderate:
        return 'Elevated';
      case RiskLevel.high:
        return 'High Dopamine';
      case RiskLevel.extreme:
        return 'Doomscrolling';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return const Color(0xFF10B981); // Emerald Green
      case RiskLevel.moderate:
        return const Color(0xFF3B82F6); // Blue
      case RiskLevel.high:
        return const Color(0xFFF59E0B); // Amber
      case RiskLevel.extreme:
        return const Color(0xFFEF4444); // Crimson
    }
  }

  String get advice {
    switch (this) {
      case RiskLevel.low:
        return 'Great control! You are watching intentionally.';
      case RiskLevel.moderate:
        return 'Consider putting your phone down soon.';
      case RiskLevel.high:
        return 'Dopamine loop detected. Take a 5-minute breather.';
      case RiskLevel.extreme:
        return 'Critical doomscroll alert! Disconnect immediately.';
    }
  }
}
