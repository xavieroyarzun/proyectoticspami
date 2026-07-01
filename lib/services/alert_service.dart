import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_data.dart';
import '../screens/sos_screen.dart';

enum AlertState { idle, warning, confirming, sos }

class AlertService {
  static const String emergencyContact = '+56912345678'; // hardcodeado por ahora
  static const Duration stepDuration = Duration(seconds: 10);

  final GlobalKey<NavigatorState> navigatorKey;
  AlertService(this.navigatorKey);

  AlertState _state = AlertState.idle;
  Timer? _timer;

  final List<double> _recentMagnitudes = [];
  static const int _windowSize = 8; // ~16s si llega un dato cada 2s
  static const double _stillThreshold = 0.3;
  static const double _severeThreshold = 3.0;

  void start() {
    bluetoothService.stream.listen(_onData);
  }

  void _onData(data) {
    final deviation = _movementDeviation(data.ax, data.ay, data.az);

    if (deviation != null) {
      _recentMagnitudes.add(deviation);
      if (_recentMagnitudes.length > _windowSize) {
        _recentMagnitudes.removeAt(0);
      }
    }

    if (_state != AlertState.idle) return; // ya hay una alerta corriendo

    final severeMovement = deviation != null && deviation > _severeThreshold;
    final sustainedStillness = _recentMagnitudes.length == _windowSize &&
        _recentMagnitudes.every((d) => d < _stillThreshold);

    if (data.stressLevel == 'Alto' && (severeMovement || sustainedStillness)) {
      _startEscalation();
    }
  }

  double? _movementDeviation(double? ax, double? ay, double? az) {
    if (ax == null || ay == null || az == null) return null;
    final magnitude = sqrt(ax * ax + ay * ay + az * az);
    return (magnitude - 9.8).abs();
  }

  void _startEscalation() {
    _state = AlertState.warning;
    _showStep(
      title: '¿Estás bien?',
      message: 'Detectamos posibles signos de estrés alto. Si no respondes en 10s, escalaremos la alerta.',
      cancelLabel: 'Estoy bien',
      onTimeout: () {
        _state = AlertState.confirming;
        _showStep(
          title: '⚠️ Confirmación de alerta',
          message: 'No respondiste a tiempo. Si no cancelas en 10s, se activará el modo SOS.',
          cancelLabel: 'Cancelar alerta',
          onTimeout: _triggerSOS,
        );
      },
    );
  }

  void _showStep({
    required String title,
    required String message,
    required String cancelLabel,
    required VoidCallback onTimeout,
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _cancel();
            },
            child: Text(cancelLabel),
          ),
        ],
      ),
    );

    _timer = Timer(stepDuration, () {
      if (navigatorKey.currentState?.canPop() ?? false) {
        Navigator.of(ctx).pop(); // cierra el diálogo actual
      }
      onTimeout();
    });
  }

  void _cancel() {
    _timer?.cancel();
    _state = AlertState.idle;
  }

  Future<void> _triggerSOS() async {
    _state = AlertState.sos;

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const SosScreen()),
    );

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      final mapsLink = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      final message = 'Necesito ayuda. Mi ubicación: $mapsLink';

      final uri = Uri(
        scheme: 'sms',
        path: emergencyContact,
        queryParameters: {'body': message},
      );
      await launchUrl(uri);
    } catch (e) {
      print('❌ No se pudo obtener ubicación o abrir SMS: $e');
    }

    _state = AlertState.idle;
  }
}