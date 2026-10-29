import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Acceso asíncrono a SQLite (CRUD completo de Solicitud + Cotizaciones).
class AppDatabase {
  static Database? _db;

  static Future<Database> get _database async => _db ??= await openDatabase(
        join(await getDatabasesPath(), 'encargalo.db'),
        version: 1,
        onCreate: (db, v) async {
          await db.execute('''CREATE TABLE solicitudes(
            id TEXT PRIMARY KEY, titulo TEXT, detalle TEXT, cantidad INTEGER,
            fecha TEXT, distrito TEXT, categoria TEXT, estado TEXT, fotos TEXT)''');
          await db.execute('''CREATE TABLE cotizaciones(
            id INTEGER PRIMARY KEY AUTOINCREMENT, solicitud_id TEXT, negocio TEXT,
            precio REAL, plazo_dias INTEGER, condiciones TEXT, estado TEXT)''');
        },
      );

  // CREATE / UPDATE
  Future<void> guardar(Solicitud s) async => (await _database)
      .insert('solicitudes', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  // READ
  Future<List<Solicitud>> listar() async => (await (await _database).query('solicitudes', orderBy: 'rowid DESC'))
      .map(Solicitud.fromMap)
      .toList();

  // DELETE
  Future<void> eliminar(String id) async {
    final db = await _database;
    await db.delete('solicitudes', where: 'id = ?', whereArgs: [id]);
    await db.delete('cotizaciones', where: 'solicitud_id = ?', whereArgs: [id]);
  }

  Future<void> cambiarEstado(String id, String estado) async => (await _database)
      .update('solicitudes', {'estado': estado}, where: 'id = ?', whereArgs: [id]);

  Future<List<Cotizacion>> cotizaciones(String solicitudId) async =>
      (await (await _database).query('cotizaciones', where: 'solicitud_id = ?', whereArgs: [solicitudId]))
          .map(Cotizacion.fromMap)
          .toList();

  Future<void> insertarCotizaciones(List<Cotizacion> l) async {
    final db = await _database;
    final b = db.batch();
    for (final c in l) {
      b.insert('cotizaciones', c.toMap()..remove('id'));
    }
    await b.commit(noResult: true);
  }

  /// Acepta una sola cotización (atómico); las demás pasan a NO SELECCIONADA.
  Future<void> aceptarCotizacion(String solicitudId, int cotizacionId) async {
    final db = await _database;
    await db.transaction((t) async {
      await t.update('cotizaciones', {'estado': 'NO SELECCIONADA'}, where: 'solicitud_id = ?', whereArgs: [solicitudId]);
      await t.update('cotizaciones', {'estado': 'ACEPTADA'}, where: 'id = ?', whereArgs: [cotizacionId]);
      await t.update('solicitudes', {'estado': Estado.confirmado}, where: 'id = ?', whereArgs: [solicitudId]);
    });
  }
}
