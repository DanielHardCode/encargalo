import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final recientes = st.solicitudes.take(3).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${st.usuario}'),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, Routes.ajustes))],
      ),
      body: Column(children: [
        BannerRed(online: st.online),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              _Contador('Pendientes', st.pendientes, Colors.orange, Icons.cloud_off),
              _Contador('Publicadas', st.contar(Estado.publicada), Colors.blue, Icons.cloud_done),
              _Contador('Pedidos', st.solicitudes.where((s) => s.esPedido).length, Colors.indigo, Icons.local_shipping),
            ]),
            const SizedBox(height: 16),
            if (st.pendientes > 0)
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.sync_problem, color: Colors.orange),
                  title: Text('${st.pendientes} borrador(es) por sincronizar'),
                  subtitle: const Text('Se publicarán cuando haya conexión'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, Routes.sync),
                ),
              ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: FilledButton.icon(icon: const Icon(Icons.add), label: const Text('Nueva solicitud'), onPressed: () => Navigator.pushNamed(context, Routes.formulario))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.list), label: const Text('Ver todas'), onPressed: () => Navigator.pushNamed(context, Routes.lista))),
            ]),
            const SizedBox(height: 24),
            const Text('Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (recientes.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Aún no tienes solicitudes.'))),
            for (final s in recientes) SolicitudCard(s: s, onTap: () => Navigator.pushNamed(context, Routes.detalle, arguments: s.id)),
          ]),
        ),
      ]),
    );
  }
}

class _Contador extends StatelessWidget {
  final String label;
  final int valor;
  final Color color;
  final IconData icono;
  const _Contador(this.label, this.valor, this.color, this.icono);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Icon(icono, color: color),
              Text('$valor', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ),
      );
}
