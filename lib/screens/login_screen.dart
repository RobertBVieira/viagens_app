import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
  bool _ocultar = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final ok = await AuthService.instance.login(
      _email.text.trim(),
      _senha.text,
    );

    setState(() => _carregando = false);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha inválidos.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaria,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flight_takeoff,
                      size: 56, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('Controle de Viagens',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const Text('Suas viagens em um só lugar',
                    style: TextStyle(color: AppTheme.cinza)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'E-mail inválido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senha,
                  obscureText: _ocultar,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultar
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a senha' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ENTRAR'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CadastroScreen()),
                  ),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
