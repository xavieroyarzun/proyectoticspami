import 'dart:math';
import 'calibration_data.dart';

class StressCalculator {
  static String calculate(int? bpm, double? temperature, double? ax, double? ay, double? az) {
    double score = 0;

    if (bpm != null) {
      final diff = bpm - CalibrationData.baselineBpm;
      if (diff > 20) score += 2;
      else if (diff > 10) score += 1;
    }

    if (temperature != null) {
      final diff = temperature - CalibrationData.baselineTemperature;
      if (diff > 2) score += 2;
      else if (diff > 0.5) score += 1;
    }

    if (ax != null && ay != null && az != null) {
      final magnitude = sqrt(ax * ax + ay * ay + az * az);
      final deviation = (magnitude - 9.8).abs();
      if (deviation > 3) score += 2;
      else if (deviation > 1) score += 1;
    }

    if (score >= 4) return "Alto";
    if (score >= 2) return "Moderado";
    return "Bajo";
  }
}