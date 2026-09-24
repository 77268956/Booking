class Hotel {
  const Hotel({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.imagen,
    required this.precioNoche,
    required this.calificacion,
    required this.descripcion,
    required this.servicios,
  });

  final int id;
  final String nombre;
  final String ubicacion;
  final String imagen;
  final double precioNoche;
  final double calificacion;
  final String descripcion;
  final List<String> servicios;

  factory Hotel.fromMap(Map<String, Object?> map) {
    return Hotel(
      id: map['id']! as int,
      nombre: map['nombre']! as String,
      ubicacion: map['ubicacion']! as String,
      imagen: map['imagen']! as String,
      precioNoche: (map['precio_noche']! as num).toDouble(),
      calificacion: (map['calificacion']! as num).toDouble(),
      descripcion: map['descripcion']! as String,
      servicios: (map['servicios']! as String).split('|'),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'ubicacion': ubicacion,
    'imagen': imagen,
    'precio_noche': precioNoche,
    'calificacion': calificacion,
    'descripcion': descripcion,
    'servicios': servicios.join('|'),
  };
}
