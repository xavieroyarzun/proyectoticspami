import 'dart:async';

import '../models/sensor_data.dart';

class BluetoothService {

  final StreamController<SensorData> _controller =
  StreamController<SensorData>.broadcast();

  Stream<SensorData> get stream =>
      _controller.stream;

  bool connected = false;

  Future<void> connect() async {

    connected = true;
  }

  Future<void> disconnect() async {

    connected = false;
  }

  void addSensorData(
      SensorData data,
      ) {
    _controller.add(data);
  }

  void dispose() {
    _controller.close();
  }
}