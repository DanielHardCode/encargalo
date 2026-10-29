/// Estados de la solicitud / pedido (según el informe técnico de Encárgalo).
class Estado {
  static const pendiente = 'PENDIENTE'; // borrador local, aún sin publicar
  static const publicada = 'SINCRONIZADO'; // publicada en el servidor
  static const confirmado = 'CONFIRMADO'; // cotización aceptada
  static const produccion = 'EN PRODUCCIÓN';
  static const listo = 'LISTO';
  static const entregado = 'ENTREGADO';

  static const pedido = [confirmado, produccion, listo, entregado];
  static const todos = [pendiente, publicada, confirmado, produccion, listo, entregado];
}

class Solicitud {
  final String id; // UUID (idempotencia)
  final String titulo;
  final String detalle;
  final int cantidad;
  final String fecha;
  final String distrito;
  final String categoria;
  final String estado;
  final List<String> fotos;

  const Solicitud({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.cantidad,
    required this.fecha,
    required this.distrito,
    required this.categoria,
    required this.estado,
    required this.fotos,
  });

  bool get esPedido => Estado.pedido.contains(estado);

  Solicitud copyWith({String? estado}) => Solicitud(
        id: id,
        titulo: titulo,
        detalle: detalle,
        cantidad: cantidad,
        fecha: fecha,
        distrito: distrito,
        categoria: categoria,
        estado: estado ?? this.estado,
        fotos: fotos,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'titulo': titulo,
        'detalle': detalle,
        'cantidad': cantidad,
        'fecha': fecha,
        'distrito': distrito,
        'categoria': categoria,
        'estado': estado,
        'fotos': fotos.join('|'),
      };

  factory Solicitud.fromMap(Map<String, Object?> m) => Solicitud(
        id: m['id'] as String,
        titulo: m['titulo'] as String,
        detalle: m['detalle'] as String,
        cantidad: m['cantidad'] as int,
        fecha: m['fecha'] as String,
        distrito: m['distrito'] as String,
        categoria: m['categoria'] as String,
        estado: m['estado'] as String,
        fotos: (m['fotos'] as String).isEmpty ? [] : (m['fotos'] as String).split('|'),
      );
}

class Cotizacion {
  final int? id;
  final String solicitudId;
  final String negocio;
  final double precio;
  final int plazoDias;
  final String condiciones;
  final String estado; // PENDIENTE DE RESPUESTA | ACEPTADA | NO SELECCIONADA

  const Cotizacion({
    this.id,
    required this.solicitudId,
    required this.negocio,
    required this.precio,
    required this.plazoDias,
    required this.condiciones,
    this.estado = 'PENDIENTE DE RESPUESTA',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'solicitud_id': solicitudId,
        'negocio': negocio,
        'precio': precio,
        'plazo_dias': plazoDias,
        'condiciones': condiciones,
        'estado': estado,
      };

  factory Cotizacion.fromMap(Map<String, Object?> m) => Cotizacion(
        id: m['id'] as int,
        solicitudId: m['solicitud_id'] as String,
        negocio: m['negocio'] as String,
        precio: (m['precio'] as num).toDouble(),
        plazoDias: m['plazo_dias'] as int,
        condiciones: m['condiciones'] as String,
        estado: m['estado'] as String,
      );
}
