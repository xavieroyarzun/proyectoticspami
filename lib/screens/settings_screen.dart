import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: ListView(
        children: const [

          ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text("Bluetooth"),
          ),

          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notificaciones"),
          ),

          ListTile(
            leading: Icon(Icons.security),
            title: Text("Privacidad"),
          ),
        ],
      ),
    );
  }
}