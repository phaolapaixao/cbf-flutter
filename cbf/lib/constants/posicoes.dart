class Posicoes {
  static const Map<String, int> stringParaId = {
    'GOL': 1,
    'GOLEIRO': 1,
    'LAT': 2,
    'LATERAL': 2,
    'ZAG': 3,
    'ZAGUEIRO': 3,
    'MEI': 4,
    'MEIA': 4,
    'MEIO-CAMPO': 4,
    'ATA': 5,
    'ATACANTE': 5,
    'TEC': 6,
    'TECNICO': 6,
    'TÉCNICO': 6,
  };

  static const Map<int, String> idParaString = {
    1: 'GOL',
    2: 'LAT',
    3: 'ZAG',
    4: 'MEI',
    5: 'ATA',
    6: 'TEC',
  };

  static const Map<int, String> idParaNomeCompleto = {
    1: 'Goleiro',
    2: 'Lateral',
    3: 'Zagueiro',
    4: 'Meia',
    5: 'Atacante',
    6: 'Técnico',
  };

  /// Converte nome da posição para ID
  static int? converterParaId(String? posicao) {
    if (posicao == null || posicao.isEmpty) return null;
    return stringParaId[posicao.toUpperCase()];
  }

  /// Converte ID da posição para nome
  static String? converterParaNome(int? id) {
    if (id == null) return null;
    return idParaString[id];
  }

  /// Converte ID para nome completo
  static String? converterParaNomeCompleto(int? id) {
    if (id == null) return null;
    return idParaNomeCompleto[id];
  }
}
