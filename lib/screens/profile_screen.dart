import 'package:flutter/material.dart';
import '../services/user_data.dart';
import '../services/calibration_data.dart';
import '../services/preferences_service.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  void editName() {

    final controller = TextEditingController(
      text: UserData.userName,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cambiar nombre"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nombre",
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () {

              setState(() {
                UserData.userName =
                    controller.text.trim();
              });

              PreferencesService.saveUserName();

              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              UserData.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),

              label: const Text(
                "Editar nombre",
              ),

              onPressed: editName,
            ),
          ),
          const SizedBox(height: 30),

          const Card(
            child: ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text("Estado Bluetooth"),
              subtitle: Text("Conectado (Simulado)"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("BPM Base"),
              subtitle: Text(
                "${CalibrationData.baselineBpm}",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.thermostat),
              title: const Text("Temperatura Base"),
              subtitle: Text(
                "${CalibrationData.baselineTemperature.toStringAsFixed(1)} °C",
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.speed),
              title: const Text("GSR Base"),

            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text("Servidor"),
              subtitle: Text("Conectado (Simulado)"),
            ),
          ),
        ],
      ),
    );
  }
}