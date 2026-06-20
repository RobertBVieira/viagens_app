import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const ViagensApp());
}

class ViagensApp extends StatelessWidget {
  const ViagensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Viagens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
