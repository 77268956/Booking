import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/hotel.dart';
import '../model/user.dart';
import 'hotel_detail.dart';
import 'mis_reservas.dart';
import 'perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  late Future<List<Hotel>> _hotelsFuture;
  late User _user;
  Timer? _debounce;
  String _query = '';

  static const List<String> _destinos = ['Cancún', 'Madrid', 'Nueva York'];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _hotelsFuture = DatabaseHelper.instance.getHotels();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _buscar(String texto) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _query = texto.trim();
        _hotelsFuture = DatabaseHelper.instance.getHotels(search: _query);
      });
    });
  }

  void _alEscribir(String texto) {
    setState(() {});
    _buscar(texto);
  }

  void _buscarInmediato(String texto) {
    _debounce?.cancel();
    setState(() {
      _query = texto.trim();
      _hotelsFuture = DatabaseHelper.instance.getHotels(search: _query);
    });
  }

  void _limpiarBusqueda() {
    _debounce?.cancel();
    _searchController.clear();
    _buscarInmediato('');
  }

  Future<void> _abrirPerfil() async {
    final actualizado = await Navigator.push<User>(
      context,
      MaterialPageRoute<User>(builder: (_) => PerfilPage(user: _user)),
    );
    if (actualizado != null && mounted) {
      setState(() => _user = actualizado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(child: _buildHotels()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF003B95),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    'Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (MediaQuery.sizeOf(context).width > 560) ...[
                    const Icon(Icons.language, color: Colors.white, size: 19),
                    const SizedBox(width: 5),
                    const Text('EUR', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 20),
                  ],
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => MisReservasPage(user: _user),
                        ),
                      );
                    },
                    child: const Text(
                      'Mis Reservas',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _abrirPerfil,
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_circle_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _user.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      color: const Color(0xFF003B95),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${_user.nombre}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Encuentra tu próxima estancia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEBB02),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 620;
                      final search = Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _alEscribir,
                          onSubmitted: _buscarInmediato,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(Icons.search),
                            hintText: 'Ciudad, hotel o destino',
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Limpiar',
                                    icon: const Icon(Icons.close),
                                    onPressed: _limpiarBusqueda,
                                  ),
                          ),
                        ),
                      );
                      final button = SizedBox(
                        height: 56,
                        width: compact ? double.infinity : 120,
                        child: ElevatedButton(
                          onPressed: () => _buscarInmediato(_searchController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0071C2),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Buscar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                      return compact
                          ? Column(
                              children: [
                                search,
                                const SizedBox(height: 4),
                                button,
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: search),
                                const SizedBox(width: 4),
                                button,
                              ],
                            );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final destino in _destinos)
                      ActionChip(
                        avatar: const Icon(Icons.location_on, size: 16, color: Colors.white),
                        label: Text(
                          destino,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        backgroundColor: _query == destino
                            ? const Color(0xFFFEBB02)
                            : Colors.white.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: _query == destino
                              ? const Color(0xFFFEBB02)
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                        labelStyle: TextStyle(
                          color: _query == destino ? const Color(0xFF003B95) : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          _searchController.text = destino;
                          _buscarInmediato(destino);
                        },
                      ),
                    if (_query.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.close, size: 16, color: Colors.white),
                        label: const Text(
                          'Limpiar búsqueda',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: _limpiarBusqueda,
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

  Widget _buildHotels() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _query.isEmpty
                          ? 'Hoteles recomendados'
                          : 'Resultados para "$_query"',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    TextButton.icon(
                      onPressed: _limpiarBusqueda,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Limpiar búsqueda'),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _query.isEmpty
                    ? 'Elige tu próxima estancia y consulta todos sus detalles.'
                    : 'Buscando por ciudad, hotel, descripción o servicios.',
                style: const TextStyle(color: Color(0xFF595959)),
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Hotel>>(
                future: _hotelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Text('No fue posible cargar los hoteles.');
                  }
                  final hotels = snapshot.data ?? [];
                  if (hotels.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _query.isEmpty
                                ? 'No hay hoteles disponibles.'
                                : 'No encontramos hoteles para "$_query".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF595959)),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _limpiarBusqueda,
                            icon: const Icon(Icons.close),
                            label: const Text('Limpiar búsqueda'),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0071C2)),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_query.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${hotels.length} ${hotels.length == 1 ? 'hotel encontrado' : 'hoteles encontrados'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0071C2),
                            ),
                          ),
                        ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth > 820
                              ? 3
                              : constraints.maxWidth > 540
                              ? 2
                              : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: hotels.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: columns == 1 ? 1.55 : .82,
                            ),
                            itemBuilder: (context, index) => _HotelCard(
                              hotel: hotels[index],
                              user: _user,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel, required this.user});

  final Hotel hotel;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  hotel.imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: Color(0xFFB8CBE4),
                        child: Icon(Icons.hotel, color: Colors.white, size: 50),
                      ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFFB400),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          hotel.calificacion.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF003B95),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF595959),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        hotel.ubicacion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF595959),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF262626)),
                          children: [
                            const TextSpan(
                              text: 'Desde ',
                              style: TextStyle(fontSize: 12),
                            ),
                            TextSpan(
                              text: '\$${hotel.precioNoche.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ' / noche',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => HotelDetail(
                            hotel: hotel,
                            user: user,
                          ),
                        ),
                      ),
                      child: const Text('Ver hotel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
