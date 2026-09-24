import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../model/hotel.dart';
import '../model/user.dart';
import 'hotel_data.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final path = join(await getDatabasesPath(), 'booking_clone.db');
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: (database, oldVersion, newVersion) => _createTable(database),
      onOpen: _ensureDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database database, int version) async {
    await _createTable(database);
    await _createUsersTable(database);
    await _seedHotels(database);
    await _seedUsers(database);
  }

  Future<void> _createTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS hoteles (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        imagen TEXT NOT NULL,
        precio_noche REAL NOT NULL,
        calificacion REAL NOT NULL,
        descripcion TEXT NOT NULL,
        servicios TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createUsersTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedHotels(Database database) async {
    for (final hotel in initialHotels) {
      await database.insert('hoteles', hotel.toMap());
    }
  }

  Future<void> _seedUsers(Database database) async {
    for (final user in initialUsers) {
      await database.insert('usuarios', user.toMap());
    }
  }

  Future<void> _ensureDatabase(Database database) async {
    await _createTable(database);
    await _createUsersTable(database);
    final result = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM hoteles',
    );
    if ((result.first['total'] as int? ?? 0) == 0) await _seedHotels(database);
    final users = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM usuarios',
    );
    if ((users.first['total'] as int? ?? 0) == 0) await _seedUsers(database);
  }

  Future<List<Hotel>> getHotels({String search = ''}) async {
    final database = await this.database;
    final value = search.trim();
    final rows = await database.query(
      'hoteles',
      where: value.isEmpty ? null : 'nombre LIKE ? OR ubicacion LIKE ?',
      whereArgs: value.isEmpty ? null : ['%$value%', '%$value%'],
      orderBy: 'calificacion DESC',
    );
    return rows.map(Hotel.fromMap).toList();
  }

  Future<User?> getUserByEmail(String email) async {
    final database = await this.database;
    final rows = await database.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }

  Future<bool> addUser(User user) async {
    final database = await this.database;
    try {
      await database.insert('usuarios', user.toMap());
      return true;
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) return false;
      rethrow;
    }
  }
}
