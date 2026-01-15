import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _response = 'Clique para testar a API';
  bool _isLoading = false;

  Future<void> _testarAPI() async {
    setState(() {
      _isLoading = true;
      _response = 'Carregando...';
    });

    try {
      // Testar endpoint de jogadores
      final uri = Uri.parse('${ApiConfig.baseUrl}/jogadores');
      print('Testando URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));

          String result = 'Status: ${response.statusCode}\n\n';
          result += 'Total de jogadores: ${(data as List).length}\n\n';
          result += 'Campos do primeiro jogador:\n';

          if (data.isNotEmpty) {
            final primeiro = data[0];
            primeiro.keys.forEach((key) {
              result += '  $key: ${primeiro[key]}\n';
            });
          }

          result +=
              '\n\nPrimeiros 2 jogadores completos:\n${JsonEncoder.withIndent('  ').convert(data.take(2).toList())}';
          _response = result;
        } else {
          _response = 'Erro ${response.statusCode}\n\nBody: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _response = 'Erro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84),
        child: AppBar(
          leading: Navigator.canPop(context)
              ? const BackButton(color: Colors.white)
              : null,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B894), Color(0xFF0066FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
          centerTitle: true,
          title: const Text('Teste de API'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('URL da API:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              ApiConfig.baseUrl,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testarAPI,
              child: Text(_isLoading ? 'Testando...' : 'Ver Estrutura da API'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _response,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
