import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eventos_provider.dart';
import '../services/api_service.dart';
 
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});
  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}
 
class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventosProvider>().cargarHistorial();
    });
  }
 
  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return '';
    try {
      final fecha = DateTime.parse(fechaStr).toLocal();
      final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                     'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
    } catch (_) {
      return '';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EventosProvider>();
 
    // Calcular estadísticas
    final total = prov.historial.length;
    final acertados = prov.historial.where((p) => p['acerto'] == true).length;
    final fallados = prov.historial.where((p) => p['acerto'] == false).length;
    final pendientes = prov.historial.where((p) => p['acerto'] == null).length;
 
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
                  'Modo demo — las predicciones se guardan localmente',
                  style: TextStyle(color: Color(0xFF42A5F5), fontSize: 12),
                ),
              ),
            ]),
          ),
 
        // Estadísticas rápidas
        if (total > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2E40),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statChip('Total', total.toString(), const Color(0xFF42A5F5)),
                _divider(),
                _statChip('Aciertos', acertados.toString(), Colors.greenAccent),
                _divider(),
                _statChip('Fallos', fallados.toString(), Colors.redAccent),
                _divider(),
                _statChip('Pendientes', pendientes.toString(), Colors.white38),
              ],
            ),
          ),
 
        // Lista
        Expanded(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF42A5F5)))
              : prov.historial.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.history, color: Colors.white24, size: 64),
                          SizedBox(height: 16),
                          Text('Sin predicciones todavía',
                              style: TextStyle(color: Colors.white54, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Ve a Eventos y predice un partido',
                              style: TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF42A5F5),
                      onRefresh: () => prov.cargarHistorial(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: prov.historial.length,
                        itemBuilder: (ctx, i) {
                          final p = prov.historial[i];
                          final ev = p['evento_detalle'] as Map<String, dynamic>?;
                          final acerto = p['acerto'];
                          final confianza = ((p['confianza'] as num?) ?? 0) * 100;
                          final resultado = p['resultado_predicho'] as String? ?? '';
                          final fecha = _formatearFecha(p['created_at'] as String?);
                          final liga = ev?['liga'] as String? ?? '';
 
                          Color colorAcerto;
                          IconData iconoAcerto;
                          String labelAcerto;
                          if (acerto == true) {
                            colorAcerto = Colors.greenAccent;
                            iconoAcerto = Icons.check_circle;
                            labelAcerto = 'Acertó';
                          } else if (acerto == false) {
                            colorAcerto = Colors.redAccent;
                            iconoAcerto = Icons.cancel;
                            labelAcerto = 'Falló';
                          } else {
                            colorAcerto = Colors.white38;
                            iconoAcerto = Icons.hourglass_empty;
                            labelAcerto = 'Pendiente';
                          }
 
                          return Card(
                            color: const Color(0xFF1A2E40),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: colorAcerto.withOpacity(0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icono resultado
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorAcerto.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(iconoAcerto,
                                        color: colorAcerto, size: 22),
                                  ),
                                  const SizedBox(width: 12),
 
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Liga
                                        if (liga.isNotEmpty)
                                          Text(liga,
                                              style: const TextStyle(
                                                  color: Colors.white38, fontSize: 11)),
                                        // Equipos
                                        Text(
                                          ev != null
                                              ? '${ev['equipo_local']} vs ${ev['equipo_visitante']}'
                                              : 'Evento #${p['evento']}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        // Predicción + confianza
                                        Row(children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1565C0).withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              resultado[0].toUpperCase() + resultado.substring(1),
                                              style: const TextStyle(
                                                  color: Color(0xFF42A5F5),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${confianza.toStringAsFixed(0)}% confianza',
                                            style: const TextStyle(
                                                color: Colors.white54, fontSize: 12),
                                          ),
                                        ]),
                                        if (fecha.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(fecha,
                                              style: const TextStyle(
                                                  color: Colors.white24, fontSize: 11)),
                                        ],
                                      ],
                                    ),
                                  ),
 
                                  // Etiqueta acierto
                                  Text(labelAcerto,
                                      style: TextStyle(
                                          color: colorAcerto,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
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
 
  Widget _statChip(String label, String valor, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(valor,
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
 
  Widget _divider() => Container(width: 1, height: 32, color: Colors.white12);
}
 