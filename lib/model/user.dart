class User {
  const User({
    required this.nombre,
    required this.email,
    required this.password,
  });

  final String nombre;
  final String email;
  final String password;

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      nombre: map['nombre']! as String,
      email: map['email']! as String,
      password: map['password']! as String,
    );
  }

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'email': email.trim().toLowerCase(),
    'password': password,
  };
}

const initialUsers = [
  User(nombre: 'Juan Pérez', email: 'usuario@correo.com', password: '123456'),
  User(nombre: 'Ana López', email: 'ana@correo.com', password: '654321'),
];
