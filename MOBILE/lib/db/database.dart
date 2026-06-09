import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/divida.dart';
import '../models/contato.dart';
import 'dart:io';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'appdividas.db');

  return openDatabase(
    path,
    version: 3, // ALTERAÇÃO: versão incrementada para executar o onUpgrade
    onCreate: (db, version) async {
      // ALTERAÇÃO: adicionado campos descricao e status
      await db.execute('''
        CREATE TABLE dividas(          
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          valor REAL NOT NULL,
          numero_conta INTEGER NOT NULL,
          descricao TEXT,
          status TEXT DEFAULT 'pendente',
          data_criacao TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await db.execute('''
        create table contatos(
          id integer primary key autoincrement,
          nome text not null,
          numero_conta integer not null
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // ALTERAÇÃO: migrate dados da versão antiga para nova
      if (oldVersion < 3) {
        try {
          // Adiciona as novas colunas se não existirem
          await db.execute('ALTER TABLE dividas ADD COLUMN descricao TEXT');
          await db.execute('ALTER TABLE dividas ADD COLUMN status TEXT DEFAULT "pendente"');
          await db.execute('ALTER TABLE dividas ADD COLUMN data_criacao TEXT DEFAULT CURRENT_TIMESTAMP');
          debugPrint('****Banco de dados migrado para versão $newVersion');
        } catch (e) {
          debugPrint('Erro ao migrar banco: $e');
        }
      }
    },
  );
}

// ALTERAÇÃO: função para salvar dívida com descricao e status
Future<int> salvarDivida(Divida divida) async {
  final Database db = await getDatabase();

  final Map<String, dynamic> dividaMap = {
    'valor': divida.valor,
    'numero_conta': divida.numeroConta,
    'descricao': divida.descricao,
    'status': divida.status ?? 'pendente',
  };

  return db.insert('dividas', dividaMap);
}

// ALTERAÇÃO: função para buscar dívidas com todos os campos
Future<List<Divida>> buscarDividas() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> result = await db.query(
    "dividas",
    orderBy: "id DESC", // ALTERAÇÃO: ordena igual a API
  );

  return List.generate(result.length, (i) {
    return Divida(
      result[i]['valor'],
      result[i]['numero_conta'],
      result[i]['descricao'],
      result[i]['status'] ?? 'pendente', // ALTERAÇÃO: valor padrão se null
      id: result[i]['id'], // ALTERAÇÃO: inclui o ID
    );
  });
}

// ALTERAÇÃO: função para atualizar dívida
Future<int> atualizarDivida(Divida divida) async {
  final Database db = await getDatabase();

  final Map<String, dynamic> dividaMap = {
    'valor': divida.valor,
    'numero_conta': divida.numeroConta,
    'descricao': divida.descricao,
    'status': divida.status,
  };

  return db.update(
    'dividas',
    dividaMap,
    where: 'id = ?',
    whereArgs: [divida.id],
  );
}

// ALTERAÇÃO: função para atualizar status da dívida
Future<int> atualizarStatusDivida(int id, String status) async {
  final Database db = await getDatabase();

  return db.update(
    'dividas',
    {'status': status},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// ALTERAÇÃO: função para deletar dívida
Future<int> deletarDivida(int id) async {
  final Database db = await getDatabase();

  return db.delete(
    'dividas',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// ALTERAÇÃO: função para salvar contato (mantida igual mas garantindo campos)
Future<int> salvarContato(Contato contato) async {
  final Database db = await getDatabase();
  return db.insert('contatos', contato.toMap());
}

// ALTERAÇÃO: função para atualizar contato
Future<int> atualizarContato(Contato contato) async {
  final Database db = await getDatabase();

  final Map<String, dynamic> contatoMap = {
    'nome': contato.nome,
    'numero_conta': contato.numeroConta,
  };

  return db.update(
    'contatos',
    contatoMap,
    where: 'id = ?',
    whereArgs: [contato.id],
  );
}

// ALTERAÇÃO: função para deletar contato
Future<int> deletarContato(int id) async {
  final Database db = await getDatabase();

  return db.delete(
    'contatos',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<List<Contato>> buscarContatos() async {
  final Database db = await getDatabase();

  final List<Map<String, dynamic>> resultado = await db.query(
    'contatos',
    orderBy: 'id DESC',
  );

  return List.generate(resultado.length, (i) {
    return Contato(
      id: resultado[i]['id'],
      nome: resultado[i]['nome'],
      numeroConta: resultado[i]['numero_conta'],
    );
  });
}

Future<void> testarBanco() async {
  final String path = join(await getDatabasesPath(), 'appdividas.db');
  final File arquivoBanco = File(path);

  final bool existe = await arquivoBanco.exists();

  if (existe) {
    debugPrint("****Banco de Dados encontrado: $path");

    final Database db = await openDatabase(path);

    final List<Map<String, dynamic>> tabelas = 
      await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    if (tabelas.isNotEmpty) {
      debugPrint("****Tabelas Encontradas: ");
      for (var tabela in tabelas) {
        debugPrint('- ${tabela['name']}');
      }

      // ALTERAÇÃO: verifica estrutura da tabela dividas
      final List<Map<String, dynamic>> colunas = 
        await db.rawQuery("PRAGMA table_info(dividas)");
      
      debugPrint("****Estrutura da tabela dividas:");
      for (var coluna in colunas) {
        debugPrint('- ${coluna['name']} (${coluna['type']})');
      }
    } else {
      debugPrint('****Nenhuma tabela encontrada no banco!');
    }

    await db.close();
  } else {
    debugPrint("XXXX - O arquivo do banco de dados não foi encontrado em: $path");
  }
}