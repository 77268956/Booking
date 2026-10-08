import '../model/hotel.dart';

const Map<String, String> _sustituciones = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
  'ñ': 'n', 'ç': 'c',
};

String normalizar(String valor) {
  final texto = valor.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final caracter in texto.split('')) {
    buffer.write(_sustituciones[caracter] ?? caracter);
  }
  return buffer.toString();
}

List<Hotel> filtrarHoteles(List<Hotel> hoteles, String consulta) {
  final termino = normalizar(consulta);
  if (termino.isEmpty) return hoteles;

  return hoteles.where((hotel) {
    final campo = normalizar(
      [
        hotel.nombre,
        hotel.ubicacion,
        hotel.descripcion,
        hotel.servicios.join(' '),
      ].join(' '),
    );
    return campo.contains(termino);
  }).toList();
}
