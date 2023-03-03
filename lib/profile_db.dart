import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String tableProfileDB = 'profileDB';
final String columnId = '_id';
final String columnName = 'name';
final String columnAge = 'age';
final String columnHospital = 'hospital';
final String columnphone = 'phone';
final String columnthing = 'thing';

String pName = "";
String pAge = "";
String pHospital = "";
String pPhone = "";
String pThing = "";

int profileIntial = 1;

class ProfileDB {
  int? id;
  String name = '尚未輸入';
  String age = '尚未輸入';
  String hospital = '尚未輸入';
  String phone = '尚未輸入';
  String thing = '尚未輸入';

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnName: name,
      columnAge: age,
      columnHospital: hospital,
      columnphone: phone,
      columnthing: thing,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ProfileDB();

  ProfileDB.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int;
    name = map[columnName] as String;
    age = map[columnAge] as String;
    hospital = map[columnHospital] as String;
    phone = map[columnphone] as String;
    thing = map[columnthing] as String;
    print(
        "id:$id,name:$name,age:$age,hospital:$hospital,phone:$phone,thing:$thing");
  }
}

class ProfileDBProvider {
  Database? db;

  Future open() async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, "profile.db");

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table $tableProfileDB ( 
  $columnId integer primary key autoincrement, 
  $columnName text not null,
  $columnAge text not null,
  $columnHospital text not null,
  $columnphone text not null,
  $columnthing text not null)
''');
        });
  }

  Future<ProfileDB> insert(ProfileDB profileDB) async {
    profileDB.id = await db!.insert(tableProfileDB, profileDB.toMap());
    return profileDB;
  }

  Future<ProfileDB?> getProfileDB(int id) async {
    List<Map> maps = await db!.query(tableProfileDB,
        columns: [
          columnId,
          columnName,
          columnAge,
          columnHospital,
          columnphone,
          columnthing
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      profileIntial = 1;
      return ProfileDB.fromMap(maps.first as Map<String, Object?>);
    } else {
      profileIntial = 0;
    }
    return null;
  }

  Future<ProfileDB?> getProfileName(int id) async {
    List<Map> maps = await db!.query(tableProfileDB,
        columns: [
          columnId,
          columnName,
          columnAge,
          columnHospital,
          columnphone,
          columnthing
        ],
        where: '$columnId = ?',
        whereArgs: [id]);

    pName = maps.first[columnName];
    pAge = maps.first[columnAge];
    pHospital = maps.first[columnHospital];
    pPhone = maps.first[columnphone];
    pThing = maps.first[columnthing];
    //print(pName + maps.first[columnName]);

    return null;
  }

  Future<int> delete(int id) async {
    return await db!
        .delete(tableProfileDB, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(ProfileDB profileDB) async {
    return await db!.update(tableProfileDB, profileDB.toMap(),
        where: '$columnId = ?', whereArgs: [profileDB.id]);
  }

  Future close() async => db!.close();
}
