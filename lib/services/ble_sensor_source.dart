import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_data.dart';

class BleSensorSource {
  static final Guid serviceUuid = Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b');
  static final Guid bpmCharUuid = Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8');
  static final Guid tempCharUuid = Guid('ac4d92d1-3df0-4e1d-8f5e-1a2b3c4d5e6f');
  static final Guid accelCharUuid = Guid('9e8f7a6b-5c4d-3e2f-1a0b-9c8d7e6f5a4b');

  final void Function(SensorData) onData;
  BleSensorSource({required this.onData});

  BluetoothDevice? _device;
  final List<StreamSubscription> _subs = [];

  // último valor conocido de cada sensor — se va llenando independiente
  int? _lastBpm;
  double? _lastTemp;
  double? _lastAx, _lastAy, _lastAz;
  bool isConnected = false;
  Future<void> connectToDevice(BluetoothDevice device) async {
    _device = device;
    await device.connect();
    isConnected = true;
    final services = await device.discoverServices();
    final service = services.firstWhere((s) => s.uuid == serviceUuid);

    final bpmChar = service.characteristics.firstWhere((c) => c.uuid == bpmCharUuid);
    final tempChar = service.characteristics.firstWhere((c) => c.uuid == tempCharUuid);
    final accelChar = service.characteristics.firstWhere((c) => c.uuid == accelCharUuid);

    await bpmChar.setNotifyValue(true);
    await tempChar.setNotifyValue(true);
    await accelChar.setNotifyValue(true);

    _subs.add(bpmChar.lastValueStream.listen(_onBpmPacket));
    _subs.add(tempChar.lastValueStream.listen(_onTempPacket));
    _subs.add(accelChar.lastValueStream.listen(_onAccelPacket));
  }

  void _onBpmPacket(List<int> bytes) {
    print('📡 BPM bytes recibidos: $bytes');
    if (bytes.length < 2) return;
    _lastBpm = ByteData.sublistView(Uint8List.fromList(bytes)).getInt16(0, Endian.little);
    print('💓 BPM parseado: $_lastBpm');
    _emitMerged();
  }

  void _onTempPacket(List<int> bytes) {
    print('📡 TEMP bytes recibidos: $bytes');
    if (bytes.length < 4) return;
    _lastTemp = ByteData.sublistView(Uint8List.fromList(bytes)).getFloat32(0, Endian.little);
    print('🌡️ Temp parseada: $_lastTemp');
    _emitMerged();
  }

  void _onAccelPacket(List<int> bytes) {
    print('📡 ACCEL bytes recibidos: $bytes');
    if (bytes.length < 12) return;
    final buffer = ByteData.sublistView(Uint8List.fromList(bytes));
    _lastAx = buffer.getFloat32(0, Endian.little);
    _lastAy = buffer.getFloat32(4, Endian.little);
    _lastAz = buffer.getFloat32(8, Endian.little);
    print('📐 Accel parseado: ax=$_lastAx ay=$_lastAy az=$_lastAz');
    _emitMerged();
  }

  void _emitMerged() {
    print('🔀 emitMerged: bpm=$_lastBpm temp=$_lastTemp ax=$_lastAx');
    onData(SensorData(
      bpm: _lastBpm,
      temperature: _lastTemp,
      ax: _lastAx,
      ay: _lastAy,
      az: _lastAz,
    ));
  }

  Future<void> disconnect() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _device?.disconnect();
    isConnected = false;
  }

  Future<List<ScanResult>> scanForDevices({Duration timeout = const Duration(seconds: 5)}) async {
    final results = <ScanResult>[];
    final sub = FlutterBluePlus.scanResults.listen((batch) {
      for (final r in batch) {
        if (r.advertisementData.serviceUuids.contains(serviceUuid) &&
            !results.any((e) => e.device.remoteId == r.device.remoteId)) {
          results.add(r);
        }
      }
    });

    await FlutterBluePlus.startScan(
      withServices: [serviceUuid], // 👈 filtra por UUID directamente
      timeout: timeout,
    );
    await Future.delayed(timeout);
    await sub.cancel();
    return results;




  }

}