import 'package:intl/intl.dart';

class Viagem {
  final int? id;
  final int usuarioId;
  final String destino;
  final String dataInicio; // ISO yyyy-MM-dd
  final String dataFim; // ISO yyyy-MM-dd
  final double custo;
  final String observacoes;

  /// Caminhos das fotos (carregados via tabela `fotos`). Não persistido aqui.
  final List<String> fotos;

  Viagem({
    this.id,
    required this.usuarioId,
    required this.destino,
    required this.dataInicio,
    required this.dataFim,
    required this.custo,
    this.observacoes = '',
    this.fotos = const [],
  });

  /// Quantidade de dias da viagem (inclusivo). Mínimo 1.
  int get dias {
    final ini = DateTime.parse(dataInicio);
    final fim = DateTime.parse(dataFim);
    final diff = fim.difference(ini).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  String get periodoFormatado {
    final fmt = DateFormat('dd/MM/yyyy');
    return '${fmt.format(DateTime.parse(dataInicio))} '
        '— ${fmt.format(DateTime.parse(dataFim))}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        'destino': destino,
        'data_inicio': dataInicio,
        'data_fim': dataFim,
        'custo': custo,
        'observacoes': observacoes,
      };

  factory Viagem.fromMap(Map<String, dynamic> m,
          {List<String> fotos = const []}) =>
      Viagem(
        id: m['id'] as int?,
        usuarioId: m['usuario_id'] as int,
        destino: m['destino'] as String,
        dataInicio: m['data_inicio'] as String,
        dataFim: m['data_fim'] as String,
        custo: (m['custo'] as num).toDouble(),
        observacoes: (m['observacoes'] as String?) ?? '',
        fotos: fotos,
      );

  Viagem copyWith({
    String? destino,
    String? dataInicio,
    String? dataFim,
    double? custo,
    String? observacoes,
    List<String>? fotos,
  }) =>
      Viagem(
        id: id,
        usuarioId: usuarioId,
        destino: destino ?? this.destino,
        dataInicio: dataInicio ?? this.dataInicio,
        dataFim: dataFim ?? this.dataFim,
        custo: custo ?? this.custo,
        observacoes: observacoes ?? this.observacoes,
        fotos: fotos ?? this.fotos,
      );
}
