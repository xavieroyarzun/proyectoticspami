import 'dart:async';
import 'dart:math';
import 'calibration_data.dart';
import '../models/sensor_data.dart';

class SensorSimulator {
  final Random _random = Random();

  final StreamController<SensorData> _controller =
  StreamController<SensorData>.broadcast();

  Stream<SensorData> get stream => _controller.stream;

  Timer? _timer;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final data = SensorData(
        bpm: 65 + _random.nextInt(50),
        temperature: 36 + (_random.nextDouble() * 1.5),

        // sin stressLevel — lo calcula BluetoothService
      );
      _controller.add(data);
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}