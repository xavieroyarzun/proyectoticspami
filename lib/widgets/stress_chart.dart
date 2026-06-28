import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StressChart extends StatelessWidget {
  final List<FlSpot> points;

  const StressChart({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 10,
          minY: 0,
          maxY: 10,

          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.white24,
            ),
          ),

          gridData: const FlGridData(show: false),

          titlesData: const FlTitlesData(
            show: false,
          ),

          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 4,
              dotData: const FlDotData(
                show: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}