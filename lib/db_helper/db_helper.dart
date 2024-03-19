import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../model/note_model.dart';

class DBHelper {
  late Database _database;
  static const _dbName = "notes.db";
  static const _tableName = "notes";

  Future<Database> get database async {
    _database = await initiateDatabase();
    return _database;
  }

  Future<Database> initiateDatabase() async {
    sqfliteFfiInit();
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Build the path for the database file
    String path = join(documentsDirectory.path, _dbName);
    // Initialize sqflite ffi databaseFactory
    var databaseFactory = databaseFactoryFfi;
    // Open the database or create it if it doesn't exist
    var database = await databaseFactory.openDatabase(path);
    // Create the table if it doesn't exist
    _createDB(database, 1);
    return database;
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  Future<int> insert(Note note) async {
    Database db = await this.database;
    var result = await db.insert(_tableName, note.toJson());
    return result;
  }

  Future<List<Note>> getNotes() async {
    Database db = await this.database;
    List<Map<String, dynamic>> notes = await db.query(_tableName);
    List<Note> noteList = [];
    notes.forEach((element) {
      Note note = Note.fromJson(element);
      noteList.add(note);
    });
    return noteList;
  }

  Future<int> update(Note note) async {
    Database db = await this.database;
    var result = await db.update(
      _tableName,
      note.toJson(),
      where: "id = ?",
      whereArgs: [note.id],
    );
    return result;
  }

  Future<int> delete(int id) async {
    Database db = await this.database;
    var result = await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(
      maps.length,
      (index) {
        return Note(
          id: maps[index]["id"],
          title: maps[index]["title"],
          content: maps[index]["content"],
        );
      },
    );
  }
}
