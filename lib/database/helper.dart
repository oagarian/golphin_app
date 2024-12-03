import 'package:golphin_app/models/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDatabaseHelper {
  static final ChatDatabaseHelper instance = ChatDatabaseHelper._init();
  static Database? _database;

  ChatDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chatMessages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE messages(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT,
          isUserMessage INTEGER
        )
        ''');
      },
    );
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await instance.database;
    await db.insert('messages', message.toMap());
  }

  Future<List<ChatMessage>> getMessages() async {
    final db = await instance.database;
    final maps = await db.query('messages');

    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }
}
