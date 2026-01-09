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
    return ScoutRanking(
      atletaId: json['atleta_id'] as int? ?? json['atletaId'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      apelido: json['apelido'] as String? ?? '',
      foto: json['foto'] as String? ?? '',
      clube: json['clube_id'] as String? ?? json['clube'] as String? ?? '',
      posicao:
          json['posicao_id'] as String? ?? json['posicao'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      mediaPorJogo:
          (json['media_por_jogo'] as num? ?? json['mediaPorJogo'] as num? ?? 0)
              .toDouble(),
      jogos: json['jogos'] as int? ?? json['total_partidas'] as int? ?? 0,
    );
  }
}
