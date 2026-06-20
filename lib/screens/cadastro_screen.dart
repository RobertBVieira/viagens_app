import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final erro = await AuthService.instance.cadastrar(
      nome: _nome.text.trim(),
      email: _email.text.trim(),
      senha: _senha.text,
    );

    setState(() => _carregando = false);
    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(erro)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada! Faça login.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senha,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v == null || v.length < 4 ? 'Mínimo 4 caracteres' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirma,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v != _senha.text ? 'As senhas não conferem' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('CADASTRAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
