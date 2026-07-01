import 'dart:async';
import '../models/sensor_data.dart';
import 'sensor_simulator.dart';
import 'mqtt_sensor_bridge.dart';
import 'stress_calculator.dart';
import 'ble_sensor_source.dart';
enum DataSourceMode { simuladoLocal, nodeRedMqtt, bluetoothReal }

class BluetoothService {
  // Único valor a cambiar según la etapa del proyecto
  //static const DataSourceMode mode = DataSourceMode.bluetoothReal;
  static const DataSourceMode mode = DataSourceMode.nodeRedMqtt;

  final StreamController<SensorData> _controller =
  StreamController<SensorData>.broadcast();
  Stream<SensorData> get stream => _controller.stream;

  SensorData? lastData;
  bool get connected {
    switch (mode) {
      case DataSourceMode.bluetoothReal:
        return _bleSource?.isConnected ?? false; // solo true si hay BLE real
      case DataSourceMode.nodeRedMqtt:
      case DataSourceMode.simuladoLocal:
        return false; // nunca hay dispositivo físico en estos modos
    }
  }

  SensorSimulator? _simulator;
  MqttSensorBridge? _mqttBridge;
  BleSensorSource? _bleSource;

  BleSensorSource? get bleSource => _bleSource;
  Future<void> connect() async {
    if (connected) return;

    switch (mode) {
      case DataSourceMode.simuladoLocal:
        _simulator = SensorSimulator();
        _simulator!.stream.listen(_emit);
        _simulator!.start();
        break;

      case DataSourceMode.nodeRedMqtt:
        _mqttBridge = MqttSensorBridge(onData: _emit);
        await _mqttBridge!.connect();
        break;

      case DataSourceMode.bluetoothReal:
        _bleSource = BleSensorSource(onData: _emit);
        break;
    }

  }

  Future<void> disconnect() async {
    _simulator?.dispose();
    await _mqttBridge?.disconnect();
    await _bleSource?.disconnect();

  }

  void _emit(SensorData raw) {
    print('📤 BluetoothService _emit: bpm=${raw.bpm} temp=${raw.temperature}');
    final data = SensorData(
      bpm: raw.bpm,
      temperature: raw.temperature,

      ax: raw.ax,
      stressLevel: StressCalculator.calculate(raw.bpm, raw.temperature, raw.ax, raw.ay, raw.az), // 👈 nuevo, sin cálculo, solo se transporta
      ay: raw.ay, // 👈 nuevo
      az: raw.az, // 👈 nuevo
    );
    lastData = data;
    _controller.add(data);
  }

  void addSensorData(SensorData data) => _emit(data);

  void dispose() => _controller.close();
}