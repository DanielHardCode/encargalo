import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'routes.dart';

/// Pantalla extra: compara cotizaciones recibidas y acepta solo una (RF-06).
/// Requiere conexión (la aceptación no se hace offline).
class CotizacionesScreen extends StatefulWidget {
  final String id;
  const CotizacionesScreen({super.key, required this.id});
  @override
  State<CotizacionesScreen> createState() => _CotizacionesScreenState();
}

class _CotizacionesScreenState extends State<CotizacionesScreen> {
  late Future<List<Cotizacion>> _f;

  @override
  void initState() {
    super.initState();
    _f = context.read<AppState>().cotizaciones(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cotizaciones recibidas')),
      body: Column(children: [
        BannerRed(online: st.online),
        Expanded(
          child: FutureBuilder<List<Cotizacion>>(
            future: _f,
            builder: (_, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final l = [...snap.data!]..sort((a, b) => a.precio.compareTo(b.precio));
              if (l.isEmpty) return const Center(child: Text('Aún no hay cotizaciones'));
              return ListView(padding: const EdgeInsets.all(12), children: [
                for (var i = 0; i < l.length; i++)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(l[i].negocio, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          if (i == 0) const Chip(label: Text('Más económica')),
                        ]),
                        Text('S/ ${l[i].precio.toStringAsFixed(2)}  ·  ${l[i].plazoDias} días', style: const TextStyle(fontSize: 20)),
                        Text(l[i].condiciones),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: !st.online
                              ? null
                              : () async {
                                  final nav = Navigator.of(context);
                                  await st.aceptar(widget.id, l[i].id!);
                                  nav.pushReplacementNamed(Routes.seguimiento, arguments: widget.id);
                                },
                          child: Text(st.online ? 'Aceptar esta cotización' : 'Requiere conexión'),
                        ),
                      ]),
                    ),
                  ),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}
