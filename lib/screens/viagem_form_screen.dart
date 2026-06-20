import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/viagem.dart';
import '../services/auth_service.dart';
import '../services/photo_service.dart';
import '../theme.dart';

class ViagemFormScreen extends StatefulWidget {
  final Viagem? viagem; // null = nova
  const ViagemFormScreen({super.key, this.viagem});

  @override
  State<ViagemFormScreen> createState() => _ViagemFormScreenState();
}

class _ViagemFormScreenState extends State<ViagemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;

  late final TextEditingController _destino;
  late final TextEditingController _custo;
  late final TextEditingController _obs;
  DateTime? _inicio;
  DateTime? _fim;
  List<String> _fotos = [];
  bool _salvando = false;

  bool get _editando => widget.viagem != null;

  @override
  void initState() {
    super.initState();
    final v = widget.viagem;
    _destino = TextEditingController(text: v?.destino ?? '');
    _custo = TextEditingController(
        text: v != null ? v.custo.toStringAsFixed(2) : '');
    _obs = TextEditingController(text: v?.observacoes ?? '');
    _inicio = v != null ? DateTime.parse(v.dataInicio) : null;
    _fim = v != null ? DateTime.parse(v.dataFim) : null;
    _fotos = List<String>.from(v?.fotos ?? []);
  }

  @override
  void dispose() {
    _destino.dispose();
    _custo.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _selecionarData({required bool inicio}) async {
    final base = inicio ? (_inicio ?? DateTime.now()) : (_fim ?? _inicio ?? DateTime.now());
    final data = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data == null) return;
    setState(() {
      if (inicio) {
        _inicio = data;
        if (_fim != null && _fim!.isBefore(data)) _fim = data;
      } else {
        _fim = data;
      }
    });
  }

  Future<void> _adicionarFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.pop(context);
                final p = await PhotoService.instance.tirarFoto();
                if (p != null) setState(() => _fotos.add(p));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                Navigator.pop(context);
                final p = await PhotoService.instance.escolherDaGaleria();
                if (p != null) setState(() => _fotos.add(p));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_inicio == null || _fim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione as datas da viagem.')),
      );
      return;
    }
    setState(() => _salvando = true);

    final fmt = DateFormat('yyyy-MM-dd');
    final custo = double.tryParse(_custo.text.replaceAll(',', '.')) ?? 0;
    final usuarioId = AuthService.instance.usuarioLogado!.id!;

    if (_editando) {
      final atualizada = widget.viagem!.copyWith(
        destino: _destino.text.trim(),
        dataInicio: fmt.format(_inicio!),
        dataFim: fmt.format(_fim!),
        custo: custo,
        observacoes: _obs.text.trim(),
      );
      await _db.atualizarViagem(atualizada, _fotos);
    } else {
      final nova = Viagem(
        usuarioId: usuarioId,
        destino: _destino.text.trim(),
        dataInicio: fmt.format(_inicio!),
        dataFim: fmt.format(_fim!),
        custo: custo,
        observacoes: _obs.text.trim(),
      );
      await _db.inserirViagem(nova, _fotos);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar viagem' : 'Nova viagem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _destino,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o destino' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _campoData(
                      label: 'Início',
                      data: _inicio,
                      texto: _inicio == null ? 'Selecionar' : fmt.format(_inicio!),
                      onTap: () => _selecionarData(inicio: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campoData(
                      label: 'Fim',
                      data: _fim,
                      texto: _fim == null ? 'Selecionar' : fmt.format(_fim!),
                      onTap: () => _selecionarData(inicio: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _custo,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custo (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o custo';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obs,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fotos da viagem',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _adicionarFoto,
                    icon: const Icon(Icons.add_a_photo, size: 18),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _gridFotos(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_editando ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoData({
    required String label,
    required DateTime? data,
    required String texto,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month),
        ),
        child: Text(texto,
            style: TextStyle(
                color: data == null ? AppTheme.cinza : AppTheme.texto)),
      ),
    );
  }

  Widget _gridFotos() {
    if (_fotos.isEmpty) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: const Text('Nenhuma foto adicionada',
            style: TextStyle(color: AppTheme.cinza)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_fotos.length, (i) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(base64Decode(_fotos[i]),
                  width: 90, height: 90, fit: BoxFit.cover),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () => setState(() => _fotos.removeAt(i)),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
