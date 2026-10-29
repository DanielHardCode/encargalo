import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(children: [
        ListTile(leading: const Icon(Icons.person), title: Text(st.usuario ?? ''), subtitle: Text('Rol: ${st.rol}')),
        SwitchListTile(secondary: const Icon(Icons.dark_mode), title: const Text('Modo oscuro'), value: st.oscuro, onChanged: st.setOscuro),
        SwitchListTile(secondary: const Icon(Icons.wifi), title: const Text('Simular conexión a internet'), value: st.online, onChanged: st.setOnline),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('Cambiar rol (demo)'),
          subtitle: Text('Actual: ${st.rol}'),
          onTap: () => st.iniciarSesion(st.usuario!, st.rol == 'Cliente' ? 'Negocio' : 'Cliente'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Cerrar sesión'),
          onTap: () async {
            final nav = Navigator.of(context);
            await st.cerrarSesion();
            nav.popUntil((r) => r.isFirst);
          },
        ),
      ]),
    );
  }
}
