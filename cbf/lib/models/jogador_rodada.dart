class JogadorRodada {
  final int atletaId;
  final String nome;
  final String apelido;
  final String foto;
  final String clube;
  final String posicao;
  final int rodada;
  final double pontos;
  final int temporada;
  final Map<String, int>? scouts;

  JogadorRodada({
    required this.atletaId,
    required this.nome,
    required this.apelido,
    required this.foto,
    required this.clube,
    required this.posicao,
    required this.rodada,
    required this.pontos,
    required this.temporada,
    this.scouts,
  });

  factory JogadorRodada.fromJson(Map<String, dynamic> json) {
    return JogadorRodada(
      atletaId: json['atleta_id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      apelido: json['apelido'] as String? ?? '',
      foto: json['foto'] as String? ?? '',
      clube: json['clube_id'] as String? ?? json['clube'] as String? ?? '',
      posicao:
          json['posicao_id'] as String? ?? json['posicao'] as String? ?? '',
      rodada: json['rodada_id'] as int? ?? json['rodada'] as int? ?? 0,
      pontos: (json['pontuacao_fantasy'] as num? ?? json['pontos'] as num? ?? 0)
          .toDouble(),
      temporada: json['ano'] as int? ?? json['temporada'] as int? ?? 2025,
      scouts: json['scouts'] != null
          ? Map<String, int>.from(json['scouts'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'atletaId': atletaId,
      'nome': nome,
      'apelido': apelido,
      'foto': foto,
      'clube': clube,
      'posicao': posicao,
      'rodada': rodada,
      'pontos': pontos,
      'temporada': temporada,
      'scouts': scouts,
    };
  }
}
