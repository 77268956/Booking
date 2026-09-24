import '../model/hotel.dart';

const initialHotels = [
  Hotel(
    id: 1,
    nombre: 'Hotel Paraíso',
    ubicacion: 'Cancún, México',
    imagen:
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200',
    precioNoche: 120,
    calificacion: 4.8,
    descripcion:
        'Una estancia tranquila frente al mar, con habitaciones amplias y atención personalizada.',
    servicios: [
      'Piscina',
      'Wi-Fi gratis',
      'Desayuno incluido',
      'Playa privada',
    ],
  ),
  Hotel(
    id: 2,
    nombre: 'Casa Madrid Centro',
    ubicacion: 'Madrid, España',
    imagen: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200',
    precioNoche: 95,
    calificacion: 4.6,
    descripcion:
        'Alojamiento moderno en el centro de Madrid, cerca de restaurantes, museos y transporte público.',
    servicios: ['Wi-Fi gratis', 'Aire acondicionado', 'Recepción 24 horas'],
  ),
  Hotel(
    id: 3,
    nombre: 'The Urban Loft',
    ubicacion: 'Nueva York, Estados Unidos',
    imagen:
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=1200',
    precioNoche: 180,
    calificacion: 4.7,
    descripcion:
        'Un loft urbano con diseño contemporáneo y vistas increíbles de la ciudad.',
    servicios: ['Gimnasio', 'Bar', 'Wi-Fi gratis', 'Mascotas permitidas'],
  ),
];
