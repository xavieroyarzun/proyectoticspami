import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/app_data.dart';
import '../services/calibration_data.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() =>
      _CalibrationScreenState();
}

class _CalibrationScreenState
    extends State<CalibrationScreen> {

  void calibrate() {
    final data = AppData.currentData;

    if (data.bpm != null) CalibrationData.baselineBpm = data.bpm!;
    if (data.temperature != null) CalibrationData.baselineTemperature = data.temperature!;


    CalibrationData.calibrated = true;
    PreferencesService.saveCalibration();
    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Calibración completada",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calibración",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              "Valores Base",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "BPM Base: ${CalibrationData.baselineBpm}",
            ),

            Text(
              "Temperatura Base: "
                  "${CalibrationData.baselineTemperature.toStringAsFixed(1)} °C",
            ),



            //const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.tune,
              ),

              label: const Text(
                "Calibrar Ahora",
              ),

              onPressed: calibrate,
            ),

            const SizedBox(height: 20),

            Text(
              CalibrationData.calibrated
                  ? "Estado: Calibrado"
                  : "Estado: Sin calibrar",
            ),
          ],
        ),
      ),
    );
  }
}