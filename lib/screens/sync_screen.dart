import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Pantalla extra: cola de sincronización (explica el flujo Offline-First).
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cola = st.solicitudes.where((s) => s.estado == Estado.pendiente).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización')),
      body: Column(children: [
        BannerRed(online: st.online),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Flujo: 1) subir fotos  →  2) publicar solicitud con UUID  →  3) confirmar y marcar SINCRONIZADO.\nLas solicitudes incompletas nunca se publican.'),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(title: const Text('Simular conexión a internet'), subtitle: const Text('Apágalo para probar modo avión'), value: st.online, onChanged: st.setOnline),
            const Divider(),
            Text('Cola (${cola.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (cola.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Todo sincronizado ✔'))),
            for (final s in cola)
              ListTile(leading: const Icon(Icons.cloud_queue, color: Colors.orange), title: Text(s.titulo), subtitle: Text('${s.fotos.length} foto(s) por subir'), trailing: const EstadoChip(Estado.pendiente)),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar ahora'),
              onPressed: cola.isEmpty
                  ? null
                  : () async {
                      final m = ScaffoldMessenger.of(context);
                      final n = await st.sincronizar();
                      m.showSnackBar(SnackBar(content: Text(n < 0 ? 'Sin conexión: se reintentará luego.' : '$n solicitud(es) publicada(s).')));
                    },
            ),
          ]),
        ),
      ]),
    );
  }
}
