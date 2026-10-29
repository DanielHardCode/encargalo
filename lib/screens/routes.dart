import 'package:flutter/material.dart';

import '../models/models.dart';
import 'ajustes_screen.dart';
import 'cotizaciones_screen.dart';
import 'detalle_screen.dart';
import 'formulario_screen.dart';
import 'lista_screen.dart';
import 'seguimiento_screen.dart';
import 'sync_screen.dart';

class Routes {
  static const lista = '/lista';
  static const formulario = '/formulario';
  static const detalle = '/detalle';
  static const cotizaciones = '/cotizaciones';
  static const seguimiento = '/seguimiento';
  static const sync = '/sync';
  static const ajustes = '/ajustes';

  /// Enrutamiento con paso de argumentos entre pantallas.
  static Route<dynamic>? generar(RouteSettings s) {
    final a = s.arguments;
    final Widget w = switch (s.name) {
      lista => const ListaScreen(),
      formulario => FormularioScreen(editar: a as Solicitud?),
      detalle => DetalleScreen(id: a as String),
      cotizaciones => CotizacionesScreen(id: a as String),
      seguimiento => SeguimientoScreen(id: a as String),
      sync => const SyncScreen(),
      ajustes => const AjustesScreen(),
      _ => const Scaffold(body: Center(child: Text('Ruta desconocida'))),
    };
    return MaterialPageRoute(builder: (_) => w, settings: s);
  }
}
