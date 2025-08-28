import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database.dart';
import '../model/history_model.dart';

class HistoryDao {
  Future<History> inserir(History history) async {
    final db = await AppDatabase.instance.database;
    final id = await db.insert('history', history.toMap());
    return history.copyWith(id: id);
  }

  Future<List<History>> buscarTodos() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('history');
    return result.map((map) => History.fromMap(map)).toList();
  }

  Future<History?> buscarPorId(int id) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('history', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return History.fromMap(result.first);
    }
    return null;
  }

  Future<int> deletar(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> postarHistory(String texto) async {
    final dao = HistoryDao();

    final novo = History(texto: texto);

    await dao.inserir(novo);
    print("Histórico salvo localmente: ${novo.texto}");
  }
}
