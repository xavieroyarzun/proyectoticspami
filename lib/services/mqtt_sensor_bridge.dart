import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor_data.dart';

class MqttSensorBridge {
  final void Function(SensorData) onData;
  MqttSensorBridge({required this.onData});

  static const String topic = 'pami/sensors';
  late MqttServerClient _client;

  Future<void> connect() async {
    _client = MqttServerClient(
      '10.0.2.2', // 👈 en vez de 'broker.hivemq.com' — apunta a localhost de TU PC
      'pami_${DateTime.now().millisecondsSinceEpoch}',
    );
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;

    try {
      await _client.connect();

    } catch (_) {
      _client.disconnect();
      rethrow;
    }

    _client.subscribe(topic, MqttQos.atMostOnce);


    _client.updates!.listen((events) {

      final msg = events[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);

      final json = jsonDecode(payload) as Map<String, dynamic>;

      onData(SensorData(
        bpm: json['bpm'] as int?,
        temperature: (json['temperature'] as num?)?.toDouble(),

        ax: (json['ax'] as num?)?.toDouble(), // 👈 nuevo
        ay: (json['ay'] as num?)?.toDouble(), // 👈 nuevo
        az: (json['az'] as num?)?.toDouble(), // 👈 nuevo
      ));
    });
  }

  Future<void> disconnect() async => _client.disconnect();
}