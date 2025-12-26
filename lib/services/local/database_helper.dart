import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:library_app/models/reservation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'library_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reservations(
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        userId TEXT NOT NULL,
        bookTitle TEXT NOT NULL,
        bookThumbnail TEXT,
        reservationDate TEXT NOT NULL,
        returnDate TEXT,
        status TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations
  Future<int> insertReservation(Reservation reservation) async {
    final db = await database;
    return await db.insert(
      'reservations',
      reservation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reservation>> getReservationsByUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'reservations',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'reservationDate DESC',
    );

    return maps.map((map) => Reservation.fromMap(map)).toList();
  }

  Future<int> updateReservation(Reservation reservation) async {
    final db = await database;
    return await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<int> deleteReservation(String id) async {
    final db = await database;
    return await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
  }
}
