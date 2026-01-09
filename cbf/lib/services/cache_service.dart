import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _prefix = 'cbf_cache_';
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<void> saveToCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_prefix + key, jsonEncode(cacheData));
    } catch (e) {
      print('Erro ao salvar cache: $e');
    }
  }

  Future<dynamic> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_prefix + key);

      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Verifica se o cache ainda é válido
      if (now - timestamp > _cacheDuration.inMilliseconds) {
        await clearCache(key);
        return null;
      }

      return cacheData['data'];
    } catch (e) {
      print('Erro ao buscar cache: $e');
      return null;
    }
  }

  Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefix + key);
    } catch (e) {
      print('Erro ao limpar cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
      for (var key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Erro ao limpar todo o cache: $e');
    }
  }
}
