class User {
  const User({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
  });

  final int? id;
  final String nombre;
  final String email;
  final String password;

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int?,
      nombre: map['nombre']! as String,
      email: map['email']! as String,
      password: map['password']! as String,
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'email': email.trim().toLowerCase(),
    'password': password,
  };
}

const initialUsers = [
  User(id: 1, nombre: 'Juan Pérez', email: 'usuario@correo.com', password: '123456'),
  User(id: 2, nombre: 'Ana López', email: 'ana@correo.com', password: '654321'),
];
