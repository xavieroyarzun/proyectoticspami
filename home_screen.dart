import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';
import '../services/app_data.dart';
import 'sos_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SensorData currentData = SensorData(
    bpm: 75,
    temperature: 36.5,
    stressLevel: "Bajo",
  );

  final List<FlSpot> _bpmHistory = [const FlSpot(0, 75)];
  int _bpmIndex = 1;

  @override
  void initState() {
    super.initState();
    bluetoothService.stream.listen((data) {
      if (!mounted) return;
      setState(() {
        currentData = data;
        if (data.bpm != null) {
          _bpmHistory.add(FlSpot(_bpmIndex.toDouble(), data.bpm!.toDouble()));
          _bpmIndex++;
          if (_bpmHistory.length > 20) _bpmHistory.removeAt(0);
        }
      });
    });
  }

  String _activityLabel(double? ax, double? ay, double? az) {
    if (ax == null || ay == null || az == null) return "Sin datos";
    final magnitude = sqrt(ax * ax + ay * ay + az * az);
    final deviation = (magnitude - 9.8).abs();
    if (deviation > 3) return "Movimiento intenso";
    if (deviation > 1) return "Caminata tranquila";
    return "En reposo";
  }

  IconData _activityIcon(double? ax, double? ay, double? az) {
    if (ax == null || ay == null || az == null) return Icons.device_unknown;
    final magnitude = sqrt(ax * ax + ay * ay + az * az);
    final deviation = (magnitude - 9.8).abs();
    if (deviation > 3) return Icons.directions_run;
    if (deviation > 1) return Icons.directions_walk;
    return Icons.airline_seat_recline_normal;
  }

  Color _stressColor(String? level) {
    if (level == 'Alto') return Colors.red;
    if (level == 'Moderado') return Colors.orange;
    return const Color(0xFF4CAF50);
  }

  String _greeting(String? level) {
    if (level == 'Alto') return "Hola, necesitas un descanso.";
    if (level == 'Moderado') return "Hola, intenta relajarte.";
    return "Hola, todo está bien.";
  }
  void _showHardwareTestDialog(String component) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Probar $component"),
        content: Text(
          bluetoothService.connected
              ? "Enviando comando de prueba al dispositivo..."
              : "No hay dispositivo conectado. Conéctate desde Ajustes → Bluetooth.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }
  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Activar SOS"),
        content: const Text("¿Deseas activar la alerta de emergencia?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen()));
            },
            child: const Text("Activar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stress = currentData.stressLevel ?? "Bajo";
    final stressColor = _stressColor(stress);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Text(
                _greeting(stress),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, color: stressColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Nivel de estrés: $stress",
                    style: TextStyle(color: stressColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tarjetas superiores
              Row(
                children: [
                  Expanded(child: _StatCard(
                    icon: Icons.thermostat,
                    iconColor: Colors.orange,
                    label: "TEMPERATURA",
                    value: "${currentData.temperature?.toStringAsFixed(1) ?? '--'}°C",
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: Icons.bluetooth,
                    iconColor: bluetoothService.connected ? Colors.blue : Colors.grey,
                    label: "DISPOSITIVO",
                    value: bluetoothService.connected ? "Conectado" : "Sin conexión",
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: Icons.bolt,
                    iconColor: stressColor,
                    label: "ESTRÉS",
                    value: stress,
                    valueColor: stressColor,
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Tarjeta BPM con gráfica
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text("RITMO CARDÍACO",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${currentData.bpm ?? '--'}",
                          style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 4),
                          child: Text("lpm", style: TextStyle(fontSize: 16, color: Colors.black45)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: _bpmHistory.length < 2
                          ? const Center(child: Text("Esperando datos...", style: TextStyle(color: Colors.black38)))
                          : LineChart(
                        LineChartData(
                          minY: 40, maxY: 160,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _bpmHistory,
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.0)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta Actividad (acelerómetro)
              _InfoCard(
                icon: _activityIcon(currentData.ax, currentData.ay, currentData.az),
                iconColor: Colors.purple,
                label: "ACTIVIDAD",
                value: _activityLabel(currentData.ax, currentData.ay, currentData.az),
              ),
              const SizedBox(height: 16),

              // Sección de navegación
              const Text("Opciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _NavCard(icon: Icons.bar_chart, color: Colors.green, label: "Estadísticas",
                      onTap: () => Navigator.pushNamed(context, "/stats")),
                  _NavCard(icon: Icons.contact_phone, color: Colors.orange, label: "Emergencia",
                      onTap: () => Navigator.pushNamed(context, "/emergency")),
                  _NavCard(icon: Icons.gps_fixed, color: Colors.teal, label: "Calibrar",
                      onTap: () => Navigator.pushNamed(context, "/calibration")),
                  _NavCard(icon: Icons.settings, color: Colors.blueGrey, label: "Ajustes",
                      onTap: () => Navigator.pushNamed(context, "/settings")),
                ],






              ),
              const SizedBox(height: 16),

              // GSR - Futura implementación
              _InfoCard(
                icon: Icons.water_drop,
                iconColor: Colors.teal,
                label: "RESPUESTA GALVÁNICA DE LA PIEL (GSR)",
                value: "Futura implementación",
                subtitle: "El sensor todavía no forma parte del prototipo actual.",
              ),
              const SizedBox(height: 20),

            // Pruebas de Hardware
              const Text(
                "Pruebas de Hardware",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Divider(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _HardwareTestCard(
                    icon: Icons.favorite_border,
                    label: "Probar Pulso",
                    onTap: () => _showHardwareTestDialog("Pulso"),
                  ),
                  _HardwareTestCard(
                    icon: Icons.palette_outlined,
                    label: "Probar LEDs",
                    onTap: () => _showHardwareTestDialog("LEDs"),
                  ),
                  _HardwareTestCard(
                    icon: Icons.notifications_outlined,
                    label: "Probar Buzzer",
                    onTap: () => _showHardwareTestDialog("Buzzer"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(icon: Icons.home, label: "Inicio", onTap: () {}),
          GestureDetector(
            onTap: _showSOSDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone_in_talk, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          _BottomNavItem(icon: Icons.more_horiz, label: "Opciones",
              onTap: () => Navigator.pushNamed(context, "/settings")),
        ],
      ),
    );
  }
}

// Widgets auxiliares

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  const _StatCard({required this.icon, required this.iconColor, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;
  const _InfoCard({required this.icon, required this.iconColor, required this.label, required this.value,this.subtitle,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _NavCard({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomNavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _HardwareTestCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HardwareTestCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black54, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}