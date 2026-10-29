import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'routes.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});
  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  String? _filtro;
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final items = st.solicitudes
        .where((s) => (_filtro == null || s.estado == _filtro) && s.titulo.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis solicitudes')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        onPressed: () => Navigator.pushNamed(context, Routes.formulario),
      ),
      body: Column(children: [
        BannerRed(online: st.online),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por título', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _busqueda = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
            Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: const Text('Todas'), selected: _filtro == null, onSelected: (_) => setState(() => _filtro = null))),
            for (final e in Estado.todos)
              Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(e), selected: _filtro == e, onSelected: (_) => setState(() => _filtro = e))),
          ]),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No hay solicitudes'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final s = items[i];
                    return Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      confirmDismiss: (_) async =>
                          await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('¿Eliminar solicitud?'),
                              content: Text(s.titulo),
                              actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar'))],
                            ),
                          ) ??
                          false,
                      onDismissed: (_) => st.eliminar(s.id),
                      child: SolicitudCard(s: s, onTap: () => Navigator.pushNamed(context, Routes.detalle, arguments: s.id)),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
