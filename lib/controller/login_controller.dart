import '../model/user.dart';
import '../database/database_helper.dart';

class LoginController {
  const LoginController();

  Future<bool> authenticate(String email, String password) async {
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    return user != null && user.password == password;
  }

  // agregar un nuevo usuario
  Future<bool> registerUser(
    String nombre,
    String email,
    String password,
  ) async {
    final existingUser = await DatabaseHelper.instance.getUserByEmail(email);
    if (existingUser != null) {
      return false; // El usuario ya existe
    }

    final newUser = User(nombre: nombre, email: email, password: password);
    return DatabaseHelper.instance.addUser(newUser);
  }

  // traer un usuario por correo electrónico
  Future<User?> getUserByEmail(String email) {
    return DatabaseHelper.instance.getUserByEmail(email);
  }
}
