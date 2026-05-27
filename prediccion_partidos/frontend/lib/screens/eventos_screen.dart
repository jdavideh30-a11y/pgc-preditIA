import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eventos_provider.dart';
import '../services/api_service.dart';
import 'prediccion_screen.dart';
 
class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});
  @override
  State<EventosScreen> createState() => _EventosScreenState();
}
 
class _EventosScreenState extends State<EventosScreen> {
  String _filtroDeporte = 'todos';
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventosProvider>().cargarEventos();
    });
  }
 
  void _aplicarFiltro(String deporte) {
    setState(() => _filtroDeporte = deporte);
    final prov = context.read<EventosProvider>();
    prov.cargarEventos(deporte: deporte == 'todos' ? null : deporte);
  }
 
  Color _colorEstado(String estado) {
    switch (estado) {
      case 'en_vivo':
        return Colors.redAccent;
      case 'finalizado':
        return Colors.grey;
      default:
        return const Color(0xFF42A5F5);
    }
  }
 
  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'en_vivo':
        return Icons.fiber_manual_record;
      case 'finalizado':
        return Icons.check_circle_outline;
      default:
        return Icons.schedule;
    }
  }
 
  String _labelEstado(String estado) {
    switch (estado) {
      case 'en_vivo':
        return 'EN VIVO';
      case 'finalizado':
        return 'Finalizado';
      default:
        return 'Próximo';
    }
  }
 
  IconData _iconoDeporte(String deporte) {
    switch (deporte) {
      case 'baloncesto':
        return Icons.sports_basketball;
      case 'tenis':
        return Icons.sports_tennis;
      default:
        return Icons.sports_soccer;
    }
  }
 
  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return '';
    try {
      final fecha = DateTime.parse(fechaStr).toLocal();
      final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      final dia = dias[fecha.weekday - 1];
      final mes = meses[fecha.month - 1];
      final hora = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
      return '$dia ${fecha.day} $mes • $hora';
    } catch (_) {
      return '';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EventosProvider>();
 
    return Column(
      children: [
        // Banner demo
        if (ApiService.esModoDemo)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1565C0).withOpacity(0.25),
            child: Row(children: const [
              Icon(Icons.info_outline, color: Color(0xFF42A5F5), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Modo demo — partidos de ejemplo (backend no disponible)',
                  style: TextStyle(color: Color(0xFF42A5F5), fontSize: 12),
                ),
              ),
            ]),
          ),
 
        // Filtros por deporte
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['todos', 'futbol', 'baloncesto', 'tenis'].map((d) {
                final activo = _filtroDeporte == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d == 'todos' ? 'Todos' : d[0].toUpperCase() + d.substring(1)),
                    selected: activo,
                    onSelected: (_) => _aplicarFiltro(d),
                    selectedColor: const Color(0xFF1565C0),
                    backgroundColor: const Color(0xFF1A2E40),
                    labelStyle: TextStyle(
                      color: activo ? Colors.white : Colors.white54,
                      fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: activo ? const Color(0xFF42A5F5) : Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
 
        // Lista de eventos
        Expanded(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF42A5F5)))
              : prov.eventos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sports_soccer, color: Colors.white24, size: 64),
                          const SizedBox(height: 16),
                          const Text('No hay eventos disponibles',
                              style: TextStyle(color: Colors.white54, fontSize: 16)),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _aplicarFiltro('todos'),
                            icon: const Icon(Icons.refresh, color: Color(0xFF42A5F5)),
                            label: const Text('Recargar',
                                style: TextStyle(color: Color(0xFF42A5F5))),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF42A5F5),
                      onRefresh: () => prov.cargarEventos(
                          deporte: _filtroDeporte == 'todos' ? null : _filtroDeporte),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: prov.eventos.length,
                        itemBuilder: (ctx, i) {
                          final e = prov.eventos[i];
                          final estado = e['estado'] as String? ?? 'pendiente';
                          final deporte = e['deporte'] as String? ?? 'futbol';
                          final liga = e['liga'] as String? ?? '';
                          final fecha = _formatearFecha(e['fecha'] as String?);
 
                          return Card(
                            color: const Color(0xFF1A2E40),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: estado == 'en_vivo'
                                  ? const BorderSide(color: Colors.redAccent, width: 1.2)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Liga + estado + deporte
                                  Row(
                                    children: [
                                      Icon(_iconoDeporte(deporte),
                                          color: Colors.white38, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(liga,
                                            style: const TextStyle(
                                                color: Colors.white38, fontSize: 12)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _colorEstado(estado).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                              color: _colorEstado(estado).withOpacity(0.6),
                                              width: 0.8),
                                        ),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(_iconoEstado(estado),
                                              color: _colorEstado(estado), size: 10),
                                          const SizedBox(width: 4),
                                          Text(_labelEstado(estado),
                                              style: TextStyle(
                                                  color: _colorEstado(estado),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                      ),
                                    ],
                                  ),
 
                                  const SizedBox(height: 14),
 
                                  // Equipos enfrentados
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          e['equipo_local'] as String? ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D1B2A),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('VS',
                                            style: TextStyle(
                                                color: Color(0xFF42A5F5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                      ),
                                      Expanded(
                                        child: Text(
                                          e['equipo_visitante'] as String? ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
 
                                  const SizedBox(height: 14),
 
                                  // Fecha + botón predecir
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Colors.white38, size: 13),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(fecha,
                                            style: const TextStyle(
                                                color: Colors.white38, fontSize: 12)),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: estado == 'finalizado'
                                            ? null
                                            : () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => PrediccionScreen(
                                                        eventoId: e['id'] as int,
                                                        evento: e))),
                                        icon: const Icon(Icons.auto_graph,
                                            size: 16, color: Colors.white),
                                        label: Text(
                                          estado == 'finalizado'
                                              ? 'Finalizado'
                                              : 'Predecir',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 13),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: estado == 'finalizado'
                                              ? Colors.grey.shade800
                                              : const Color(0xFF1565C0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                          elevation: 0,
                                        ),
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
      ],
    );
  }
}
 