import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_app/data/models/todo.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:hive_flutter/hive_flutter.dart'; 

class TodoDatabase {
  static final TodoDatabase _instance = TodoDatabase._internal();
  static Database? _database;
  final _secureStorage = const FlutterSecureStorage();

  TodoDatabase._internal();

  factory TodoDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(documentsDirectory.path, "todo_database.db");

    // Get or generate a secure key
    String? password = await _secureStorage.read(key: 'db_password');
    if (password == null) {
      final secureKey = Hive.generateSecureKey();
      password = secureKey.toString();
      await _secureStorage.write(key: 'db_password', value: password);
    }
    

    // Add this print statement to see the full path
    // print('Database path: $dbPath');

    // In your _initDB() method, after retrieving the password:
    // print('DB Password: $password');

    return await openDatabase(
      dbPath,
      version: 1,
      password: password,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isDone INTEGER)",
        );
      },
    );
  }

  Future<void> createTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

    // --- Utility for Development ---
  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
    _database = null;
    print('Secure storage has been cleared.');
  }

}