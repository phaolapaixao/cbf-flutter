import 'package:flutter/material.dart';
import '../models/jogador_rodada.dart';
import '../models/scout_ranking.dart';
import '../services/jogador_service.dart';
import '../services/scout_service.dart';
import 'detalhes_jogador_screen.dart';

class RankingsScreen extends StatefulWidget {
  final String? clubeFavorito;

  const RankingsScreen({Key? key, this.clubeFavorito}) : super(key: key);

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JogadorService _jogadorService = JogadorService();
  final ScoutService _scoutService = ScoutService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Rodada'),
            Tab(text: 'Temporada'),
            Tab(text: 'Scouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RankingRodadaTab(clubeFavorito: widget.clubeFavorito),
          RankingTemporadaTab(clubeFavorito: widget.clubeFavorito),
          const RankingScoutsTab(),
        ],
      ),
    );
  }
}

// Tab de Ranking por Rodada
class RankingRodadaTab extends StatefulWidget {
  final String? clubeFavorito;

  const RankingRodadaTab({Key? key, this.clubeFavorito}) : super(key: key);

  @override
  State<RankingRodadaTab> createState() => _RankingRodadaTabState();
}

class _RankingRodadaTabState extends State<RankingRodadaTab> {
  final JogadorService _jogadorService = JogadorService();

  int _rodadaSelecionada = 1;
  String? _posicaoSelecionada;
  List<JogadorRodada> _ranking = [];
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
    _carregarRanking();
  }

  Future<void> _carregarRanking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ranking = await _jogadorService.buscarRankingRodada(
        rodada: _rodadaSelecionada,
        posicao: _posicaoSelecionada,
        limite: 50,
      );

      setState(() {
        _ranking = ranking;
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
    return Column(
      children: [
        _buildFiltros(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFiltros() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _rodadaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Rodada',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: List.generate(38, (i) => i + 1)
                    .map((r) => DropdownMenuItem(value: r, child: Text('$r')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _rodadaSelecionada = value);
                    _carregarRanking();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _posicaoSelecionada ?? 'Todas',
                decoration: const InputDecoration(
                  labelText: 'Posição',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: _posicoes
                    .map(
                      (p) => DropdownMenuItem(
                        value: p == 'Todas' ? null : p,
                        child: Text(p),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _posicaoSelecionada = value);
                  _carregarRanking();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarRanking,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarRanking,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _ranking.length,
        itemBuilder: (context, index) {
          final jogador = _ranking[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
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
                  jogador.pontos.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
          );
        },
      ),
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

// Tab de Ranking da Temporada (usando média)
class RankingTemporadaTab extends StatefulWidget {
  final String? clubeFavorito;

  const RankingTemporadaTab({Key? key, this.clubeFavorito}) : super(key: key);

  @override
  State<RankingTemporadaTab> createState() => _RankingTemporadaTabState();
}

class _RankingTemporadaTabState extends State<RankingTemporadaTab> {
  // Implementação similar ao RankingRodadaTab, mas ordenando por média da temporada
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Ranking de Temporada\n(Em desenvolvimento)'),
    );
  }
}

// Tab de Rankings por Scouts
class RankingScoutsTab extends StatefulWidget {
  const RankingScoutsTab({Key? key}) : super(key: key);

  @override
  State<RankingScoutsTab> createState() => _RankingScoutsTabState();
}

class _RankingScoutsTabState extends State<RankingScoutsTab> {
  final ScoutService _scoutService = ScoutService();

  String _scoutSelecionado = 'gols';
  List<ScoutRanking> _ranking = [];
  bool _isLoading = false;
  String? _error;

  final Map<String, String> _scouts = {
    'gols': 'Gols',
    'assistencias': 'Assistências',
    'desarmes': 'Desarmes',
    'finalizacoes': 'Finalizações Perigosas',
    'defesas': 'Defesas Difíceis',
    'sem_gol': 'Jogos sem Gol',
  };

  @override
  void initState() {
    super.initState();
    _carregarRanking();
  }

  Future<void> _carregarRanking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<ScoutRanking> ranking;

      switch (_scoutSelecionado) {
        case 'gols':
          ranking = await _scoutService.topGols(limite: 30);
          break;
        case 'assistencias':
          ranking = await _scoutService.topAssistencias(limite: 30);
          break;
        case 'desarmes':
          ranking = await _scoutService.topDesarmes(limite: 30);
          break;
        case 'finalizacoes':
          ranking = await _scoutService.topFinalizacoesPerigosas(limite: 30);
          break;
        case 'defesas':
          ranking = await _scoutService.topDefesasDificeis(limite: 30);
          break;
        case 'sem_gol':
          ranking = await _scoutService.topJogosSemGol(limite: 30);
          break;
        default:
          ranking = [];
      }

      setState(() {
        _ranking = ranking;
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
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _scoutSelecionado,
              decoration: const InputDecoration(
                labelText: 'Scout',
                border: OutlineInputBorder(),
              ),
              items: _scouts.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _scoutSelecionado = value);
                  _carregarRanking();
                }
              },
            ),
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarRanking,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarRanking,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _ranking.length,
        itemBuilder: (context, index) {
          final jogador = _ranking[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${jogador.clube} - ${jogador.posicao}'),
                  Text(
                    'Média: ${jogador.mediaPorJogo.toStringAsFixed(2)} por jogo',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      jogador.total.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${jogador.jogos} jogos',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
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
          );
        },
      ),
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
