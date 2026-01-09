class ApiConfig {
  // URL da API
  // Para emulador Android: use 'http://10.0.2.2:8080/api'
  // Para dispositivo físico: use o IP da sua máquina (ex: 'http://192.168.1.100:8080/api')
  // Para iOS Simulator: use 'http://localhost:8080/api'
  static const String baseUrl = 'http://192.168.18.219:8080/api';

  // Timeout configurations
  static const Duration timeoutDuration = Duration(seconds: 30);
}
