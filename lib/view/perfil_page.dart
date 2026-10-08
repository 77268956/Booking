import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/reserva.dart';
import '../model/user.dart';
import 'login_page.dart';
import 'mis_reservas.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, required this.user});

  final User user;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const Color _azulOscuro = Color(0xFF003B95);
  static const Color _azul = Color(0xFF0071C2);

  late User _user;
  late Future<List<Reserva>> _reservasFuture;

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passActualController = TextEditingController();
  final _passNuevaController = TextEditingController();
  final _passRepetirController = TextEditingController();

  bool _guardandoDatos = false;
  bool _guardandoPassword = false;
  bool _mostrarPassword = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nombreController.text = _user.nombre;
    _emailController.text = _user.email;
    _reservasFuture = _user.id == null
        ? Future<List<Reserva>>.value(const [])
        : DatabaseHelper.instance.getReservationsForUser(_user.id!);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passActualController.dispose();
    _passNuevaController.dispose();
    _passRepetirController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: error ? Colors.redAccent : null,
        ),
      );
  }

  Future<void> _guardarDatos() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final emailValido = RegExp(r'^[\w.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email);

    if (nombre.isEmpty) {
      _mostrarMensaje('El nombre no puede estar vacío.', error: true);
      return;
    }
    if (!emailValido) {
      _mostrarMensaje('Introduce un correo electrónico válido.', error: true);
      return;
    }

    setState(() => _guardandoDatos = true);
    final actualizado = User(
      id: _user.id,
      nombre: nombre,
      email: email,
      password: _user.password,
    );
    final ok = await DatabaseHelper.instance.updateUser(actualizado);
    if (!mounted) return;
    setState(() => _guardandoDatos = false);

    if (!ok) {
      _mostrarMensaje('El correo electrónico ya está en uso.', error: true);
      return;
    }
    setState(() => _user = actualizado);
    _mostrarMensaje('Datos actualizados correctamente.');
  }

  Future<void> _guardarPassword() async {
    final actual = _passActualController.text;
    final nueva = _passNuevaController.text;
    final repetir = _passRepetirController.text;

    if (actual != _user.password) {
      _mostrarMensaje('La contraseña actual no es correcta.', error: true);
      return;
    }
    if (nueva.length < 6) {
      _mostrarMensaje('La nueva contraseña debe tener mínimo 6 caracteres.', error: true);
      return;
    }
    if (nueva != repetir) {
      _mostrarMensaje('Las contraseñas no coinciden.', error: true);
      return;
    }

    setState(() => _guardandoPassword = true);
    final actualizado = User(
      id: _user.id,
      nombre: _user.nombre,
      email: _user.email,
      password: nueva,
    );
    final ok = await DatabaseHelper.instance.updateUser(actualizado);
    if (!mounted) return;
    setState(() => _guardandoPassword = false);

    if (!ok) {
      _mostrarMensaje('No se pudo actualizar la contraseña.', error: true);
      return;
    }
    setState(() => _user = actualizado);
    _passActualController.clear();
    _passNuevaController.clear();
    _passRepetirController.clear();
    _mostrarMensaje('Contraseña actualizada correctamente.');
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (ruta) => false,
    );
  }

  String _formatearMonto(double valor) => '\$${valor.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (pudoPoblar, resultado) {
        if (!pudoPoblar) Navigator.pop(context, _user);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Mi perfil'),
          backgroundColor: _azulOscuro,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _user),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _cabecera(),
                const SizedBox(height: 16),
                _estadisticas(),
                const SizedBox(height: 16),
                _tarjetaDatos(),
                const SizedBox(height: 16),
                _tarjetaPassword(),
                const SizedBox(height: 16),
                _acciones(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecera() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: _azulOscuro,
              child: Text(
                _user.nombre.isNotEmpty ? _user.nombre[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user.email,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadisticas() {
    return FutureBuilder<List<Reserva>>(
      future: _reservasFuture,
      builder: (context, snapshot) {
        final reservas = snapshot.data ?? [];
        final noches = reservas.fold<int>(
          0,
          (total, r) =>
              total + (r.fechaSalida.difference(r.fechaEntrada).inDays),
        );
        final gastado = reservas.fold<double>(0, (total, r) => total + r.total);

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                _dato('Reservas', '${reservas.length}', Icons.bookmark_border),
                _divisor(),
                _dato('Noches', '$noches', Icons.nightlight_outlined),
                _divisor(),
                _dato('Gastado', _formatearMonto(gastado), Icons.payments_outlined),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _divisor() => Container(width: 1, height: 46, color: Colors.grey.shade200);

  Widget _dato(String etiqueta, String valor, IconData icono) {
    return Expanded(
      child: Column(
        children: [
          Icon(icono, color: _azul, size: 26),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaDatos() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _azulOscuro),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _guardandoDatos ? null : _guardarDatos,
                style: FilledButton.styleFrom(
                  backgroundColor: _azul,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _guardandoDatos
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaPassword() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar contraseña',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _azulOscuro),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passActualController,
              obscureText: !_mostrarPassword,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passNuevaController,
              obscureText: !_mostrarPassword,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_reset),
                helperText: 'Mínimo 6 caracteres',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passRepetirController,
              obscureText: !_mostrarPassword,
              decoration: const InputDecoration(
                labelText: 'Repetir nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _mostrarPassword,
                  onChanged: (valor) => setState(() => _mostrarPassword = valor ?? false),
                ),
                const Text('Mostrar contraseña'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _guardandoPassword ? null : _guardarPassword,
                style: FilledButton.styleFrom(
                  backgroundColor: _azulOscuro,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _guardandoPassword
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Actualizar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acciones() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_border, color: _azul),
            title: const Text('Mis Reservas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => MisReservasPage(user: _user),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            onTap: _cerrarSesion,
          ),
        ],
      ),
    );
  }
}
