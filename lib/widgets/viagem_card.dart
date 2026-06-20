import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/viagem.dart';
import '../theme.dart';
import 'photo_carousel.dart';

/// Card de viagem exibido na home: carrossel no topo + dados resumidos.
class ViagemCard extends StatelessWidget {
  final Viagem viagem;
  final VoidCallback onTap;

  const ViagemCard({super.key, required this.viagem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoCarousel(fotos: viagem.fotos, altura: 190),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place,
                          color: AppTheme.primaria, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          viagem.destino,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(viagem.periodoFormatado,
                      style: const TextStyle(color: AppTheme.cinza)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _chip(Icons.calendar_today,
                          '${viagem.dias} ${viagem.dias == 1 ? "dia" : "dias"}'),
                      const SizedBox(width: 8),
                      _chip(Icons.attach_money, moeda.format(viagem.custo)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaria.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primaria),
          const SizedBox(width: 4),
          Text(texto,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaria,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
