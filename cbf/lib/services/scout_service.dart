import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scout_ranking.dart';
import 'api_config.dart';
import 'cache_service.dart';

class ScoutService {
  final CacheService _cacheService = CacheService();

  Future<List<ScoutRanking>> _fetchRanking(
    String endpoint,
    Map<String, String> queryParams,
    bool useCache,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/scouts/$endpoint',
      ).replace(queryParameters: queryParams);

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return (cached as List).map((r) => ScoutRanking.fromJson(r)).toList();
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final ranking = data.map((r) => ScoutRanking.fromJson(r)).toList();

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return ranking;
      } else {
        throw Exception('Erro ao buscar ranking: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em _fetchRanking: $e');
      throw Exception('Falha ao carregar ranking');
    }
  }

  Future<List<ScoutRanking>> topAssistencias({
    int temporada = 2025,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicao != null) queryParams['posicao'] = posicao;
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('ataque/top-assistencias', queryParams, useCache);
  }

  Future<List<ScoutRanking>> topDesarmes({
    int temporada = 2025,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicao != null) queryParams['posicao'] = posicao;
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('defesa/top-desarmes', queryParams, useCache);
  }

  Future<List<ScoutRanking>> topGols({
    int temporada = 2025,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicao != null) queryParams['posicao'] = posicao;
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('ataque/top-gols', queryParams, useCache);
  }

  Future<List<ScoutRanking>> topFinalizacoesPerigosas({
    int temporada = 2025,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicao != null) queryParams['posicao'] = posicao;
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking(
      'ataque/top-finalizacoes-perigosas',
      queryParams,
      useCache,
    );
  }

  Future<List<ScoutRanking>> topDefesasDificeis({
    int temporada = 2025,
    int? rodada,
    int limite = 10,
    String? clube,
    bool useCache = true,
  }) async {
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking(
      'goleiros/top-defesas-dificeis',
      queryParams,
      useCache,
    );
  }

  Future<List<ScoutRanking>> topJogosSemGol({
    int temporada = 2025,
    int? rodada,
    int limite = 10,
    String? clube,
    bool useCache = true,
  }) async {
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('defesa/top-jogos-sem-gol', queryParams, useCache);
  }
}
