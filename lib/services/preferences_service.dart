import 'package:shared_preferences/shared_preferences.dart';

import 'user_data.dart';
import 'calibration_data.dart';

class PreferencesService {

  static Future<void> load() async {

    final prefs =
    await SharedPreferences.getInstance();

    UserData.userName =
        prefs.getString('userName')
            ?? 'Usuario AFIVI';

    CalibrationData.baselineBpm =
        prefs.getInt('baselineBpm')
            ?? 75;

    CalibrationData.baselineTemperature =
        prefs.getDouble('baselineTemperature')
            ?? 36.5;

    CalibrationData.baselineGsr =
        prefs.getInt('baselineGsr')
            ?? 400;

    CalibrationData.calibrated =
        prefs.getBool('calibrated')
            ?? false;
  }

  static Future<void> saveUserName() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'userName',
      UserData.userName,
    );
  }

  static Future<void> saveCalibration() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setInt(
      'baselineBpm',
      CalibrationData.baselineBpm,
    );

    await prefs.setDouble(
      'baselineTemperature',
      CalibrationData.baselineTemperature,
    );

    await prefs.setInt(
      'baselineGsr',
      CalibrationData.baselineGsr,
    );

    await prefs.setBool(
      'calibrated',
      CalibrationData.calibrated,
    );
  }
}