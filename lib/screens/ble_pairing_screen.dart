import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/app_data.dart';
import '../services/ble_sensor_source.dart';
class BlePairingScreen extends StatefulWidget {
  const BlePairingScreen({super.key});

  @override
  State<BlePairingScreen> createState() => _BlePairingScreenState();
}

class _BlePairingScreenState extends State<BlePairingScreen> {
  List<ScanResult> _results = [];
  bool _scanning = false;

  Future<void> _scan() async {
    setState(() { _scanning = true; _results = []; });
    final found = await bluetoothService.bleSource?.scanForDevices() ?? [];
    setState(() { _results = found; _scanning = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conectar dispositivo")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _scanning ? null : _scan,
            child: Text(_scanning ? "Buscando..." : "Buscar PulseGuard-ESP32"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  title: Text(r.device.platformName.isNotEmpty ? r.device.platformName : "Dispositivo sin nombre"),
                  subtitle: Text(r.device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await bluetoothService.bleSource?.connectToDevice(r.device);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text("Conectar"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}