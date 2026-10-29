import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../models/models.dart';

/// Gestión de estado (Provider + ChangeNotifier): separa lógica de la vista.
class AppState extends ChangeNotifier {
  final AppDatabase _db = AppDatabase();
  late SharedPreferences _prefs;

  List<Solicitud> solicitudes = [];
  String? usuario; // sesión (Shared Preferences)
  String rol = 'Cliente';
  bool oscuro = false;
  bool online = true; // interruptor para simular el modo avión
  bool cargando = true;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    usuario = _prefs.getString('usuario');
    rol = _prefs.getString('rol') ?? 'Cliente';
    oscuro = _prefs.getBool('oscuro') ?? false;
    online = _prefs.getBool('online') ?? true;
    await cargar();
    cargando = false;
    notifyListeners();
  }

  Future<void> cargar() async {
    solicitudes = await _db.listar();
    notifyListeners();
  }

  Future<void> iniciarSesion(String nombre, String r) async {
    usuario = nombre;
    rol = r;
    await _prefs.setString('usuario', nombre);
    await _prefs.setString('rol', r);
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    usuario = null;
    await _prefs.remove('usuario');
    notifyListeners();
  }

  Future<void> setOscuro(bool v) async {
    oscuro = v;
    await _prefs.setBool('oscuro', v);
    notifyListeners();
  }

  Future<void> setOnline(bool v) async {
    online = v;
    await _prefs.setBool('online', v);
    notifyListeners();
  }

  // Borrador temporal del formulario (ciclo de vida: app a segundo plano).
  // Las fotos se representan como una lista JSON de referencias simuladas.
  static const _camposBorrador = [
    'titulo',
    'detalle',
    'cantidad',
    'distrito',
    'categoria',
    'fecha',
    'fotos',
  ];

  Map<String, String> get borrador =>
      {for (final k in _camposBorrador) k: _prefs.getString('b_$k') ?? ''};

  Future<void> guardarBorradorTemporal(Map<String, String> m) async {
    for (final e in m.entries) {
      await _prefs.setString('b_${e.key}', e.value);
    }
  }

  Future<void> limpiarBorradorTemporal() async {
    for (final k in _camposBorrador) {
      await _prefs.remove('b_$k');
    }
  }

  Future<void> guardar(Solicitud s) async {
    await _db.guardar(s);
    await cargar();
  }

  Future<void> eliminar(String id) async {
    await _db.eliminar(id);
    await cargar();
  }

  Solicitud? porId(String id) {
    for (final s in solicitudes) {
      if (s.id == id) return s;
    }
    return null;
  }

  int contar(String estado) => solicitudes.where((s) => s.estado == estado).length;

  int get pendientes => contar(Estado.pendiente);

  /// Sincroniza: publica borradores (solo con red) y recibe cotizaciones simuladas.
  /// Devuelve la cantidad de solicitudes publicadas.
  Future<int> sincronizar() async {
    if (!online) return -1;
    var n = 0;
    for (final s in solicitudes.where((s) => s.estado == Estado.pendiente)) {
      await _db.cambiarEstado(s.id, Estado.publicada);
      await _db.insertarCotizaciones([
        Cotizacion(solicitudId: s.id, negocio: 'Estampados Piura', precio: 18.0 * s.cantidad, plazoDias: 7, condiciones: 'Incluye diseño y 1 prueba.'),
        Cotizacion(solicitudId: s.id, negocio: 'Textil Norte', precio: 15.5 * s.cantidad, plazoDias: 10, condiciones: 'Entrega en taller.'),
        Cotizacion(solicitudId: s.id, negocio: 'Bordados Tacalá', precio: 21.0 * s.cantidad, plazoDias: 5, condiciones: 'Bordado premium.'),
      ]);
      n++;
    }
    await cargar();
    return n;
  }

  Future<List<Cotizacion>> cotizaciones(String id) => _db.cotizaciones(id);

  Future<void> aceptar(String solicitudId, int cotizacionId) async {
    await _db.aceptarCotizacion(solicitudId, cotizacionId);
    await cargar();
  }

  Future<void> avanzar(Solicitud s) async {
    final i = Estado.pedido.indexOf(s.estado);
    if (i < 0 || i >= Estado.pedido.length - 1) return;
    await _db.cambiarEstado(s.id, Estado.pedido[i + 1]);
    await cargar();
  }
}
