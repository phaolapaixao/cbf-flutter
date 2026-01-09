import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jogador.dart';
import '../models/jogador_rodada.dart';
import '../models/comparacao_response.dart';
import 'api_config.dart';
import 'cache_service.dart';

class JogadorService {
  final CacheService _cacheService = CacheService();

  Future<List<Jogador>> listarJogadores({
    String? clube,
    String? posicao,
    String? nome,
    bool useCache = true,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (clube != null) queryParams['clube'] = clube;
      if (posicao != null) queryParams['posicao'] = posicao;
      if (nome != null) queryParams['nome'] = nome;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/jogadores',
      ).replace(queryParameters: queryParams);

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return (cached as List).map((j) => Jogador.fromJson(j)).toList();
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final jogadores = data.map((j) => Jogador.fromJson(j)).toList();

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return jogadores;
      } else {
        throw Exception('Erro ao buscar jogadores: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em listarJogadores: $e');
      throw Exception('Falha ao carregar jogadores');
    }
  }

  Future<Jogador?> buscarJogadorPorId(int id, {bool useCache = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/jogadores/$id');

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return Jogador.fromJson(cached);
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final jogador = Jogador.fromJson(data);

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return jogador;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar jogador: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em buscarJogadorPorId: $e');
      throw Exception('Falha ao carregar jogador');
    }
  }

  Future<List<JogadorRodada>> buscarRodadasJogador(
    int atletaId, {
    int? temporada,
    int? limite,
    bool useCache = true,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (temporada != null) queryParams['temporada'] = temporada.toString();
      if (limite != null) queryParams['limite'] = limite.toString();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/jogadores/$atletaId/rodadas',
      ).replace(queryParameters: queryParams);

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return (cached as List)
              .map((r) => JogadorRodada.fromJson(r))
              .toList();
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final rodadas = data.map((r) => JogadorRodada.fromJson(r)).toList();

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return rodadas;
      } else {
        throw Exception('Erro ao buscar rodadas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em buscarRodadasJogador: $e');
      throw Exception('Falha ao carregar rodadas');
    }
  }

  Future<List<JogadorRodada>> buscarRankingRodada({
    required int rodada,
    String? posicao,
    int limite = 10,
    int temporada = 2025,
    bool useCache = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'rodada': rodada.toString(),
        'limite': limite.toString(),
        'temporada': temporada.toString(),
      };
      if (posicao != null) queryParams['posicao'] = posicao;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/ranking/rodada',
      ).replace(queryParameters: queryParams);

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return (cached as List)
              .map((r) => JogadorRodada.fromJson(r))
              .toList();
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print('🔍 Ranking API - Total de registros: ${data.length}');
        if (data.isNotEmpty) {
          print('🔍 Primeiro item JSON: ${data[0]}');
        }
        final ranking = data.map((r) => JogadorRodada.fromJson(r)).toList();
        if (ranking.isNotEmpty) {
          print(
            '🔍 Após parse: ${ranking[0].apelido} - rodada=${ranking[0].rodada}, pontos=${ranking[0].pontos}',
          );
        }
        await _cacheService.saveToCache(uri.toString(), data);

        return ranking;
      } else {
        throw Exception('Erro ao buscar ranking: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em buscarRankingRodada: $e');
      throw Exception('Falha ao carregar ranking');
    }
  }

  Future<ComparacaoResponse?> compararJogadores(
    int idJogador1,
    int idJogador2, {
    int temporada = 2025,
    bool useCache = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'idJogador1': idJogador1.toString(),
        'idJogador2': idJogador2.toString(),
        'temporada': temporada.toString(),
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/comparacao',
      ).replace(queryParameters: queryParams);

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return ComparacaoResponse.fromJson(cached);
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final comparacao = ComparacaoResponse.fromJson(data);

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return comparacao;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao comparar jogadores: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em compararJogadores: $e');
      throw Exception('Falha ao comparar jogadores');
    }
  }

  Future<Map<String, dynamic>> estatisticasClube(
    String clube, {
    int temporada = 2025,
    bool useCache = true,
  }) async {
    try {
      final queryParams = <String, String>{'temporada': temporada.toString()};

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/estatisticas/clube/$clube',
      ).replace(queryParameters: queryParams);

      // Tenta buscar do cache
      if (useCache) {
        final cached = await _cacheService.getFromCache(uri.toString());
        if (cached != null) {
          return cached as Map<String, dynamic>;
        }
      }

      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Salva no cache
        await _cacheService.saveToCache(uri.toString(), data);

        return data;
      } else {
        throw Exception('Erro ao buscar estatísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em estatisticasClube: $e');
      throw Exception('Falha ao carregar estatísticas');
    }
  }
}
