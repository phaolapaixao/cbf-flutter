class Jogador {
  final int atletaId;
  final String nome;
  final String apelido;
  final String foto;
  final String clube;
  final String posicao;
  final double mediaTemporada;
  final double mediaUltimas5;
  final double pontuacaoMaxima;
  final double pontuacaoMinima;
  final int jogos;
  final double preco;

  Jogador({
    required this.atletaId,
    required this.nome,
    required this.apelido,
    required this.foto,
    required this.clube,
    required this.posicao,
    required this.mediaTemporada,
    required this.mediaUltimas5,
    required this.pontuacaoMaxima,
    required this.pontuacaoMinima,
    required this.jogos,
    required this.preco,
  });

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      atletaId: json['atleta_id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      apelido: json['apelido'] as String? ?? '',
      foto: json['foto'] as String? ?? '',
      clube: json['clube_id'] as String? ?? '',
      posicao: json['posicao_id'] as String? ?? '',
      mediaTemporada: (json['pontuacao_media'] as num? ?? 0).toDouble(),
      mediaUltimas5: (json['media_ultimas_5'] as num? ?? 0).toDouble(),
      pontuacaoMaxima: (json['pontuacao_maxima'] as num? ?? 0).toDouble(),
      pontuacaoMinima: (json['pontuacao_minima'] as num? ?? 0).toDouble(),
      jogos: json['total_partidas'] as int? ?? 0,
      preco: (json['preco'] as num? ?? 0).toDouble(),
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
      'mediaTemporada': mediaTemporada,
      'mediaUltimas5': mediaUltimas5,
      'pontuacaoMaxima': pontuacaoMaxima,
      'pontuacaoMinima': pontuacaoMinima,
      'jogos': jogos,
      'preco': preco,
    };
  }
}
