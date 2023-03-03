import 'ExtramedicinedataModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ExtraDB {
  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "ExtramedicineDb.db"),
      onCreate: (database, verison) async {
        await database.execute("""
        CREATE TABLE MYTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Extramedicinename TEXT NOT NULL,
        ExtraEattime TEXT NOT NULL,
        ExtraBuyplace TEXT NOT　NULL,
        ExtraMedremark TEXT NOT NULL
        )
        """);
      },
      version: 1,
    );
  }

  Future<bool> insertData(ExtraDataModel dataModel) async {
    final Database db = await initDB();
    db.insert("MYTable", dataModel.toMap());
    return true;
  }

  Future<List<ExtraDataModel>> getData() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> datas = await db.query("MYTable");
    return datas.map((e) => ExtraDataModel.fromMap(e)).toList();
  }

  Future<void> update(ExtraDataModel dataModel, int id) async {
    final Database db = await initDB();
    await db
        .update("MYTable", dataModel.toMap(), where: "id=?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final Database db = await initDB();
    await db.delete("MYTable", where: "id=?", whereArgs: [id]);
  }
}