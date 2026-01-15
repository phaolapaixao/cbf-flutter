class ApiConfig {
  // URL da API
  static const String baseUrl = 'http://192.168.18.219:8080/api';

  // Timeout configurations
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Ano/temporada padrão usado nas chamadas à API
  static const int defaultSeason = 2025;
}
