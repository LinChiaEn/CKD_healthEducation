import 'package:Finalproject/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String tableBloodpressureDB = 'bloodpressureDB';
final String columnId = '_id';
final String columnNum = 'num';
final String columnTime = 'time';
final String columnWeekday = 'weekday';
final String columnSd = 'sd';

List<int> weekNumList = []; //get num in one week
List<int> weekTimeList = []; //紀錄星期幾
List<String> weekLineList = []; //紀錄(1)sDay(2)dDay(3)sNight(4)dNight

List<int> monthNumList = []; //get num in one week
List<int> monthTimeList = []; //紀錄幾號
List<String> monthLineList = []; //紀錄(1)sDay(2)dDay(3)sNight(4)dNight

class BloodpressureDB {
  int? id;
  String num = '未知';
  String time = '未知';
  String weekday = '未知';
  String sd = '未知';

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnNum: num,
      columnTime: time,
      columnWeekday: weekday,
      columnSd: sd,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  BloodpressureDB();

  BloodpressureDB.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int;
    num = map[columnNum] as String;
    time = map[columnTime] as String;
    weekday = map[columnWeekday] as String;
    sd = map[columnSd] as String;
    print("id:$id,num:$num,time:$time,weekday:$weekday,sd:$sd");
  }
}

class BloodpressureDBProvider {
  Database? db;

  Future open() async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, "bloodpressure.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table $tableBloodpressureDB ( 
  $columnId integer primary key autoincrement, 
  $columnNum text not null,
  $columnTime integer not null,
  $columnWeekday text not null,
  $columnSd integer not null)
''');
        });
  }

  Future<BloodpressureDB> insert(BloodpressureDB bloodpressureDB) async {
    bloodpressureDB.id =
    await db!.insert(tableBloodpressureDB, bloodpressureDB.toMap());
    return bloodpressureDB;
  }

  Future<BloodpressureDB?> getBloodpressureDB(int id) async {
    List<Map> maps = await db!.query(tableBloodpressureDB,
        columns: [columnId, columnNum, columnTime, columnWeekday, columnSd],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return BloodpressureDB.fromMap(maps.first as Map<String, Object?>);
    }
    return null;
  }

  Future<BloodpressureDB?> checkUpdate1(String weekday, String time) async {
    List<Map> maps = await db!.query(tableBloodpressureDB,
        where: '$columnWeekday = ?', whereArgs: [weekday]);
    var now = DateTime.now();
    print(maps);
    print(maps.length);
    for (int i = 0; i < maps.length; i++) {
      if (maps[i]['time'].substring(0, 10) == time) {
        if (maps[i]['sd'] == 'sDay') {
          checkDaySBP = maps[i]['_id'];
          daySBP = maps[i]['num'];
          print("sDay:" + daySBP);
        }
        if (maps[i]['sd'] == 'dDay') {
          dayDBP = maps[i]['num'];
          checkDayDBP = maps[i]['_id'];
          print("dDay:" + dayDBP);
        }
        if (maps[i]['sd'] == 'sNight') {
          nightSBP = maps[i]['num'];
          checkNightSBP = maps[i]['_id'];
          print("sNight:" + nightSBP);
        }
        if (maps[i]['sd'] == 'dNight') {
          nightDBP = maps[i]['num'];
          checkNightDBP = maps[i]['_id'];
          print("dNight:" + nightDBP);
        }
      }
    }
  }

  Future<int> delete(int id) async {
    return await db!
        .delete(tableBloodpressureDB, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(BloodpressureDB bloodpressureDB) async {
    return await db!.update(tableBloodpressureDB, bloodpressureDB.toMap(),
        where: '$columnId = ?', whereArgs: [bloodpressureDB.id]);
  }

  Future close() async => db!.close();

  Future<BloodpressureDB?> bloodpressureNumWeek() async {
    List<Map> maps = await db!.query(tableBloodpressureDB);
    var now = DateTime.now();
    weekNumList = [];
    weekTimeList = [];
    weekLineList = [];
    print(maps);
    if (now.weekday.toString() != '1') {
      int len = maps.length - 1;
      while (len >= 0) {
        if (maps[len]['weekday'] != '1') {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['sd']);
          len--;
        } else
          break;
      }
      //計算到Monday時
      while (len >= 0) {
        if (maps[len]['weekday'] == '1') {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['sd']);
          len--;
        } else
          break;
      }
      //today is Monday
    } else {
      int len = maps.length - 1;
      while (len >= 0) {
        if (maps[len]['weekday'] == '1') {
          weekNumList.add((int.parse(maps[len]['num']))); //y軸
          weekTimeList.add((int.parse(maps[len]['weekday']))); //x軸
          weekLineList.add(maps[len]['sd']); //num of line
          len--;
        } else
          break;
      }
    }
  }

  Future<BloodpressureDB?> bloodpressureNumWeek1() async {
    List<Map> maps = await db!.query(tableBloodpressureDB);
    var now = DateTime.now();
    weekNumList = [];
    weekTimeList = [];
    weekLineList = [];
    print(maps);
    int week = int.parse(now.weekday.toString());
    int len = maps.length - 1;
    int date = int.parse(now.toString().substring(8, 10));
    int sDay = 0, dDay = 0, sNight = 0, dNight = 0;

    while (len >= 0 && week > 0) {
      //same date
      if (date == int.parse(maps[len]['time'].substring(8, 10))) {
        if (maps[len]['sd'] == 'sDay' && sDay == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['sd']);
          len--;
          sDay = 1;
        } else if (maps[len]['sd'] == 'dDay' && dDay == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['sd']);
          len--;
          dDay = 1;
        } else if (maps[len]['sd'] == 'sNight' && sNight == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['sd']);
          sNight = 1;
        } else if (maps[len]['sd'] == 'dNight' && dNight == 0) {
          weekNumList.add((int.parse(maps[len]['num'])));
          weekTimeList.add((int.parse(maps[len]['weekday'])));
          weekLineList.add(maps[len]['sd']);
          len--;
          dNight = 1;
        } else {
          //資料已滿
          len--;
        }
      } else {
        week--;
        date--;
        sDay = 0;
        dDay = 0;
        sNight = 0;
        dNight = 0;
      }
    }
    print(weekNumList);
    print(weekTimeList);
    print(weekLineList);
  }

  Future<BloodpressureDB?> bloodpressureNumMonth(String time) async {
    List<Map> maps = await db!.query(tableBloodpressureDB);
    var now = DateTime.now();
    monthNumList = [];
    monthTimeList = [];
    monthLineList = [];

    int len = maps.length - 1;
    int date = int.parse(now.toString().substring(8, 10));
    int sDay = 0, dDay = 0, sNight = 0, dNight = 0;

    while (len >= 0 && date > 0) {
      //same date
      if (date == int.parse(maps[len]['time'].substring(8, 10))) {
        if (maps[len]['sd'] == 'sDay' && sDay == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['sd']);
          len--;
          sDay = 1;
        } else if (maps[len]['sd'] == 'dDay' && dDay == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['sd']);
          len--;
          dDay = 1;
        } else if (maps[len]['sd'] == 'sNight' && sNight == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['sd']);
          sNight = 1;
        } else if (maps[len]['sd'] == 'dNight' && dNight == 0) {
          monthNumList.add((int.parse(maps[len]['num'])));
          monthTimeList.add(int.parse(maps[len]['time'].substring(8, 10)));
          monthLineList.add(maps[len]['sd']);
          len--;
          dNight = 1;
        } else {
          //資料已滿
          len--;
        }
      } else {
        date--;
        sDay = 0;
        dDay = 0;
        sNight = 0;
        dNight = 0;
      }
    }

    print("month");
    print(monthNumList);
    print(monthTimeList);
    print(monthLineList);
  }
}

List<int> getBloodpressureWeekNum() {
  return weekNumList.reversed.toList();
}

List<int> getBloodpressureWeekNum1() {
  return weekNumList.reversed.toList();
}

List<int> getBloodpressureWeekTime() {
  return weekTimeList.reversed.toList();
}

List<String> getBloodpressureWeekLine() {
  return weekLineList.reversed.toList();
}

//---------------------------------------
List<int> getBloodpressureMonthNum() {
  return monthNumList.reversed.toList();
}

List<int> getBloodpressureMonthTime() {
  return monthTimeList.reversed.toList();
}

List<String> getBloodpressureMonthLine() {
  return monthLineList.reversed.toList();
}
