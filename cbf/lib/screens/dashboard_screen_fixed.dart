import 'package:flutter/material.dart';
import '../models/jogador.dart';
import '../services/jogador_service.dart';
import 'detalhes_jogador_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? clubeFavorito;

  const DashboardScreen({Key? key, this.clubeFavorito}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final JogadorService _jogadorService = JogadorService();

  String? _posicaoSelecionada;

  List<Jogador> _topLiga = [];
  List<Jogador> _topClube = [];
  bool _isLoading = false;
  String? _error;

  final List<String> _posicoes = [
    'Todas',
    'GOL',
    'ZAG',
    'LAT',
    'MEI',
    'ATA',
    'TEC',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Busca todos os jogadores e ordena por média da temporada
      var todosJogadores = await _jogadorService.listarJogadores(
        posicao: _posicaoSelecionada == 'Todas' ? null : _posicaoSelecionada,
      );

      // Ordena por média da temporada (decrescente)
      todosJogadores.sort(
        (a, b) => b.mediaTemporada.compareTo(a.mediaTemporada),
      );

      // Top 5 da liga
      final topLiga = todosJogadores.take(5).toList();

      // Top 5 do clube (se definido)
      List<Jogador> topClube = [];
      if (widget.clubeFavorito != null) {
        topClube = todosJogadores
            .where((j) => j.clube == widget.clubeFavorito)
            .take(5)
            .toList();
      }

      setState(() {
        _topLiga = topLiga;
        _topClube = topClube;
        _isLoading = false;
      });

      // Debug: verificar dados carregados
      print('🔍 Dashboard - Top Liga carregados: ${topLiga.length}');
      if (topLiga.isNotEmpty) {
        print(
          '🔍 Primeiro jogador: ${topLiga.first.apelido}, média=${topLiga.first.mediaTemporada}',
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Na Gaveta'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFiltros(),
              const SizedBox(height: 20),
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_error != null) ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarDados,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildTopSection('Top 5 da Liga', _topLiga),
                if (_topClube.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildTopSection(
                    'Top 5 do ${widget.clubeFavorito}',
                    _topClube,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Posição:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: _posicaoSelecionada,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('Todas'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas'),
                    ),
                    ..._posicoes
                        .where((p) => p != 'Todas')
                        .map(
                          (p) => DropdownMenuItem<String?>(
                            value: p,
                            child: Text(p),
                          ),
                        )
                        .toList(),
                  ],
                  onChanged: (String? value) {
                    setState(() => _posicaoSelecionada = value);
                    _carregarDados();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(String titulo, List<Jogador> jogadores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Column(
            children: jogadores.asMap().entries.map((entry) {
              final index = entry.key;
              final jogador = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCorPosicao(jogador.posicao),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      jogador.apelido,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${jogador.clube} - ${jogador.posicao}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        jogador.mediaTemporada.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalhesJogadorScreen(atletaId: jogador.atletaId),
                        ),
                      );
                    },
                  ),
                  if (index < jogadores.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getCorPosicao(String posicao) {
    switch (posicao) {
      case 'GOL':
        return Colors.orange;
      case 'ZAG':
        return Colors.blue;
      case 'LAT':
        return Colors.lightBlue;
      case 'MEI':
        return Colors.green;
      case 'ATA':
        return Colors.red;
      case 'TEC':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
