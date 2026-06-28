import 'dart:async';
import 'dart:math';
import 'calibration_data.dart';
import '../models/sensor_data.dart';
import 'app_data.dart';
class SensorSimulator {
  final Random _random = Random();

  final StreamController<SensorData> _controller =
  StreamController<SensorData>.broadcast();

  Stream<SensorData> get stream => _controller.stream;

  Timer? _timer;

  void start() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
          (_) {
        final bpm = 65 + _random.nextInt(50);

        final temp =
            36 + (_random.nextDouble() * 1.5);

        final gsr =
            300 + _random.nextInt(400);

        final bpmDiff =
            bpm - CalibrationData.baselineBpm;

        final tempDiff =
            temp - CalibrationData.baselineTemperature;

        final gsrDiff =
            gsr - CalibrationData.baselineGsr;

        double score = 0;

        if (bpmDiff > 20) score += 2;
        else if (bpmDiff > 10) score += 1;

        if (tempDiff > 0.5) score += 1;

        if (gsrDiff > 150) score += 2;
        else if (gsrDiff > 75) score += 1;

        String stress;

        if (score >= 4) {
          stress = "Alto";
        } else if (score >= 2) {
          stress = "Moderado";
        } else {
          stress = "Bajo";
        }

        final data = SensorData(
          bpm: bpm,
          temperature: temp,
          gsr: gsr,
          stressLevel: stress,
        );

        _controller.add(data);

        bluetoothService.addSensorData(data);
      },
    );
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}