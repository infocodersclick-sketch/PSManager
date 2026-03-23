import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/password_entry.dart';

class StorageService extends ChangeNotifier {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;
  enc.Key? _encryptionKey;
  final _iv = enc.IV.fromLength(16);
  final _secureStorage = const FlutterSecureStorage();

  List<PasswordEntry> _passwords = [];
  List<PasswordEntry> get passwords => _passwords;

  Future<void> init() async {
    await _initEncryptionKey();
    await _initDatabase();
    await loadPasswords();
  }

  Future<void> _initEncryptionKey() async {
    String? storedKey = await _secureStorage.read(key: 'db_encryption_key');
    if (storedKey == null) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
      storedKey = base64Encode(keyBytes);
      await _secureStorage.write(key: 'db_encryption_key', value: storedKey);
    }
    _encryptionKey = enc.Key.fromBase64(storedKey);
  }

  String _encrypt(String text) {
    if (_encryptionKey == null) return text;
    final encrypter = enc.Encrypter(enc.AES(_encryptionKey!));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  String _decrypt(String encryptedText) {
    if (_encryptionKey == null) return encryptedText;
    try {
      final encrypter = enc.Encrypter(enc.AES(_encryptionKey!));
      return encrypter.decrypt(enc.Encrypted.fromBase64(encryptedText), iv: _iv);
    } catch (e) {
      return '';
    }
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'passwords.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE passwords(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            username TEXT,
            password TEXT,
            category TEXT DEFAULT 'general',
            profilePassword TEXT,
            notes TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE passwords ADD COLUMN category TEXT DEFAULT 'general'");
          await db.execute("ALTER TABLE passwords ADD COLUMN profilePassword TEXT");
          await db.execute("ALTER TABLE passwords ADD COLUMN notes TEXT");
        }
      },
    );
  }

  Future<void> loadPasswords() async {
    if (_database == null) return;
    final List<Map<String, dynamic>> maps = await _database!.query('passwords', orderBy: 'id DESC');
    _passwords = maps.map((map) {
      return PasswordEntry(
        id: map['id'],
        title: map['title'],
        username: map['username'],
        password: _decrypt(map['password']),
        category: map['category'] ?? 'general',
        profilePassword: map['profilePassword'] != null && map['profilePassword'].isNotEmpty
            ? _decrypt(map['profilePassword'])
            : null,
        notes: map['notes'],
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addPassword(PasswordEntry entry) async {
    final encryptedMap = {
      'title': entry.title,
      'username': entry.username,
      'password': _encrypt(entry.password),
      'category': entry.category,
      'profilePassword': entry.profilePassword != null && entry.profilePassword!.isNotEmpty
          ? _encrypt(entry.profilePassword!)
          : null,
      'notes': entry.notes,
    };
    await _database!.insert('passwords', encryptedMap);
    await loadPasswords();
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    final encryptedMap = {
      'title': entry.title,
      'username': entry.username,
      'password': _encrypt(entry.password),
      'category': entry.category,
      'profilePassword': entry.profilePassword != null && entry.profilePassword!.isNotEmpty
          ? _encrypt(entry.profilePassword!)
          : null,
      'notes': entry.notes,
    };
    await _database!.update(
      'passwords',
      encryptedMap,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    await loadPasswords();
  }

  Future<void> deletePassword(int id) async {
    await _database!.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadPasswords();
  }

  Future<String> getDatabasePathStr() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'passwords.db');
  }
}
