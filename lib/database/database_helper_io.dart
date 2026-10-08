import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../model/hotel.dart';
import '../model/reserva.dart';
import '../model/user.dart';
import 'hotel_data.dart';
import 'hotel_search.dart';

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
      version: 6,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onOpen: _ensureDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database database, int version) async {
    await _createHotelsTables(database);
    await _createUsersTable(database);
    await _createReservationsTable(database);
    await _seedHotels(database);
    await _seedUsers(database);
  }

  Future<void> _createHotelsTables(DatabaseExecutor database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS hoteles (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        imagen TEXT NOT NULL,
        precio_noche REAL NOT NULL,
        calificacion REAL NOT NULL,
        descripcion TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS servicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS hotel_servicios (
        hotel_id INTEGER NOT NULL,
        servicio_id INTEGER NOT NULL,
        PRIMARY KEY (hotel_id, servicio_id),
        FOREIGN KEY (hotel_id) REFERENCES hoteles(id) ON DELETE CASCADE,
        FOREIGN KEY (servicio_id) REFERENCES servicios(id) ON DELETE CASCADE
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

  Future<void> _createReservationsTable(DatabaseExecutor database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS reservas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        hotel_id INTEGER NOT NULL,
        fecha_entrada TEXT NOT NULL,
        fecha_salida TEXT NOT NULL,
        cantidad_personas INTEGER NOT NULL,
        notas TEXT NOT NULL,
        codigo TEXT NOT NULL,
        total REAL NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY (hotel_id) REFERENCES hoteles(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 4) {
      await database.transaction((transaction) async {
        await transaction.execute('ALTER TABLE hoteles RENAME TO hoteles_antiguos');
        await _createHotelsTables(transaction);
        await transaction.execute('''
          INSERT INTO hoteles
            (id, nombre, ubicacion, imagen, precio_noche, calificacion, descripcion)
          SELECT id, nombre, ubicacion, imagen, precio_noche, calificacion, descripcion
          FROM hoteles_antiguos
        ''');
        final oldHotels = await transaction.query('hoteles_antiguos');
        for (final hotel in oldHotels) {
          final services = (hotel['servicios'] as String).split('|');
          await _insertServices(transaction, hotel['id']! as int, services);
        }
        await transaction.execute('DROP TABLE hoteles_antiguos');
        await _createReservationsTable(transaction);
      });
    } else if (oldVersion < 6) {
      // Version 5 to 6 adds ON DELETE CASCADE, but since it's just local dev it's fine to drop and recreate for now,
      // or we can just copy data. Let's drop and recreate for simplicity unless data loss is a huge issue.
      // Wait, let's copy data so we don't lose user reservations in dev.
      await database.transaction((transaction) async {
        await transaction.execute('ALTER TABLE reservas RENAME TO reservas_antiguas');
        await _createReservationsTable(transaction);
        try {
          await transaction.execute('''
            INSERT INTO reservas
              (id, usuario_id, hotel_id, fecha_entrada, fecha_salida, cantidad_personas, notas, codigo, total, estado)
            SELECT id, usuario_id, hotel_id, fecha_entrada, fecha_salida, cantidad_personas, notas, codigo, total, estado
            FROM reservas_antiguas
          ''');
        } catch (e) {
            // Ignore if missing columns (if upgrading from 4 directly, which shouldn't happen here but just in case)
        }
        await transaction.execute('DROP TABLE reservas_antiguas');
      });
    }
  }

  Future<void> _insertServices(
    DatabaseExecutor database,
    int hotelId,
    List<String> services,
  ) async {
    for (final service in services) {
      final name = service.trim();
      if (name.isEmpty) continue;
      await database.insert(
        'servicios',
        {'nombre': name},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      final rows = await database.query(
        'servicios',
        columns: ['id'],
        where: 'nombre = ?',
        whereArgs: [name],
        limit: 1,
      );
      await database.insert('hotel_servicios', {
        'hotel_id': hotelId,
        'servicio_id': rows.first['id'],
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedHotels(Database database) async {
    for (final hotel in initialHotels) {
      await database.insert('hoteles', {
        'id': hotel.id,
        'nombre': hotel.nombre,
        'ubicacion': hotel.ubicacion,
        'imagen': hotel.imagen,
        'precio_noche': hotel.precioNoche,
        'calificacion': hotel.calificacion,
        'descripcion': hotel.descripcion,
      });
      await _insertServices(database, hotel.id, hotel.servicios);
    }
  }

  Future<void> _seedUsers(Database database) async {
    for (final user in initialUsers) {
      await database.insert('usuarios', user.toMap());
    }
  }

  Future<void> _ensureDatabase(Database database) async {
    await _createHotelsTables(database);
    await _createUsersTable(database);
    await _createReservationsTable(database);
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
    final rows = await database.query('hoteles', orderBy: 'calificacion DESC');
    final hotels = <Hotel>[];
    for (final row in rows) {
      final services = await database.rawQuery('''
        SELECT servicios.nombre
        FROM servicios
        INNER JOIN hotel_servicios
          ON hotel_servicios.servicio_id = servicios.id
        WHERE hotel_servicios.hotel_id = ?
        ORDER BY servicios.nombre
      ''', [row['id']]);
      hotels.add(Hotel.fromMap({
        ...row,
        'servicios': services.map((service) => service['nombre'] as String).join('|'),
      }));
    }
    return filtrarHoteles(hotels, search);
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

  Future<bool> updateUser(User user) async {
    if (user.id == null) return false;
    final database = await this.database;
    final valores = Map<String, Object?>.from(user.toMap())..remove('id');
    try {
      final filas = await database.update(
        'usuarios',
        valores,
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return filas > 0;
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) return false;
      rethrow;
    }
  }

  Future<int> addReservation(Reserva reservation) async {
    final database = await this.database;
    return database.insert('reservas', reservation.toMap());
  }

  Future<List<Reserva>> getReservationsForUser(int userId) async {
    final database = await this.database;
    final rows = await database.query(
      'reservas',
      where: 'usuario_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha_entrada DESC',
    );
    return rows.map(Reserva.fromMap).toList();
  }
}
