import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scout_ranking.dart';
import '../constants/posicoes.dart';
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
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        // Normaliza para lista quando API retornar objeto ou lista
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded is Map ? [decoded] : []);

        final ranking = data.map((r) {
          if (r is Map<String, dynamic>) return ScoutRanking.fromJson(r);
          if (r is Map)
            return ScoutRanking.fromJson(Map<String, dynamic>.from(r));
          return ScoutRanking.fromJson({});
        }).toList();

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return ranking;
      } else {
        throw Exception('Erro ao buscar ranking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar ranking');
    }
  }

  Future<List<ScoutRanking>> topAssistencias({
    int temporada = ApiConfig.defaultSeason,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final posicaoId = Posicoes.converterParaId(posicao);
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicaoId != null) queryParams['posicao'] = posicaoId.toString();
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('ataque/top-assistencias', queryParams, useCache);
  }

  Future<List<ScoutRanking>> topDesarmes({
    int temporada = ApiConfig.defaultSeason,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final posicaoId = Posicoes.converterParaId(posicao);
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicaoId != null) queryParams['posicao'] = posicaoId.toString();
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('defesa/top-desarmes', queryParams, useCache);
  }

  Future<List<ScoutRanking>> topGols({
    int temporada = ApiConfig.defaultSeason,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final posicaoId = Posicoes.converterParaId(posicao);
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicaoId != null) queryParams['posicao'] = posicaoId.toString();
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking('ataque/top-gols', queryParams, useCache);
  }

  Future<List<ScoutRanking>> topFinalizacoesPerigosas({
    int temporada = ApiConfig.defaultSeason,
    int? rodada,
    int limite = 10,
    String? posicao,
    String? clube,
    bool useCache = true,
  }) async {
    final posicaoId = Posicoes.converterParaId(posicao);
    final queryParams = <String, String>{
      'temporada': temporada.toString(),
      'limite': limite.toString(),
    };
    if (rodada != null) queryParams['rodada'] = rodada.toString();
    if (posicaoId != null) queryParams['posicao'] = posicaoId.toString();
    if (clube != null) queryParams['clube'] = clube;

    return _fetchRanking(
      'ataque/top-finalizacoes-perigosas',
      queryParams,
      useCache,
    );
  }

  Future<List<ScoutRanking>> topDefesasDificeis({
    int temporada = ApiConfig.defaultSeason,
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
    int temporada = ApiConfig.defaultSeason,
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
