class ScoutRanking {
  final int atletaId;
  final String nome;
  final String apelido;
  final String foto;
  final String clube;
  final String posicao;
  final int total;
  final double mediaPorJogo;
  final int jogos;

  ScoutRanking({
    required this.atletaId,
    required this.nome,
    required this.apelido,
    required this.foto,
    required this.clube,
    required this.posicao,
    required this.total,
    required this.mediaPorJogo,
    required this.jogos,
  });

  factory ScoutRanking.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
      return 0.0;
    }

    String parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    // Detecta possíveis mapas aninhados que algumas respostas da API usam
    final athleteMap = (json['atleta'] is Map)
        ? Map<String, dynamic>.from(json['atleta'])
        : (json['player'] is Map
              ? Map<String, dynamic>.from(json['player'])
              : json);

    final scoutMap = (json['scout'] is Map)
        ? Map<String, dynamic>.from(json['scout'])
        : (json['estatistica'] is Map
              ? Map<String, dynamic>.from(json['estatistica'])
              : json);

    return ScoutRanking(
      atletaId: parseInt(
        athleteMap['atleta_id'] ??
            athleteMap['atletaId'] ??
            athleteMap['id'] ??
            json['atleta_id'] ??
            json['atletaId'],
      ),
      nome: parseString(
        athleteMap['nome'] ?? athleteMap['nome_completo'] ?? json['nome'],
      ),
      apelido: parseString(
        athleteMap['apelido'] ??
            athleteMap['apelido_abreviado'] ??
            json['apelido'],
      ),
      foto: parseString(
        athleteMap['foto'] ?? athleteMap['foto_url'] ?? json['foto'] ?? '',
      ),
      clube: parseString(
        (json['clube_id'] is int ? json['clube_id'].toString() : null) ??
            (athleteMap['clube_id'] is int
                ? athleteMap['clube_id'].toString()
                : athleteMap['clube_id']) ??
            athleteMap['clube'] ??
            athleteMap['time'] ??
            json['clube'] ??
            '',
      ),
      posicao: parseString(
        (json['posicao_id'] is int ? json['posicao_id'].toString() : null) ??
            (athleteMap['posicao_id'] is int
                ? athleteMap['posicao_id'].toString()
                : athleteMap['posicao_id']) ??
            athleteMap['posicao'] ??
            json['posicao'] ??
            '',
      ),
      total: parseInt(
        scoutMap['total'] ??
            scoutMap['gols'] ??
            scoutMap['assistencias'] ??
            scoutMap['valor'] ??
            scoutMap['quantidade'] ??
            json['total'] ??
            json['gols'] ??
            json['assistencias'],
      ),
      mediaPorJogo: parseDouble(
        scoutMap['media_por_jogo'] ??
            scoutMap['mediaPorJogo'] ??
            scoutMap['media'] ??
            scoutMap['media_jogo'] ??
            json['media_por_jogo'] ??
            json['mediaPorJogo'] ??
            json['media'],
      ),
      jogos: parseInt(
        scoutMap['jogos'] ??
            scoutMap['total_partidas'] ??
            scoutMap['partidas'] ??
            scoutMap['numero_jogos'] ??
            json['jogos'] ??
            json['total_partidas'] ??
            json['partidas'],
      ),
    );
  }
}
