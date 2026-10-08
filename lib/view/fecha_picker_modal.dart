import 'package:flutter/material.dart';

const Color _azulOscuro = Color(0xFF003B95);
const Color _azul = Color(0xFF0071C2);
const Color _banda = Color(0xFFE3F0FF);

Future<DateTimeRange?> mostrarSelectorFechas(
  BuildContext context, {
  DateTimeRange? rangoInicial,
}) {
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FechaPickerModal(rangoInicial: rangoInicial),
  );
}

class FechaPickerModal extends StatefulWidget {
  const FechaPickerModal({super.key, this.rangoInicial});

  final DateTimeRange? rangoInicial;

  @override
  State<FechaPickerModal> createState() => _FechaPickerModalState();
}

class _FechaPickerModalState extends State<FechaPickerModal> {
  static const List<String> _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static const List<String> _diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  static DateTime _solo(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _formatear(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  late DateTime? _inicio;
  late DateTime? _fin;
  late DateTime _mesVisible;

  final DateTime _hoy = _solo(DateTime.now());
  late final DateTime _limite = _hoy.add(const Duration(days: 365));

  int get _noches => (_fin == null || _inicio == null) ? 0 : _fin!.difference(_inicio!).inDays;

  @override
  void initState() {
    super.initState();
    _inicio = widget.rangoInicial == null ? null : _solo(widget.rangoInicial!.start);
    _fin = widget.rangoInicial == null ? null : _solo(widget.rangoInicial!.end);
    final base = _inicio ?? _hoy;
    _mesVisible = DateTime(base.year, base.month, 1);
  }

  void _tocarDia(DateTime dia) {
    if (dia.isBefore(_hoy) || dia.isAfter(_limite)) return;
    setState(() {
      if (_inicio == null || _fin != null || !dia.isAfter(_inicio!)) {
        _inicio = dia;
        _fin = null;
      } else {
        _fin = dia;
      }
      if (dia.year != _mesVisible.year || dia.month != _mesVisible.month) {
        _mesVisible = DateTime(dia.year, dia.month, 1);
      }
    });
  }

  void _moverMes(int delta) {
    setState(() {
      _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + delta, 1);
    });
  }

  bool get _puedeConfirmar => _inicio != null && _fin != null;

  List<DateTime> _diasDeLaRejilla() {
    final DateTime primero = DateTime(_mesVisible.year, _mesVisible.month, 1);
    final int diasEnMes = DateTime(_mesVisible.year, _mesVisible.month + 1, 0).day;
    final int huecos = primero.weekday - 1;
    final int totalCeldas = ((huecos + diasEnMes + 6) ~/ 7) * 7;
    final DateTime inicio = primero.subtract(Duration(days: huecos));
    return List<DateTime>.generate(totalCeldas, (i) => inicio.add(Duration(days: i)));
  }

  bool get _puedeRetroceder =>
      _mesVisible.year > _hoy.year || _mesVisible.month > _hoy.month;

  bool get _puedeAvanzar {
    final DateTime max = DateTime(_limite.year, _limite.month, 1);
    return _mesVisible.year < max.year || _mesVisible.month < max.month;
  }

  @override
  Widget build(BuildContext context) {
    final double alturaMax = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: alturaMax),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selecciona tus fechas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _azulOscuro,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _tarjetaFecha('Llegada', _inicio)),
                  const SizedBox(width: 12),
                  Expanded(child: _tarjetaFecha('Salida', _fin)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  IconButton(
                    onPressed: _puedeRetroceder ? () => _moverMes(-1) : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: _azulOscuro,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: const CircleBorder(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_meses[_mesVisible.month - 1]} ${_mesVisible.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _puedeAvanzar ? () => _moverMes(1) : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: _azulOscuro,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final d in _diasSemana)
                    Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              ..._rejilla(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _puedeConfirmar
                          ? '$_noches ${_noches == 1 ? 'noche' : 'noches'}'
                          : 'Elige la fecha de llegada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _puedeConfirmar ? _azulOscuro : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  if (_inicio != null || _fin != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _inicio = null;
                        _fin = null;
                      }),
                      child: const Text('Limpiar', style: TextStyle(color: Colors.grey)),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _puedeConfirmar
                        ? () => Navigator.pop(
                              context,
                              DateTimeRange(start: _inicio!, end: _fin!),
                            )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _azul,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaFecha(String etiqueta, DateTime? fecha) {
    final bool activa = fecha != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: activa ? _banda : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: activa ? _azul : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: activa ? _azul : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            activa ? _formatear(fecha) : '--/--/----',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: activa ? _azulOscuro : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _rejilla() {
    final List<DateTime> dias = _diasDeLaRejilla();
    final List<Widget> filas = [];

    for (int i = 0; i < dias.length; i += 7) {
      final List<DateTime> semana = dias.sublist(i, i + 7);
      filas.add(
        Row(
          children: [for (final dia in semana) Expanded(child: _celda(dia))],
        ),
      );
    }
    return filas;
  }

  Widget _celda(DateTime dia) {
    final bool otroMes = dia.month != _mesVisible.month;
    final bool pasado = dia.isBefore(_hoy);
    final bool fueraDeRango = dia.isAfter(_limite);
    final bool deshabilitado = pasado || fueraDeRango;

    final bool esInicio = _inicio != null && dia == _inicio;
    final bool esFin = _fin != null && dia == _fin;
    final bool enBanda = _inicio != null &&
        _fin != null &&
        !dia.isBefore(_inicio!) &&
        !dia.isAfter(_fin!);

    final bool finDeSemana = dia.weekday >= 6;
    final bool esHoy = dia == _hoy;

    Color colorTexto;
    if (deshabilitado) {
      colorTexto = Colors.black12;
    } else if (esInicio || esFin) {
      colorTexto = Colors.white;
    } else if (otroMes) {
      colorTexto = Colors.grey.shade300;
    } else if (finDeSemana) {
      colorTexto = Colors.grey.shade600;
    } else {
      colorTexto = Colors.black87;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: deshabilitado ? null : () => _tocarDia(dia),
      child: Container(
        height: 46,
        color: enBanda ? _banda : Colors.transparent,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: esInicio || esFin ? _azul : null,
              border: esHoy && !esInicio && !esFin
                  ? Border.all(color: _azul, width: 1.5)
                  : null,
            ),
            child: Text(
              '${dia.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: esInicio || esFin || esHoy ? FontWeight.w700 : FontWeight.w500,
                color: colorTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
