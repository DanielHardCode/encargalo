import 'package:flutter/material.dart';

import '../models/models.dart';

Color colorEstado(String e) => switch (e) {
      Estado.pendiente => Colors.orange,
      Estado.publicada => Colors.blue,
      Estado.confirmado => Colors.indigo,
      Estado.produccion => Colors.purple,
      Estado.listo => Colors.teal,
      _ => Colors.green,
    };

class EstadoChip extends StatelessWidget {
  final String estado;
  const EstadoChip(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: .15), borderRadius: BorderRadius.circular(20)),
      child: Text(estado, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class SolicitudCard extends StatelessWidget {
  final Solicitud s;
  final VoidCallback onTap;
  const SolicitudCard({super.key, required this.s, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(child: Text('${s.cantidad}')),
          title: Text(s.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${s.categoria} · ${s.distrito}\n${s.fotos.length} foto(s)'),
          isThreeLine: true,
          trailing: EstadoChip(s.estado),
        ),
      );
}

/// Cabecera que indica si hay conexión (concepto central: Offline-First).
class BannerRed extends StatelessWidget {
  final bool online;
  const BannerRed({super.key, required this.online});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: online ? Colors.green.shade600 : Colors.orange.shade800,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(online ? Icons.wifi : Icons.wifi_off, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(online ? 'En línea' : 'Sin conexión: los cambios se guardan en el dispositivo',
              style: const TextStyle(color: Colors.white)),
        ]),
      );
}
