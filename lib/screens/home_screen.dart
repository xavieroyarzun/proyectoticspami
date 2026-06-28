import 'package:flutter/material.dart';
import '../widgets/stress_chart.dart';
import '../widgets/dashboard_button.dart';
import '../services/sensor_simulator.dart';
import '../models/sensor_data.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_data.dart';
import 'profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final simulator = SensorSimulator();
  List<FlSpot> stressHistory = [
    const FlSpot(0, 5),
  ];
  SensorData currentData = SensorData(
    bpm: 75,
    temperature: 36.5,
    gsr: 400,
    stressLevel: "Bajo",
  );

  @override
  void initState() {
    super.initState();

    simulator.start();

    simulator.stream.listen((data) {

      setState(() {

        currentData = data;
        AppData.currentData = data;
        double stressValue;

        if (data.stressLevel == "Alto") {
          stressValue = 8;
        } else if (data.stressLevel == "Moderado") {
          stressValue = 5;
        } else {
          stressValue = 2;
        }

        stressHistory.add(
          FlSpot(
            stressHistory.length.toDouble(),
            stressValue,
          ),
        );

        if (stressHistory.length > 10) {
          stressHistory.removeAt(0);

          for (int i = 0; i < stressHistory.length; i++) {
            stressHistory[i] = FlSpot(
              i.toDouble(),
              stressHistory[i].y,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    simulator.dispose();
    super.dispose();
  }
  void showSOSDialog() {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("SOS"),

        content: const Text(
          "¿Deseas activar la alerta de emergencia?",
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

              Navigator.pop(context);

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Alerta SOS enviada (simulación)",
                  ),
                ),
              );
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white70,

        onTap: (index) {

          if (index == 1) {
            showSOSDialog();
          }

          if (index == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              const SizedBox(height: 10),

              SizedBox(
                height: 220,
                child: Row(
                  children: [

                    Container(
                      width: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: Container(color: Colors.red)),
                          Expanded(child: Container(color: Colors.orange)),
                          Expanded(child: Container(color: Colors.amber)),
                          Expanded(child: Container(color: Colors.green)),
                          Expanded(child: Container(color: Colors.teal)),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: StressChart(
                        points: stressHistory,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff1D1D1D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: Colors.amber,
                      size: 45,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Estrés: ${currentData.stressLevel}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            currentData.stressLevel == "Alto"
                                ? "Se recomienda una pausa inmediata."
                                : currentData.stressLevel == "Moderado"
                                ? "Se recomienda descansar."
                                : "Estado normal.",
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),


              const SizedBox(height: 15),

              Text(
                "BPM: ${currentData.bpm}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Temperatura: ${currentData.temperature.toStringAsFixed(1)} °C",
              ),

              Text(
                "GSR: ${currentData.gsr}",
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [

                    DashboardButton(
                      icon: Icons.bar_chart,
                      color: Colors.green,
                      title: "Estadísticas",
                      onTap: () {
                        Navigator.pushNamed(context, "/stats");
                      },
                    ),

                    DashboardButton(
                      icon: Icons.contact_phone,
                      color: Colors.orange,
                      title: "Emergencia",
                      onTap: () {
                        Navigator.pushNamed(context, "/emergency");
                      },
                    ),

                    DashboardButton(
                      icon: Icons.gps_fixed,
                      color: Colors.tealAccent,
                      title: "Calibrar",
                      onTap: () {
                        Navigator.pushNamed(context, "/calibration");
                      },
                    ),

                    DashboardButton(
                      icon: Icons.settings,
                      color: Colors.red,
                      title: "Ajustes",
                      onTap: () {
                        Navigator.pushNamed(context, "/settings");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}