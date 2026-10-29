import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Formulario crear/editar. Recibe una [Solicitud] opcional como argumento.
/// Implementa el ciclo de vida: guarda el borrador temporal al ir a segundo plano.
class FormularioScreen extends StatefulWidget {
  final Solicitud? editar;
  const FormularioScreen({super.key, this.editar});
  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titulo, _detalle, _cantidad, _distrito;
  String _categoria = 'Estampado';
  DateTime _fecha = DateTime.now().add(const Duration(days: 14));
  final List<String> _fotos = [];
  late final AppState _st;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _st = context.read<AppState>();
    final e = widget.editar;
    final b = e == null ? _st.borrador : <String, String>{};
    _titulo = TextEditingController(text: e?.titulo ?? b['titulo']);
    _detalle = TextEditingController(text: e?.detalle ?? b['detalle']);
    _cantidad = TextEditingController(text: e?.cantidad.toString() ?? b['cantidad']);
    _distrito = TextEditingController(text: e?.distrito ?? b['distrito']);
    if (e != null) {
      _categoria = e.categoria;
      _fecha = DateTime.tryParse(e.fecha) ?? _fecha;
      _fotos.addAll(e.fotos);
    } else {
      final categoria = b['categoria'];
      if (const ['Estampado', 'Bordado', 'Impresión'].contains(categoria)) {
        _categoria = categoria!;
      }
      _fecha = DateTime.tryParse(b['fecha'] ?? '') ?? _fecha;
      _fotos.addAll(_restaurarFotos(b['fotos']));
    }
  }

  List<String> _restaurarFotos(String? valor) {
    if (valor == null || valor.isEmpty) return [];
    try {
      final fotos = jsonDecode(valor);
      if (fotos is List && fotos.every((foto) => foto is String)) {
        return fotos.cast<String>().toList();
      }
    } on FormatException {
      // Un borrador antiguo o dañado no debe impedir abrir el formulario.
    }
    return [];
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused && widget.editar == null) {
      await _st.guardarBorradorTemporal({
        'titulo': _titulo.text,
        'detalle': _detalle.text,
        'cantidad': _cantidad.text,
        'distrito': _distrito.text,
        'categoria': _categoria,
        'fecha': _fecha.toIso8601String().substring(0, 10),
        'fotos': jsonEncode(_fotos),
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in [_titulo, _detalle, _cantidad, _distrito]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos una foto')));
      return;
    }
    final nav = Navigator.of(context);
    final id = widget.editar?.id ?? '${DateTime.now().microsecondsSinceEpoch}';
    await _st.guardar(Solicitud(
      id: id,
      titulo: _titulo.text.trim(),
      detalle: _detalle.text.trim(),
      cantidad: int.parse(_cantidad.text),
      fecha: _fecha.toIso8601String().substring(0, 10),
      distrito: _distrito.text.trim(),
      categoria: _categoria,
      estado: widget.editar?.estado ?? Estado.pendiente,
      fotos: _fotos,
    ));
    await _st.limpiarBorradorTemporal();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_st.online ? 'Guardado. Pendiente de sincronizar.' : 'Guardado sin conexión (PENDIENTE).')));
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<AppState>().online;
    return Scaffold(
      appBar: AppBar(title: Text(widget.editar == null ? 'Crear solicitud' : 'Editar solicitud')),
      body: Column(children: [
        BannerRed(online: online),
        Expanded(
          child: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextFormField(controller: _titulo, decoration: const InputDecoration(labelText: 'Título (ej. 30 polos con diseño propio)', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().length < 5) ? 'Mínimo 5 caracteres' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _detalle, maxLines: 3, decoration: const InputDecoration(labelText: 'Detalles y especificaciones', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Describe tu pedido' : null),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: _cantidad, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()), validator: (v) { final n = int.tryParse(v ?? ''); return (n == null || n < 1) ? 'Inválida' : null; })),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(value: _categoria, decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()), items: const ['Estampado', 'Bordado', 'Impresión'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _categoria = v!))),
              ]),
              const SizedBox(height: 12),
              TextFormField(controller: _distrito, decoration: const InputDecoration(labelText: 'Distrito (ej. Piura, Castilla)', prefixIcon: Icon(Icons.place), border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el distrito' : null),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                leading: const Icon(Icons.event),
                title: Text('Fecha deseada: ${_fecha.toIso8601String().substring(0, 10)}'),
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (!mounted) return;
                  if (d != null) setState(() => _fecha = d);
                },
              ),
              const SizedBox(height: 16),
              Text('Fotos (${_fotos.length}/3)', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < _fotos.length; i++)
                  Chip(avatar: const Icon(Icons.image), label: Text(_fotos[i]), onDeleted: () => setState(() => _fotos.removeAt(i))),
                if (_fotos.length < 3)
                  ActionChip(avatar: const Icon(Icons.camera_alt), label: const Text('Agregar foto'), onPressed: () => setState(() => _fotos.add('foto_${_fotos.length + 1}_${DateTime.now().millisecondsSinceEpoch % 10000}.jpg'))),
              ]),
              const Padding(padding: EdgeInsets.only(top: 6), child: Text('Las fotos se cifran y quedan en el dispositivo hasta sincronizar.', style: TextStyle(fontSize: 12))),
              const SizedBox(height: 24),
              FilledButton.icon(icon: const Icon(Icons.save), label: Text(online ? 'Guardar solicitud' : 'Guardar borrador offline'), onPressed: _guardar),
            ]),
          ),
        ),
      ]),
    );
  }
}
