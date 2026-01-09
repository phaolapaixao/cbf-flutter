import 'package:flutter/material.dart';
import '../models/jogador.dart';
import '../services/jogador_service.dart';
import 'detalhes_jogador_screen.dart';

class ListaJogadoresScreen extends StatefulWidget {
  const ListaJogadoresScreen({Key? key}) : super(key: key);

  @override
  State<ListaJogadoresScreen> createState() => _ListaJogadoresScreenState();
}

class _ListaJogadoresScreenState extends State<ListaJogadoresScreen> {
  final JogadorService _jogadorService = JogadorService();
  final TextEditingController _searchController = TextEditingController();

  List<Jogador> _jogadores = [];
  List<Jogador> _jogadoresFiltrados = [];
  bool _isLoading = false;
  String? _error;

  String? _clubeFiltro;
  String? _posicaoFiltro;

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
    _carregarJogadores();
    _searchController.addListener(_filtrarJogadores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarJogadores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jogadores = await _jogadorService.listarJogadores(
        clube: _clubeFiltro,
        posicao: _posicaoFiltro,
      );

      setState(() {
        _jogadores = jogadores;
        _jogadoresFiltrados = jogadores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filtrarJogadores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _jogadoresFiltrados = _jogadores.where((jogador) {
        final nome = jogador.nome.toLowerCase();
        final apelido = jogador.apelido.toLowerCase();
        return nome.contains(query) || apelido.contains(query);
      }).toList();
    });
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _posicaoFiltro ?? 'Todas',
                    decoration: const InputDecoration(
                      labelText: 'Posição',
                      border: OutlineInputBorder(),
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
                      setModalState(() => _posicaoFiltro = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _clubeFiltro = null;
                            _posicaoFiltro = null;
                          });
                          Navigator.pop(context);
                          _carregarJogadores();
                        },
                        child: const Text('Limpar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                          _carregarJogadores();
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
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
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          if (_posicaoFiltro != null || _clubeFiltro != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_posicaoFiltro != null)
                    Chip(
                      label: Text(_posicaoFiltro!),
                      onDeleted: () {
                        setState(() => _posicaoFiltro = null);
                        _carregarJogadores();
                      },
                    ),
                  if (_clubeFiltro != null)
                    Chip(
                      label: Text(_clubeFiltro!),
                      onDeleted: () {
                        setState(() => _clubeFiltro = null);
                        _carregarJogadores();
                      },
                    ),
                ],
              ),
            ),
          Expanded(child: _buildContent()),
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
              onPressed: _carregarJogadores,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_jogadoresFiltrados.isEmpty) {
      return const Center(child: Text('Nenhum jogador encontrado'));
    }

    return RefreshIndicator(
      onRefresh: _carregarJogadores,
      child: ListView.builder(
        itemCount: _jogadoresFiltrados.length,
        itemBuilder: (context, index) {
          final jogador = _jogadoresFiltrados[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCorPosicao(jogador.posicao),
                child: Text(
                  jogador.posicao,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'Média: ${jogador.mediaTemporada.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Últ. 5: ${jogador.mediaUltimas5.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jogador.mediaTemporada.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${jogador.jogos} jogos',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
