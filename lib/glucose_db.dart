import 'package:Finalproject/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String tableGlucoseDB = 'glucoseDB';
final String columnId = '_id';
final String columnNum = 'num';
final String columnTime = 'time';
final String columnWeekday = 'weekday';
final String columnMeal = 'meal';
//-------line-----------------------------------
List<int> weekNumList = []; //get num in one week
List<int> weekTimeList = []; //紀錄星期幾
List<String> weekLineList = [];

List<int> monthNumList = []; //get num in one week
List<int> monthTimeList = []; //紀錄幾號
List<String> monthLineList = [];

class GlucoseDB {
  int? id;
  String num = '未知';
  String time = '未知';
  String weekday = '未知';
  String meal = '未知';

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnNum: num,
      columnTime: time,
      columnWeekday: weekday,
      columnMeal: meal,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  GlucoseDB();

  GlucoseDB.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int;
    num = map[columnNum] as String;
    time = map[columnTime] as String;
    weekday = map[columnWeekday] as String;
    meal = map[columnMeal] as String;
    print("id:$id,num:$num,time:$time,weekday:$weekday,meal:$meal");
  }
}

class GlucoseDBProvider {
  Database? db;

  Future open() async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, "glucose.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table $tableGlucoseDB ( 
  $columnId integer primary key autoincrement, 
  $columnNum text not null,
  $columnTime integer not null,
  $columnWeekday text not null,
  $columnMeal integer not null)
''');
        });
  }

  Future<GlucoseDB> insert(GlucoseDB glucoseDB) async {
    glucoseDB.id = await db!.insert(tableGlucoseDB, glucoseDB.toMap());
    return glucoseDB;
  }

  Future<GlucoseDB?> getGlucoseDB(int id) async {
    List<Map> maps = await db!.query(tableGlucoseDB,
        columns: [columnId, columnNum, columnTime, columnWeekday, columnMeal],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return GlucoseDB.fromMap(maps.first as Map<String, Object?>);
    }
    return null;
  }

  Future<GlucoseDB?> checkUpdate(String weekday, String time) async {
    List<Map> maps = await db!.query(tableGlucoseDB,
        where: '$columnWeekday = ?', whereArgs: [weekday]);
    var now = DateTime.now();
    print(maps);
    print(maps.length);
    for (int i = 0; i < maps.length; i++) {
      if (maps[i]['time'].substring(0, 10) == time) {
        //日期一樣
        if (maps[i]['meal'] == 'b1') {
          //before morning
          checkBefore1 = maps[i]['_id'];
          before1 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'a1') {
          checkAfter1 = maps[i]['_id'];
          after1 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'b2') {
          checkBefore2 = maps[i]['_id'];
          before2 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'a2') {
          checkAfter2 = maps[i]['_id'];
          after2 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'b3') {
          checkBefore3 = maps[i]['_id'];
          before3 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'a3') {
          checkAfter3 = maps[i]['_id'];
          after3 = maps[i]['num'];
        }
      }
    }
  }

  Future<GlucoseDB?> checkUpdate1(String weekday, String time) async {
    List<Map> maps = await db!.query(tableGlucoseDB,
        where: '$columnWeekday = ?', whereArgs: [weekday]);
    var now = DateTime.now();
    print(maps);
    print(maps.length);
    for (int i = 0; i < maps.length; i++) {
      if (now.toString().substring(0, 10) == time) {
        //日期一樣
        if (maps[i]['meal'] == 'b1') {
          //before morning
          checkBefore1 = maps[i]['_id'];
          before1 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'a1') {
          checkAfter1 = maps[i]['_id'];
          after1 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'b2') {
          checkBefore2 = maps[i]['_id'];
          before2 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'a2') {
          checkAfter2 = maps[i]['_id'];
          after2 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'b3') {
          checkBefore3 = maps[i]['_id'];
          before3 = maps[i]['num'];
        }
        if (maps[i]['meal'] == 'a3') {
          checkAfter3 = maps[i]['_id'];
          after3 = maps[i]['num'];
        }
      }
    }
  }

  Future<int> delete(int id) async {
    return await db!
        .delete(tableGlucoseDB, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(GlucoseDB glucoseDB) async {
    return await db!.update(tableGlucoseDB, glucoseDB.toMap(),
        where: '$columnId = ?', whereArgs: [glucoseDB.id]);
  }

  Future close() async => db!.close();

  Future<GlucoseDB?> glucoseNumWeek() async {
    List<Map> maps = await db!.query(tableGlucoseDB);
    var now = DateTime.now();
    weekNumList = [];
    weekTimeList = [];
    weekLineList = [];
    print(maps);
    int week = int.parse(now.weekday.toString());
    int len = maps.length - 1;
    int date = int.parse(now.toString().substring(8, 10));
    int a1 = 0, a2 = 0, a3 = 0, b1 = 0, b2 = 0, b3 = 0;

    while (len >= 0 && week > 0) {
      if (date == int.parse(maps[len]['time'].substring(8, 10))) {
        if (maps[len]['meal'] == 'a1' && a1 == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['meal']);
          a1 = 1;
          len--;
        } else if (maps[len]['meal'] == 'a2' && a2 == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['meal']);
          a2 = 1;
          len--;
        } else if (maps[len]['meal'] == 'a3' && a3 == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['meal']);
          a3 = 1;
          len--;
        } else if (maps[len]['meal'] == 'b1' && b1 == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['meal']);
          b1 = 1;
          len--;
        } else if (maps[len]['meal'] == 'b2' && b2 == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['meal']);
          b2 = 1;
          len--;
        } else if (maps[len]['meal'] == 'b3' && b3 == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['meal']);
          b3 = 1;
          len--;
        } else {
          len--;
        }
      } else {
        week--;
        date--;
        a1 = 0;
        a2 = 0;
        a3 = 0;
        b1 = 0;
        b2 = 0;
        b3 = 0;
      }
    }
    print(weekNumList);
    print(weekTimeList);
    print(weekLineList);
  }

  Future<GlucoseDB?> glucoseNumMonth(String time) async {
    List<Map> maps = await db!.query(tableGlucoseDB);
    var now = DateTime.now();
    monthNumList = [];
    monthTimeList = [];
    monthLineList = [];

    int len = maps.length - 1;
    int date = int.parse(now.toString().substring(8, 10));
    int a1 = 0, a2 = 0, a3 = 0, b1 = 0, b2 = 0, b3 = 0;

    while (len >= 0 && date > 0) {
      if (date == int.parse(maps[len]['time'].substring(8, 10))) {
        if (maps[len]['meal'] == 'a1' && a1 == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['meal']);
          a1 = 1;
          len--;
        } else if (maps[len]['meal'] == 'a2' && a2 == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['meal']);
          a2 = 1;
          len--;
        } else if (maps[len]['meal'] == 'a3' && a3 == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['meal']);
          a3 = 1;
          len--;
        } else if (maps[len]['meal'] == 'b1' && b1 == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['meal']);
          b1 = 1;
          len--;
        } else if (maps[len]['meal'] == 'b2' && b2 == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['meal']);
          b2 = 1;
          len--;
        } else if (maps[len]['meal'] == 'b3' && b3 == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['meal']);
          b3 = 1;
          len--;
        } else {
          len--;
        }
      } else {
        date--;
        a1 = 0;
        a2 = 0;
        a3 = 0;
        b1 = 0;
        b2 = 0;
        b3 = 0;
      }
    }

    // for (int i = 0; i < maps.length; i++) {
    //   //same month
    //   if (time.toString().substring(0, 7) == now.toString().substring(0, 7)) {
    //     monthNumList.add(int.parse(maps[i]['num']));
    //     monthTimeList.add(int.parse(maps[i]['time'].substring(8, 10)));
    //     monthLineList.add(maps[i]['meal']);
    //   }
    // }
    print('monthNumList');
    print(monthNumList);
    print('monthTimeList');
    print(monthTimeList);
  }
}

List<int> getGlucoseWeekNum() {
  return weekNumList.reversed.toList();
}

List<int> getGlucoseWeekTime() {
  return weekTimeList.reversed.toList();
}

List<String> getGlucoseWeekLine() {
  return weekLineList.reversed.toList();
}

//------------------------------------------
List<int> getGlucoseMonthNum() {
  return monthNumList.reversed.toList();
}

List<int> getGlucoseMonthTime() {
  return monthTimeList.reversed.toList();
}

List<String> getGlucoseMonthLine() {
  return monthLineList.reversed.toList();
}
