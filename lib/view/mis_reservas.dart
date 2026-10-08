import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/hotel.dart';
import '../model/reserva.dart';
import '../model/user.dart';

class MisReservasPage extends StatefulWidget {
  const MisReservasPage({super.key, required this.user});

  final User user;

  @override
  State<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  late Future<List<Map<String, dynamic>>> _reservasFuture;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  void _cargarReservas() {
    _reservasFuture = _obtenerDatosReservas();
  }

  String _formatear(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  Future<List<Map<String, dynamic>>> _obtenerDatosReservas() async {
    final reservas = await DatabaseHelper.instance.getReservationsForUser(widget.user.id!);
    final hoteles = await DatabaseHelper.instance.getHotels();
    final hotelesMap = {for (var h in hoteles) h.id: h};

    return reservas.map((r) => {
      'reserva': r,
      'hotel': hotelesMap[r.hotelId],
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: const Color(0xFF003B95),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reservasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorReservas(
              error: snapshot.error,
              onReintentar: () => setState(_cargarReservas),
            );
          }

          final datos = snapshot.data ?? [];
          if (datos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hotel_class_outlined, size: 70, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Aún no tienes reservas.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(_cargarReservas),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(_cargarReservas);
                  await _reservasFuture;
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(15),
                  itemCount: datos.length,
                itemBuilder: (context, index) {
                  final reserva = datos[index]['reserva'] as Reserva;
                  final hotel = datos[index]['hotel'] as Hotel?;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  hotel?.nombre ?? 'Hotel Desconocido',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003B95)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  reserva.estado.toUpperCase(),
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Código: ${reserva.codigo}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text('Fechas: ${_formatear(reserva.fechaEntrada)} al ${_formatear(reserva.fechaSalida)}'),
                          const SizedBox(height: 5),
                          Text('Huéspedes: ${reserva.cantidadPersonas}'),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Pagado:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '\$${reserva.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0071C2)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorReservas extends StatelessWidget {
  const _ErrorReservas({required this.error, required this.onReintentar});

  final Object? error;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Error al cargar las reservas.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onReintentar,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0071C2)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
