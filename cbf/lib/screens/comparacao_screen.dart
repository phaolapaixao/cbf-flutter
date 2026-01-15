import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/jogador.dart';
import '../models/jogador_rodada.dart';
import '../models/comparacao_response.dart';
import '../services/jogador_service.dart';

class ComparacaoScreen extends StatefulWidget {
  const ComparacaoScreen({Key? key}) : super(key: key);

  @override
  State<ComparacaoScreen> createState() => _ComparacaoScreenState();
}

class _ComparacaoScreenState extends State<ComparacaoScreen> {
  final JogadorService _jogadorService = JogadorService();

  Jogador? _jogador1;
  Jogador? _jogador2;
  ComparacaoResponse? _comparacao;
  List<JogadorRodada> _rodadas1 = [];
  List<JogadorRodada> _rodadas2 = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _selecionarJogador(int numero) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SeletorJogadorScreen()),
    );

    if (result != null && result is Jogador) {
      setState(() {
        if (numero == 1) {
          _jogador1 = result;
        } else {
          _jogador2 = result;
        }
      });

      if (_jogador1 != null && _jogador2 != null) {
        _compararJogadores();
      }
    }
  }

  Future<void> _compararJogadores() async {
    if (_jogador1 == null || _jogador2 == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final comparacao = await _jogadorService.compararJogadores(
        _jogador1!.atletaId,
        _jogador2!.atletaId,
      );

      final rodadas1 = await _jogadorService.buscarRodadasJogador(
        _jogador1!.atletaId,
      );
      final rodadas2 = await _jogadorService.buscarRodadasJogador(
        _jogador2!.atletaId,
      );

      setState(() {
        _comparacao = comparacao;
        _rodadas1 = rodadas1;
        _rodadas2 = rodadas2;
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
          title: const Text('Comparação de Jogadores'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelecionadores(),
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
                  ],
                ),
              ),
            ] else if (_comparacao != null) ...[
              _buildComparacao(),
              const SizedBox(height: 20),
              _buildGraficoComparacao(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelecionadores() {
    return Row(
      children: [
        Expanded(child: _buildCardSeletor(1, _jogador1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'VS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: _buildCardSeletor(2, _jogador2)),
      ],
    );
  }

  Widget _buildCardSeletor(int numero, Jogador? jogador) {
    return GestureDetector(
      onTap: () => _selecionarJogador(numero),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          child: jogador == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecionar\nJogador $numero',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      ),
                      child: Center(
                        child: Text(
                          jogador.posicao,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jogador.apelido,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      jogador.clube,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildComparacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildLinhaComparacao(
          'Média Temporada',
          _jogador1!.mediaTemporada,
          _jogador2!.mediaTemporada,
        ),
        _buildLinhaComparacao(
          'Média Últimas 5',
          _jogador1!.mediaUltimas5,
          _jogador2!.mediaUltimas5,
        ),
        _buildLinhaComparacao(
          'Pontuação Máxima',
          _jogador1!.pontuacaoMaxima,
          _jogador2!.pontuacaoMaxima,
        ),
        _buildLinhaComparacao(
          'Pontuação Mínima',
          _jogador1!.pontuacaoMinima,
          _jogador2!.pontuacaoMinima,
        ),
        _buildLinhaComparacao(
          'Jogos',
          _jogador1!.jogos.toDouble(),
          _jogador2!.jogos.toDouble(),
          isInteger: true,
        ),
      ],
    );
  }

  Widget _buildLinhaComparacao(
    String label,
    double valor1,
    double valor2, {
    bool isInteger = false,
  }) {
    final melhor1 = valor1 > valor2;
    final melhor2 = valor2 > valor1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: melhor1 ? Colors.green[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isInteger
                          ? valor1.toInt().toString()
                          : valor1.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: melhor1 ? Colors.green[700] : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: melhor2 ? Colors.green[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isInteger
                          ? valor2.toInt().toString()
                          : valor2.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: melhor2 ? Colors.green[700] : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoComparacao() {
    if (_rodadas1.isEmpty || _rodadas2.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calcula os valores mínimos e máximos para os eixos
    final todasRodadas = [..._rodadas1, ..._rodadas2];
    final minRodada = todasRodadas
        .map((r) => r.rodada)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final maxRodada = todasRodadas
        .map((r) => r.rodada)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final maxPontos = todasRodadas
        .map((r) => r.pontos)
        .reduce((a, b) => a > b ? a : b);
    final minPontos = todasRodadas
        .map((r) => r.pontos)
        .reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desempenho por Rodada',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegenda(_jogador1!.apelido, Colors.blue[700]!),
                    const SizedBox(width: 20),
                    _buildLegenda(_jogador2!.apelido, Colors.red[700]!),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      minX: minRodada,
                      maxX: maxRodada,
                      minY: minPontos < 0 ? minPontos - 1 : 0,
                      maxY: maxPontos + 2,
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _rodadas1
                              .where(
                                (r) => r.rodada > 0,
                              ) // Filtra rodadas válidas
                              .map((r) => FlSpot(r.rodada.toDouble(), r.pontos))
                              .toList(),
                          isCurved: true,
                          color: Colors.blue[700],
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: _rodadas2
                              .where(
                                (r) => r.rodada > 0,
                              ) // Filtra rodadas válidas
                              .map((r) => FlSpot(r.rodada.toDouble(), r.pontos))
                              .toList(),
                          isCurved: true,
                          color: Colors.red[700],
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegenda(String label, Color cor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
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

// Tela auxiliar para seleção de jogadores
class SeletorJogadorScreen extends StatefulWidget {
  const SeletorJogadorScreen({Key? key}) : super(key: key);

  @override
  State<SeletorJogadorScreen> createState() => _SeletorJogadorScreenState();
}

class _SeletorJogadorScreenState extends State<SeletorJogadorScreen> {
  final JogadorService _jogadorService = JogadorService();
  final TextEditingController _searchController = TextEditingController();

  List<Jogador> _jogadores = [];
  List<Jogador> _jogadoresFiltrados = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarJogadores();
    _searchController.addListener(_filtrarJogadores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarJogadores() async {
    setState(() => _isLoading = true);
    try {
      final jogadores = await _jogadorService.listarJogadores();
      setState(() {
        _jogadores = jogadores;
        _jogadoresFiltrados = jogadores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarJogadores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _jogadoresFiltrados = _jogadores.where((jogador) {
        return jogador.nome.toLowerCase().contains(query) ||
            jogador.apelido.toLowerCase().contains(query);
      }).toList();
    });
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
          title: const Text('Selecionar Jogador'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar jogador...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _jogadoresFiltrados.length,
                    itemBuilder: (context, index) {
                      final jogador = _jogadoresFiltrados[index];
                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
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
                              jogador.posicao,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(jogador.apelido),
                        subtitle: Text('${jogador.clube} - ${jogador.posicao}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00796B)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            jogador.mediaTemporada.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, jogador);
                        },
                      );
                    },
                  ),
          ),
        ],
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
