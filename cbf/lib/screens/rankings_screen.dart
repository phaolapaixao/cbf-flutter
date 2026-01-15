import 'package:flutter/material.dart';
import '../models/jogador.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
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
          title: const Text('Rankings'),
          elevation: 0,
          backgroundColor: Colors.transparent,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 8),
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
                      setState(
                        () => _posicaoSelecionada = (p == 'Todas') ? null : p,
                      );
                      _carregarRanking();
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
  final JogadorService _jogadorService = JogadorService();

  String? _posicaoSelecionada;
  List<Jogador> _ranking = [];
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
      final jogadores = await _jogadorService.listarJogadores(
        posicao: _posicaoSelecionada,
      );

      // Ordena por média da temporada (decrescente)
      jogadores.sort((a, b) => b.mediaTemporada.compareTo(a.mediaTemporada));

      setState(() {
        _ranking = jogadores.take(50).toList();
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
        child: DropdownButtonFormField<String?>(
          value: _posicaoSelecionada,
          decoration: const InputDecoration(
            labelText: 'Posição',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _posicoes
              .map(
                (p) => DropdownMenuItem<String?>(
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

    if (_ranking.isEmpty) {
      return const Center(child: Text('Nenhum jogador encontrado'));
    }

    return RefreshIndicator(
      onRefresh: _carregarRanking,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _ranking.length,
        itemBuilder: (context, index) {
          final jogador = _ranking[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text('${jogador.clube} - ${jogador.posicao}'),
                            if (jogador.jogos > 0)
                              Text(
                                '${jogador.jogos} jogos na temporada',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF00796B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
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
                    ],
                  ),
                ),
              ),
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
                  if (jogador.mediaPorJogo > 0 || jogador.jogos > 0)
                    Text(
                      jogador.mediaPorJogo > 0
                          ? 'Média: ${jogador.mediaPorJogo.toStringAsFixed(2)} por jogo'
                          : jogador.jogos > 0
                          ? 'Média: ${(jogador.total / jogador.jogos).toStringAsFixed(2)} por jogo'
                          : '',
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
                  if (jogador.jogos > 0)
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
