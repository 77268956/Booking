import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import '../model/user.dart';
import 'home.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, LoginController? controller})
    : controller = controller ?? const LoginController();

  final LoginController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Definición de colores estilo Booking.com
  static const Color bookingBlue = Color(0xFF003580); // Azul oscuro del header
  static const Color bookingYellow = Color(
    0xFFFEBB02,
  ); // Amarillo del botón principal
  static const Color bookingLightBlue = Color(
    0xFF0071C2,
  ); // Azul para enlaces/acentos
  static const Color bookingDarkText = Color(0xFF333333); // Texto casi negro

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    bool isAuthenticated;
    try {
      isAuthenticated = await widget.controller.authenticate(
        _emailController.text,
        _passwordController.text,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo consultar la base de datos'),
          ),
        );
      }
      return;
    }
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (isAuthenticated) {
      User? user;
      try {
        user = await widget.controller.getUserByEmail(_emailController.text);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo consultar la base de datos'),
            ),
          );
        }
        return;
      }
      if (!mounted) return;
      final authenticatedUser = user;
      if (authenticatedUser == null) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
          ),
        );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => HomePage(user: authenticatedUser),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Correo o contraseña incorrectos'),
          backgroundColor: Colors.redAccent,
        ),
      );
  }

  // Estilo común para los inputs tipo Booking
  InputDecoration _buildInputDecoration({
    required String labelText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: bookingDarkText, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: bookingBlue),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // Bordes rectangulares y oscuros como Booking
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero, // Rectangular
        borderSide: BorderSide(color: Color(0xFFA2A2A2)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFA2A2A2)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: bookingBlue, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
      suffixIcon: suffixIcon,
      // Booking no suele usar iconos prefijos dentro del input en web
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco puro
      // Encabezado Azul estilo Booking
      appBar: AppBar(
        backgroundColor: bookingBlue,
        elevation: 0,
        automaticallyImplyLeading: false, // Quitar flecha atrás si hay
        title: const Text(
          'Booking.com', // O un widget Image con el logo
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Espaciador superior después del AppBar
              const SizedBox(height: 30),
              // Contenedor centrado para el formulario
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título principal
                          const Text(
                            'Inicia sesión o crea una cuenta',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: bookingDarkText,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Campo Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: bookingDarkText),
                            decoration: _buildInputDecoration(
                              labelText: 'Correo electrónico',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa tu correo electrónico';
                              }
                              if (!value.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: bookingDarkText),
                            decoration: _buildInputDecoration(
                              labelText: 'Contraseña',
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: bookingBlue,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          // Botón Principal Amarillo Booking
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bookingYellow,
                              foregroundColor: bookingBlue, // Texto azul oscuro
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ), // Ligeramente redondeado
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        bookingBlue,
                                      ),
                                    ),
                                  )
                                : const Text('Iniciar sesión'),
                          ),
                          const SizedBox(height: 20),

                          // Divisor "o" (opcional, Booking lo usa)
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(color: Color(0xFFE0E0E0)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'o',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Color(0xFFE0E0E0)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Enlace Crear Cuenta (Azul claro)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: bookingLightBlue,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            child: const Text('Crear cuenta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
