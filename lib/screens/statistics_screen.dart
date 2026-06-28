import 'package:flutter/material.dart';
import '../services/app_data.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}
class _StatisticsScreenState
    extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {

    final data = AppData.currentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Card(
            child: ListTile(
              title: const Text(
                "Frecuencia cardíaca",
              ),
              subtitle: Text(
                "${data.bpm} BPM",
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text(
                "Temperatura",
              ),
              subtitle: Text(
                "${data.temperature.toStringAsFixed(1)} °C",
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text(
                "GSR",
              ),
              subtitle: Text(
                "${data.gsr}",
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text(
                "Estrés",
              ),
              subtitle: Text(
                data.stressLevel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
