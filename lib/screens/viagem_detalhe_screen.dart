import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/viagem.dart';
import '../theme.dart';
import '../widgets/photo_carousel.dart';
import 'viagem_form_screen.dart';

class ViagemDetalheScreen extends StatefulWidget {
  final Viagem viagem;
  const ViagemDetalheScreen({super.key, required this.viagem});

  @override
  State<ViagemDetalheScreen> createState() => _ViagemDetalheScreenState();
}

class _ViagemDetalheScreenState extends State<ViagemDetalheScreen> {
  final _db = DatabaseHelper.instance;
  late Viagem _viagem;
  bool _mudou = false;

  @override
  void initState() {
    super.initState();
    _viagem = widget.viagem;
  }

  Future<void> _editar() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ViagemFormScreen(viagem: _viagem)),
    );
    if (salvou == true) {
      // Recarrega a viagem atualizada.
      final lista = await _db.listarViagens(_viagem.usuarioId);
      final atualizada = lista.firstWhere((v) => v.id == _viagem.id,
          orElse: () => _viagem);
      setState(() {
        _viagem = atualizada;
        _mudou = true;
      });
    }
  }

  Future<void> _excluir() async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir viagem'),
        content: Text('Excluir a viagem para ${_viagem.destino}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirma == true) {
      await _db.excluirViagem(_viagem.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _mudou);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_viagem.destino),
          actions: [
            IconButton(
                onPressed: _editar,
                icon: const Icon(Icons.edit),
                tooltip: 'Editar'),
            IconButton(
                onPressed: _excluir,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Excluir'),
          ],
        ),
        body: ListView(
          children: [
            PhotoCarousel(fotos: _viagem.fotos, altura: 260),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_viagem.destino,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _linha(Icons.date_range, 'Período',
                      _viagem.periodoFormatado),
                  _linha(Icons.event, 'Duração',
                      '${_viagem.dias} ${_viagem.dias == 1 ? "dia" : "dias"}'),
                  _linha(Icons.attach_money, 'Custo',
                      moeda.format(_viagem.custo)),
                  if (_viagem.observacoes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Observações',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(_viagem.observacoes,
                        style: const TextStyle(color: AppTheme.texto)),
                  ],
                  const SizedBox(height: 12),
                  Text('${_viagem.fotos.length} foto(s)',
                      style: const TextStyle(color: AppTheme.cinza)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(IconData icon, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaria.withOpacity(0.1),
            child: Icon(icon, size: 18, color: AppTheme.primaria),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      color: AppTheme.cinza, fontSize: 12)),
              Text(valor,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
