class Reserva {
  const Reserva({
    this.id,
    required this.usuarioId,
    required this.hotelId,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.cantidadPersonas,
    this.notas = '',
    required this.codigo,
    required this.total,
    this.estado = 'pendiente',
  });

  final int? id;
  final int usuarioId;
  final int hotelId;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final int cantidadPersonas;
  final String notas;
  final String codigo;
  final double total;
  final String estado;

  factory Reserva.fromMap(Map<String, Object?> map) {
    return Reserva(
      id: map['id'] as int?,
      usuarioId: map['usuario_id']! as int,
      hotelId: map['hotel_id']! as int,
      fechaEntrada: DateTime.parse(map['fecha_entrada']! as String),
      fechaSalida: DateTime.parse(map['fecha_salida']! as String),
      cantidadPersonas: map['cantidad_personas']! as int,
      notas: map['notas'] as String? ?? '',
      codigo: map['codigo']! as String,
      total: (map['total']! as num).toDouble(),
      estado: map['estado']! as String,
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'usuario_id': usuarioId,
    'hotel_id': hotelId,
    'fecha_entrada': fechaEntrada.toIso8601String(),
    'fecha_salida': fechaSalida.toIso8601String(),
    'cantidad_personas': cantidadPersonas,
    'notas': notas,
    'codigo': codigo,
    'total': total,
    'estado': estado,
  };
}