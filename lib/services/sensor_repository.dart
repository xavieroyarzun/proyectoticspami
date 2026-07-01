import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_data.dart';
import 'app_data.dart'; // bluetoothService

class SensorRepository {
  final _supabase = Supabase.instance.client;
  String? _lastStressLevel;

  void startSync() {
    bluetoothService.stream.listen((data) {
      final stress = data.stressLevel;
      if (stress == null) return;

      if (stress != _lastStressLevel) {
        _lastStressLevel = stress;
        _saveReading(data);
      }
    });
  }
  Future<List<Map<String, dynamic>>> fetchTodayHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final response = await _supabase
        .from('Mediciones_Biométricas')
        .select()
        .eq('id_Usuario', userId)
        .gte('fecha_medicion', startOfDay.toIso8601String())
        .order('fecha_medicion', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('Mediciones_Biométricas')
        .select()
        .eq('id_Usuario', userId)
        .order('fecha_medicion', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }
  Future<void> _saveReading(SensorData data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('Mediciones_Biométricas').insert({
        'id_Usuario': userId,
        'bpm': data.bpm,
        'temperatura': data.temperature,
        'aceleracion_x': data.ax,
        'aceleracion_y': data.ay,
        'aceleracion_z': data.az,
        'nivel_riesgo': data.stressLevel,
        'fecha_medicion': DateTime.now().toIso8601String(),
      });
      print('💾 Guardado en Supabase: nivel_riesgo=${data.stressLevel}');
    } catch (e) {
      print('❌ Error al guardar en Supabase: $e');
    }
  }
}