import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/viagem.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/viagem_card.dart';
import 'login_screen.dart';
import 'viagem_form_screen.dart';
import 'viagem_detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<Viagem> _viagens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final id = AuthService.instance.usuarioLogado!.id!;
    final viagens = await _db.listarViagens(id);
    setState(() {
      _viagens = viagens;
      _carregando = false;
    });
  }

  // ----- Funcionalidade aplicada ao tema -----
  double get _gastoTotal => _viagens.fold(0.0, (s, v) => s + v.custo);
  int get _diasTotais => _viagens.fold(0, (s, v) => s + v.dias);

  Future<void> _abrirForm({Viagem? viagem}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ViagemFormScreen(viagem: viagem)),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _abrirDetalhe(Viagem v) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ViagemDetalheScreen(viagem: v)),
    );
    if (mudou == true) _carregar();
  }

  void _sair() {
    AuthService.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = AuthService.instance.usuarioLogado?.nome ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        actions: [
          IconButton(
              onPressed: _sair,
              icon: const Icon(Icons.logout),
              tooltip: 'Sair'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova viagem'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Olá, $nome 👋',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _dashboard(),
                  const SizedBox(height: 20),
                  const Text('Viagens registradas',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_viagens.isEmpty)
                    _vazio()
                  else
                    ..._viagens.map((v) => ViagemCard(
                          viagem: v,
                          onTap: () => _abrirDetalhe(v),
                        )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  /// Painel com gasto total + dias viajados (funcionalidade aplicada).
  Widget _dashboard() {
    return Row(
      children: [
        Expanded(
          child: _cardResumo(
            icon: Icons.attach_money,
            cor: AppTheme.secundaria,
            titulo: 'Gasto total',
            valor: _moeda.format(_gastoTotal),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _cardResumo(
            icon: Icons.event,
            cor: AppTheme.primaria,
            titulo: 'Dias viajados',
            valor: '$_diasTotais',
          ),
        ),
      ],
    );
  }

  Widget _cardResumo({
    required IconData icon,
    required Color cor,
    required String titulo,
    required String valor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cor.withOpacity(0.15),
              child: Icon(icon, color: cor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(valor,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(titulo,
                style: const TextStyle(color: AppTheme.cinza, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _vazio() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.luggage, size: 56, color: AppTheme.cinza),
          SizedBox(height: 12),
          Text('Nenhuma viagem ainda.',
              style: TextStyle(color: AppTheme.cinza)),
          Text('Toque em "Nova viagem" para começar.',
              style: TextStyle(color: AppTheme.cinza, fontSize: 12)),
        ],
      ),
    );
  }
}
