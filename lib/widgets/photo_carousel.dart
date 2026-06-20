import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Carrossel de fotos com indicador de páginas (bolinhas).
/// Reutilizado no card da home e na tela de detalhes.
class PhotoCarousel extends StatefulWidget {
  final List<String> fotos;
  final double altura;
  final BorderRadius? borderRadius;

  const PhotoCarousel({
    super.key,
    required this.fotos,
    this.altura = 180,
    this.borderRadius,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final _controller = PageController();
  int _atual = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fotos.isEmpty) {
      return Container(
        height: widget.altura,
        decoration: BoxDecoration(
          color: AppTheme.primaria.withOpacity(0.08),
          borderRadius: widget.borderRadius,
        ),
        child: const Center(
          child: Icon(Icons.photo_camera_back_outlined,
              size: 48, color: AppTheme.cinza),
        ),
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: widget.altura,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.fotos.length,
              onPageChanged: (i) => setState(() => _atual = i),
              itemBuilder: (_, i) {
                try {
                  final bytes = base64Decode(widget.fotos[i]);
                  return Image.memory(bytes,
                      width: double.infinity, fit: BoxFit.cover);
                } catch (_) {
                  return Container(
                    color: Colors.black12,
                    child:
                        const Icon(Icons.broken_image, color: AppTheme.cinza),
                  );
                }
              },
            ),
            if (widget.fotos.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.fotos.length, (i) {
                    final ativo = i == _atual;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: ativo ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: ativo ? AppTheme.secundaria : Colors.white70,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
