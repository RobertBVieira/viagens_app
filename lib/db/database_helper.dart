import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import '../models/viagem.dart';

/// Camada de acesso ao SQLite. Responsável apenas por persistência.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'viagens.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE viagens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER NOT NULL,
            destino TEXT NOT NULL,
            data_inicio TEXT NOT NULL,
            data_fim TEXT NOT NULL,
            custo REAL NOT NULL DEFAULT 0,
            observacoes TEXT,
            FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE fotos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            viagem_id INTEGER NOT NULL,
            caminho TEXT NOT NULL,
            FOREIGN KEY (viagem_id) REFERENCES viagens (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------------- Usuários ----------------
  Future<int> inserirUsuario(Usuario u) async {
    final db = await database;
    return db.insert('usuarios', u.toMap());
  }

  Future<Usuario?> buscarLogin(String email, String senhaHash) async {
    final db = await database;
    final res = await db.query('usuarios',
        where: 'email = ? AND senha = ?',
        whereArgs: [email, senhaHash],
        limit: 1);
    return res.isEmpty ? null : Usuario.fromMap(res.first);
  }

  Future<bool> emailExiste(String email) async {
    final db = await database;
    final res = await db.query('usuarios',
        where: 'email = ?', whereArgs: [email], limit: 1);
    return res.isNotEmpty;
  }

  // ---------------- Viagens (CRUD) ----------------
  Future<int> inserirViagem(Viagem v, List<String> fotos) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('viagens', v.toMap());
      for (final caminho in fotos) {
        await txn.insert('fotos', {'viagem_id': id, 'caminho': caminho});
      }
      return id;
    });
  }

  Future<List<Viagem>> listarViagens(int usuarioId) async {
    final db = await database;
    final res = await db.query('viagens',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        orderBy: 'data_inicio DESC');

    final viagens = <Viagem>[];
    for (final m in res) {
      final fotos = await _fotosDaViagem(db, m['id'] as int);
      viagens.add(Viagem.fromMap(m, fotos: fotos));
    }
    return viagens;
  }

  Future<int> atualizarViagem(Viagem v, List<String> fotos) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.update('viagens', v.toMap(),
          where: 'id = ?', whereArgs: [v.id]);
      // Substitui o conjunto de fotos (simples e previsível).
      await txn.delete('fotos', where: 'viagem_id = ?', whereArgs: [v.id]);
      for (final caminho in fotos) {
        await txn.insert('fotos', {'viagem_id': v.id, 'caminho': caminho});
      }
      return v.id!;
    });
  }

  Future<int> excluirViagem(int id) async {
    final db = await database;
    return db.delete('viagens', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> _fotosDaViagem(Database db, int viagemId) async {
    final res = await db.query('fotos',
        where: 'viagem_id = ?', whereArgs: [viagemId], orderBy: 'id ASC');
    return res.map((e) => e['caminho'] as String).toList();
  }
}
