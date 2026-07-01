import 'package:flutter/material.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() =>
      _EmergencyScreenState();
}

class _EmergencyScreenState
    extends State<EmergencyScreen> {

  bool autoSOS = true;
  bool shareLocation = true;
  bool notifyContact = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configuración de Emergencia",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          const Icon(
            Icons.emergency,
            color: Colors.orange,
            size: 100,
          ),

          const SizedBox(height: 20),

          const Text(
            "Opciones SOS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SwitchListTile(
            title: const Text(
              "Activar SOS automático",
            ),
            subtitle: const Text(
              "Enviar alerta cuando se detecte estrés extremo",
            ),
            value: autoSOS,
            onChanged: (value) {
              setState(() {
                autoSOS = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
              "Compartir ubicación",
            ),
            subtitle: const Text(
              "Incluir ubicación en la alerta",
            ),
            value: shareLocation,
            onChanged: (value) {
              setState(() {
                shareLocation = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
              "Notificar contacto principal",
            ),
            subtitle: const Text(
              "Enviar alerta al contacto registrado",
            ),
            value: notifyContact,
            onChanged: (value) {
              setState(() {
                notifyContact = value;
              });
            },
          ),

          const SizedBox(height: 20),

          const Card(
            child: ListTile(
              leading: Icon(Icons.phone),
              title: Text("Contacto de emergencia"),
              subtitle: Text("+56 9 XXXX XXXX"),
            ),
          ),
        ],
      ),
    );
  }
}