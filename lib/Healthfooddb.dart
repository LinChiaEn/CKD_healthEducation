import 'HealthfooddataModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HealthfoodDB {
  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "HealthfoodDb.db"),
      onCreate: (database, verison) async {
        await database.execute("""
        CREATE TABLE MYTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Healthfoodname TEXT NOT NULL,
        HealthfoodEattime TEXT NOT NULL,
        HealthfoodBuyplace TEXT NOT　NULL,
        Healthfoodremark TEXT NOT NULL
        )
        """);
      },
      version: 1,
    );
  }

  Future<bool> insertData(HealthfoodDataModel dataModel) async {
    final Database db = await initDB();
    db.insert("MYTable", dataModel.toMap());
    return true;
  }

  Future<List<HealthfoodDataModel>> getData() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> datas = await db.query("MYTable");
    return datas.map((e) => HealthfoodDataModel.fromMap(e)).toList();
  }

  Future<void> update(HealthfoodDataModel dataModel, int id) async {
    final Database db = await initDB();
    await db
        .update("MYTable", dataModel.toMap(), where: "id=?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final Database db = await initDB();
    await db.delete("MYTable", where: "id=?", whereArgs: [id]);
  }
}