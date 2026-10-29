import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'routes.dart';

/// Detalle: recibe el id de la solicitud como argumento de navegación.
class DetalleScreen extends StatelessWidget {
  final String id;
  const DetalleScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final s = st.porId(id);
    if (s == null) return const Scaffold(body: Center(child: Text('Solicitud no encontrada')));
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de solicitud'), actions: [
        if (s.estado == Estado.pendiente) IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.pushNamed(context, Routes.formulario, arguments: s)),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final nav = Navigator.of(context);
            await st.eliminar(s.id);
            nav.pop();
          },
        ),
      ]),
      body: Column(children: [
        BannerRed(online: st.online),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [Expanded(child: Text(s.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), EstadoChip(s.estado)]),
            const SizedBox(height: 12),
            Text(s.detalle),
            const Divider(height: 32),
            _Dato(Icons.format_list_numbered, 'Cantidad', '${s.cantidad}'),
            _Dato(Icons.category, 'Categoría', s.categoria),
            _Dato(Icons.place, 'Distrito', s.distrito),
            _Dato(Icons.event, 'Fecha deseada', s.fecha),
            _Dato(Icons.fingerprint, 'ID (UUID idempotente)', s.id),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [for (final f in s.fotos) Chip(avatar: const Icon(Icons.lock, size: 16), label: Text(f))]),
            const SizedBox(height: 24),
            if (s.estado == Estado.pendiente)
              FilledButton.icon(icon: const Icon(Icons.cloud_upload), label: const Text('Ir a sincronizar'), onPressed: () => Navigator.pushNamed(context, Routes.sync)),
            if (s.estado == Estado.publicada)
              FilledButton.icon(icon: const Icon(Icons.compare_arrows), label: const Text('Ver y comparar cotizaciones'), onPressed: () => Navigator.pushNamed(context, Routes.cotizaciones, arguments: s.id)),
            if (s.esPedido)
              FilledButton.icon(icon: const Icon(Icons.timeline), label: const Text('Seguimiento del pedido'), onPressed: () => Navigator.pushNamed(context, Routes.seguimiento, arguments: s.id)),
          ]),
        ),
      ]),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String k, v;
  const _Dato(this.icono, this.k, this.v);
  @override
  Widget build(BuildContext context) => ListTile(dense: true, leading: Icon(icono), title: Text(k), subtitle: Text(v));
}
