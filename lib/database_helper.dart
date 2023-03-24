///
/// Created on 2023/3/20.
/// @author Xie Qin
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'chat_message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String chatMessageTable = 'chat_messages';
  String colId = 'id';
  String colRole = 'role';
  String colContent = 'content';
  String colIsSender = 'isSender';
  String colDateTime = 'dateTime';

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'chat_db');
    final chatMessagesTableSql = '''CREATE TABLE $chatMessageTable(
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colRole TEXT,
      $colContent TEXT,
      $colIsSender INTEGER,
      $colDateTime TEXT
    )''';
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(chatMessagesTableSql);
    });
  }

  Future<List<Map<String, dynamic>>> getChatMessagesMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(chatMessageTable);
    return result;
  }

  Future<List<ChatMessage>> getChatMessagesList() async {
    final List<Map<String, dynamic>> chatMessagesMapList = await getChatMessagesMapList();
    final List<ChatMessage> chatMessagesList = [];
    for (var chatMessageMap in chatMessagesMapList) {
      chatMessagesList.add(ChatMessage.fromMap(chatMessageMap));
    }
    return chatMessagesList;
  }

  Future<int> insertChatMessage(ChatMessage chatMessage) async {
    Database db = await this.db;
    final int result = await db.insert(chatMessageTable, chatMessage.toMap());
    return result;
  }
}
