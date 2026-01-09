import 'jogador.dart';

class ComparacaoResponse {
  final Jogador jogador1;
  final Jogador jogador2;
  final Map<String, dynamic> comparacao;

  ComparacaoResponse({
    required this.jogador1,
    required this.jogador2,
    required this.comparacao,
  });

  factory ComparacaoResponse.fromJson(Map<String, dynamic> json) {
    return ComparacaoResponse(
      jogador1: Jogador.fromJson(json['jogador1']),
      jogador2: Jogador.fromJson(json['jogador2']),
      comparacao: json['comparacao'] ?? {},
    );
  }
}
