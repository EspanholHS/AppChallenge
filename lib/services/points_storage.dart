// lib/services/points_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class PointsStorage {
  static const _kKey = 'inova_points';
  static const defaultPoints = 280;

  /// Chame no boot do app (main). Força iniciar sempre em 280.
  static Future<void> resetOnLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKey, defaultPoints);
  }

  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kKey) ?? defaultPoints;
  }

  static Future<void> setPoints(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKey, value);
  }
}
