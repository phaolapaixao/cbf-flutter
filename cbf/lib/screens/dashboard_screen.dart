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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84),
        child: AppBar(
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
          title: const Text('Na Gaveta'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _posicoes.map((p) {
              final isSelected =
                  (p == 'Todas' && _posicaoSelecionada == null) ||
                  (_posicaoSelecionada == p);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  onSelected: (sel) {
                    setState(() {
                      _posicaoSelecionada = (p == 'Todas') ? null : p;
                    });
                    _carregarDados();
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
        Column(
          children: jogadores.asMap().entries.map((entry) {
            final index = entry.key;
            final jogador = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetalhesJogadorScreen(atletaId: jogador.atletaId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jogador.apelido,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${jogador.clube} • ${jogador.posicao}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00796B)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            jogador.mediaTemporada.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
