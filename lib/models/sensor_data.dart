class SensorData {
  final int? bpm;
  final double? temperature;
  final String? stressLevel;
  final double? ax; // 👈 nuevo
  final double? ay; // 👈 nuevo
  final double? az; // 👈 nuevo
  SensorData({
    this.bpm,
    this.temperature,
    this.stressLevel,
    this.ax,
    this.ay,
    this.az,
  });
  // Útil para la UI: saber qué sensores trajeron datos
  bool get hasHeartRate => bpm != null;
  bool get hasTemperature => temperature != null;

}