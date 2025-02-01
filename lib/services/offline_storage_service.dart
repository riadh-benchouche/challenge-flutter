import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
if (dart.library.io) 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'message_service.dart';

class OfflineStorageService {
  static Database? _database;
  static const String tableName = 'pending_messages';

  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        'offline_messages.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    } else {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      String path = join(await getDatabasesPath(), 'offline_messages.db');

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        associationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        status INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> savePendingMessage(Message message) async {
    final Database db = await database;
    await db.insert(
      tableName,
      {
        'id': message.id,
        'content': message.content,
        'associationId': message.associationId,
        'senderId': message.senderId,
        'createdAt': message.createdAt.millisecondsSinceEpoch,
        'status': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> getPendingMessages() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'status = ?',
        whereArgs: [0],
        orderBy: 'createdAt ASC'
    );

    if (AuthService.userData == null) {
      throw Exception('User not authenticated');
    }

    return maps.map((map) => Message(
      id: map['id'],
      content: map['content'],
      associationId: map['associationId'],
      senderId: map['senderId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      sender: User.fromJson(AuthService.userData!),
      association: MessageService.currentAssociation!,
    )).toList();
  }

  Future<void> markMessageAsSent(String messageId) async {
    final Database db = await database;
    await db.update(
      tableName,
      {'status': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final Database db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<bool> hasPendingMessages() async {
    final Database db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName WHERE status = 0')
    );
    return (count ?? 0) > 0;
  }
}