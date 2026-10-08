import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../model/hotel.dart';
import '../model/reserva.dart';
import '../model/user.dart';
import 'fecha_picker_modal.dart';
import 'reserva_confirmacion.dart';

class ReservaForm extends StatefulWidget {
  const ReservaForm({super.key, required this.hotel, required this.user});

  final Hotel hotel;
  final User user;

  @override
  State<ReservaForm> createState() => _ReservaFormState();
}

class _ReservaFormState extends State<ReservaForm> {
  DateTime? _fechaEntrada;
  DateTime? _fechaSalida;
  int _cantidadPersonas = 1;
  final _notasController = TextEditingController();

  int get _dias {
    if (_fechaEntrada == null || _fechaSalida == null) return 0;
    final dif = _fechaSalida!.difference(_fechaEntrada!).inDays;
    return dif > 0 ? dif : 1;
  }

  double get _total => _dias * widget.hotel.precioNoche;

  Future<void> _selectDates() async {
    final rango = await mostrarSelectorFechas(
      context,
      rangoInicial: (_fechaEntrada != null && _fechaSalida != null)
          ? DateTimeRange(start: _fechaEntrada!, end: _fechaSalida!)
          : null,
    );
    if (rango != null) {
      setState(() {
        _fechaEntrada = rango.start;
        _fechaSalida = rango.end;
      });
    }
  }

  String _formatear(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  Future<void> _crearReserva() async {
    if (_fechaEntrada == null || _fechaSalida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona las fechas de reserva.')),
      );
      return;
    }

    final reserva = Reserva(
      usuarioId: widget.user.id!,
      hotelId: widget.hotel.id,
      fechaEntrada: _fechaEntrada!,
      fechaSalida: _fechaSalida!,
      cantidadPersonas: _cantidadPersonas,
      notas: _notasController.text,
      codigo: const Uuid().v4().substring(0, 8).toUpperCase(),
      total: _total,
    );

    await DatabaseHelper.instance.addReservation(reserva);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReservaConfirmacion(
            reserva: reserva,
            hotel: widget.hotel,
            user: widget.user,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar'),
        backgroundColor: const Color(0xFF003B95),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hotel: ${widget.hotel.nombre}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003B95)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'A nombre de: ${widget.user.nombre}',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fechas de reserva:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _selectDates,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _fechaEntrada == null
                                      ? 'Seleccionar fechas'
                                      : '${_formatear(_fechaEntrada!)}  →  ${_formatear(_fechaSalida!)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Icon(Icons.calendar_month, color: Color(0xFF0071C2)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Cantidad de personas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_cantidadPersonas > 1) {
                                  setState(() => _cantidadPersonas--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0071C2)),
                            ),
                            Text('$_cantidadPersonas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => setState(() => _cantidadPersonas++),
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0071C2)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Información adicional:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notasController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            hintText: 'Solicitudes especiales, hora de llegada, etc.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  color: const Color(0xFFE8F4FF),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumen de pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF003B95))),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Precio por noche:'),
                            Text('\$${widget.hotel.precioNoche.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total de noches:'),
                            Text('$_dias'),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total a pagar:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              '\$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0071C2)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _crearReserva,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0071C2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirmar Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
