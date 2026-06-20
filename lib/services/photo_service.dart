import 'package:image_picker/image_picker.dart';
import 'dart:convert';

/// Captura fotos da câmera/galeria e retorna a imagem como string base64,
/// funcionando em web, Android, iOS e desktop.
class PhotoService {
  PhotoService._();
  static final PhotoService instance = PhotoService._();

  final ImagePicker _picker = ImagePicker();

  Future<String?> _paraBase64(XFile? arquivo) async {
    if (arquivo == null) return null;
    final bytes = await arquivo.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String?> tirarFoto() async {
    final x =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    return _paraBase64(x);
  }

  Future<String?> escolherDaGaleria() async {
    final x =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    return _paraBase64(x);
  }
}
