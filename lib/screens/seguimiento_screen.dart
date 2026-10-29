import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Pantalla extra: línea de tiempo CONFIRMADO → EN PRODUCCIÓN → LISTO → ENTREGADO.
class SeguimientoScreen extends StatelessWidget {
  final String id;
  const SeguimientoScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final s = st.porId(id);
    if (s == null) return const Scaffold(body: Center(child: Text('Pedido no encontrado')));
    final actual = Estado.pedido.indexOf(s.estado);
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento del pedido')),
      body: Column(children: [
        BannerRed(online: st.online),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(s.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (var i = 0; i < Estado.pedido.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: i <= actual ? colorEstado(Estado.pedido[i]) : Colors.grey.shade300,
                  child: Icon(i <= actual ? Icons.check : Icons.hourglass_empty, color: Colors.white),
                ),
                title: Text(Estado.pedido[i], style: TextStyle(fontWeight: i == actual ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(i == actual ? 'Estado actual' : i < actual ? 'Completado' : 'Pendiente'),
              ),
            const SizedBox(height: 16),
            if (st.rol == 'Negocio' && actual < Estado.pedido.length - 1)
              FilledButton.icon(icon: const Icon(Icons.arrow_forward), label: Text('Marcar como ${Estado.pedido[actual + 1]}'), onPressed: st.online ? () => st.avanzar(s) : null)
            else if (st.rol == 'Negocio')
              const Center(child: Text('Pedido entregado')),
            if (st.rol == 'Cliente')
              const Card(child: ListTile(leading: Icon(Icons.info), title: Text('El negocio actualiza el estado del pedido. Cambia a rol Negocio (Ajustes) para simularlo.'))),
          ]),
        ),
      ]),
    );
  }
}
