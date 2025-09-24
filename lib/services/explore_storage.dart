import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreStorage {
  static const _kKey = 'explore_state_v1';

  /// Salva apenas o estado que muda (por id): likes, isLiked, points, comments
  static Future<void> save(List<Map<String, dynamic>> states) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(states));
  }

  /// Retorna uma lista de mapas com: {id, likes, isLiked, points, comments}
  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Apaga o estado salvo (se precisar no futuro)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
