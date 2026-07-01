import '../models/sensor_data.dart';
import 'bluetooth_service.dart';

final bluetoothService = BluetoothService();

class AppData {
  // Ahora es un getter que apunta al dato real del servicio central,
  // en vez de un valor estático congelado
  static SensorData get currentData =>
      bluetoothService.lastData ??
          SensorData(bpm: 75, temperature: 36.5, stressLevel: "Bajo");
}