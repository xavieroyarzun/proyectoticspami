import '../models/sensor_data.dart';
import 'bluetooth_service.dart';
class AppData {

  static SensorData currentData = SensorData(
    bpm: 75,
    temperature: 36.5,
    gsr: 400,
    stressLevel: "Bajo",
  );

}
final bluetoothService =
BluetoothService();