import 'package:flutter/material.dart';

import '../model/hotel.dart';
import '../model/reserva.dart';
import '../model/user.dart';
import 'home.dart';
import 'mis_reservas.dart';

class ReservaConfirmacion extends StatelessWidget {
  const ReservaConfirmacion({
    super.key,
    required this.reserva,
    required this.hotel,
    required this.user,
  });

  final Reserva reserva;
  final Hotel hotel;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva Confirmada'),
        backgroundColor: const Color(0xFF003B95),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  '¡Reserva Exitosa!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Código de reserva: ${reserva.codigo}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hotel: ${hotel.nombre}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('A nombre de: ${user.nombre}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('Fechas: ${reserva.fechaEntrada.day}/${reserva.fechaEntrada.month}/${reserva.fechaEntrada.year} - ${reserva.fechaSalida.day}/${reserva.fechaSalida.month}/${reserva.fechaSalida.year}'),
                        const SizedBox(height: 10),
                        Text('Personas: ${reserva.cantidadPersonas}'),
                        const Divider(),
                        Text(
                          'Total pagado: \$${reserva.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => HomePage(user: user),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Volver al Inicio'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => HomePage(user: user),
                          ),
                          (route) => false,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => MisReservasPage(user: user),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0071C2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ver Mis Reservas'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
