import 'package:flutter/material.dart';
import '../services/app_data.dart';
import 'ble_pairing_screen.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
// 👆 nada más aquí dentro — el StatefulWidget solo tiene createState()
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
    // 👇 el listener va aquí, dentro del initState de _SettingsScreenState
    FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = bluetoothService.connected;

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.bluetooth,
              color: isConnected ? Colors.blue : Colors.grey,
            ),
            title: const Text("Bluetooth"),
            subtitle: Text(isConnected ? "Conectado" : "Sin conexión"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlePairingScreen()),
              );
              setState(() {});
            },
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notificaciones"),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text("Privacidad"),
          ),
        ],
      ),
    );
  }
}