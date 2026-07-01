import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_data.dart';
import '../services/sensor_repository.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _repository = SensorRepository();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _repository.fetchTodayHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _repository.fetchTodayHistory();
    });
  }

  double _stressToValue(String? level) {
    switch (level) {
      case 'Alto':
        return 8;
      case 'Moderado':
        return 5;
      case 'Bajo':
        return 2;
      default:
        return 0;
    }
  }

  List<FlSpot> _buildHourlySpots(List<Map<String, dynamic>> rows) {
    final Map<int, List<double>> hourly = {};

    for (final row in rows) {
      final fecha = DateTime.tryParse(row['fecha_medicion'] ?? '');
      if (fecha == null) continue;
      final value = _stressToValue(row['nivel_riesgo']);
      hourly.putIfAbsent(fecha.hour, () => []).add(value);
    }

    final spots = hourly.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return FlSpot(e.key.toDouble(), avg);
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.currentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("En vivo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(child: ListTile(title: const Text("Frecuencia cardíaca"), subtitle: Text("${data.bpm ?? '--'} BPM"))),
            Card(child: ListTile(title: const Text("Temperatura"), subtitle: Text("${data.temperature?.toStringAsFixed(1) ?? '--'} °C"))),
            Card(child: ListTile(title: const Text("Estrés"), subtitle: Text(data.stressLevel ?? "Sin datos"))),

            const SizedBox(height: 24),
            const Text("Tu día (promedio de estrés por hora)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text("Error al cargar historial: ${snapshot.error}");
                }

                final rows = snapshot.data ?? [];
                if (rows.isEmpty) {
                  return const Text("Aún no hay registros guardados hoy.");
                }

                final spots = _buildHourlySpots(rows);

                return SizedBox(
                  height: 260,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 23,
                      minY: 0,
                      maxY: 9,
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 4,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 3,
                            getTitlesWidget: (value, meta) {
                              if (value == 2) return const Text("Bajo", style: TextStyle(fontSize: 10));
                              if (value == 5) return const Text("Mod.", style: TextStyle(fontSize: 10));
                              if (value == 8) return const Text("Alto", style: TextStyle(fontSize: 10));
                              return const Text("");
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.redAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.15)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}