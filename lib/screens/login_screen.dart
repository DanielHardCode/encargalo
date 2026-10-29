import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  String _rol = 'Cliente';

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(children: [
                  Icon(Icons.request_quote, size: 72, color: Theme.of(context).colorScheme.primary),
                  const Text('Encárgalo', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text('Pide cotizaciones de productos personalizados', textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(labelText: 'Tu nombre', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length < 3) ? 'Ingresa al menos 3 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Cliente', label: Text('Cliente'), icon: Icon(Icons.shopping_bag)),
                      ButtonSegment(value: 'Negocio', label: Text('Negocio'), icon: Icon(Icons.store)),
                    ],
                    selected: {_rol},
                    onSelectionChanged: (s) => setState(() => _rol = s.first),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (!_form.currentState!.validate()) return;
                        await context.read<AppState>().iniciarSesion(_nombre.text.trim(), _rol);
                      },
                      child: const Text('Ingresar'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('La sesión se guarda en Shared Preferences', style: TextStyle(fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      );
}
