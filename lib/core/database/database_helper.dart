import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final String dbName;
  static const int dbVersion = 1;

  static const String tableDiseases = 'diseases';
  static const String tableAntibiotics = 'antibiotics';
  static const String tableRecommendations = 'recommendations';

  static DatabaseHelper? _instance;
  Database? _database;

  DatabaseHelper._internal({this.dbName = 'clinical_reference.db'});

  factory DatabaseHelper({String? customDbName}) {
    if (customDbName != null) {
      return DatabaseHelper._internal(dbName: customDbName);
    }
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = dbName == inMemoryDatabasePath ? inMemoryDatabasePath : join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableDiseases (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        keywords TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAntibiotics (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        generic_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableRecommendations (
        id INTEGER PRIMARY KEY,
        disease_id INTEGER NOT NULL,
        antibiotic_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        dose TEXT NOT NULL,
        frequency TEXT NOT NULL,
        duration TEXT NOT NULL,
        FOREIGN KEY (disease_id) REFERENCES $tableDiseases (id) ON DELETE CASCADE,
        FOREIGN KEY (antibiotic_id) REFERENCES $tableAntibiotics (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_diseases_name ON $tableDiseases(name);');
    await db.execute('CREATE INDEX idx_diseases_category ON $tableDiseases(category);');
    await db.execute('CREATE INDEX idx_diseases_keywords ON $tableDiseases(keywords);');
    await db.execute('CREATE INDEX idx_antibiotics_name ON $tableAntibiotics(name);');
    await db.execute('CREATE INDEX idx_antibiotics_generic ON $tableAntibiotics(generic_name);');
    await db.execute('CREATE INDEX idx_recs_disease ON $tableRecommendations(disease_id);');
    await db.execute('CREATE INDEX idx_recs_antibiotic ON $tableRecommendations(antibiotic_id);');
  }

  Future<void> saveClinicalData({
    required List<Map<String, dynamic>> diseases,
    required List<Map<String, dynamic>> antibiotics,
    required List<Map<String, dynamic>> recommendations,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableRecommendations);
      await txn.delete(tableDiseases);
      await txn.delete(tableAntibiotics);

      final batch = txn.batch();
      for (var d in diseases) {
        batch.insert(tableDiseases, d, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var a in antibiotics) {
        batch.insert(tableAntibiotics, a, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var r in recommendations) {
        batch.insert(tableRecommendations, r, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
