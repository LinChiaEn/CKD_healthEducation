import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDone = 'done';
final String columnEvent = 'event';
final String columnTime = 'time';

class Todo {
  int? id;
  String title = '1';
  bool done = true;
  String event = '1';
  String time ='1';


  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitle: title,
      columnDone: done == true ? 1 : 0,
      columnEvent: event,
      columnTime: time

    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Todo();

  Todo.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int;
    title = map[columnTitle] as String;
    done = map[columnDone] == 1;
    event = map[columnTime] as String;
    time = map[columnTime] as String;
    print("id:$id,title:$title,done:$done,event:$event,time:$time");
  }
}

class TodoProvider {
  Database? db;

  Future open() async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, "1234.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnDone integer not null,
  $columnEvent text not null,
  $columnTime text not null)
''');
    });
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db!.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future<Todo?> getTodo(String time) async {
    List<Map<String,dynamic>> maps = await db!.query(tableTodo,
        columns: [columnEvent],
        where: '$columnTime = ?',
        whereArgs: [time]);
    if (maps.length > 0) {
      return Todo.fromMap(maps.first as Map<String, Object?>);
    }
    return null;
  }


  Future<int> delete(int id) async {
    return await db!.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await db!.update(tableTodo, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db!.close();
}
