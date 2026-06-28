import '../models/sensor_data.dart';

class ApiService {

  Future<void> sendSensorData(
      SensorData data,
      ) async {

    // Aquí irá la llamada HTTP real

    print(
      'Enviando: '
          '${data.bpm}, '
          '${data.temperature}, '
          '${data.gsr}',
    );
  }

  Future<bool> pingServer() async {

    // Comprobación futura

    return true;
  }
}