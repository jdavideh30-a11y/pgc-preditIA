import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eventos_provider.dart';
import 'simulacion_screen.dart';

class PrediccionScreen extends StatefulWidget {
  final int eventoId;
  final Map<String, dynamic> evento;
  const PrediccionScreen({super.key, required this.eventoId, required this.evento});
  @override
  State<PrediccionScreen> createState() => _PrediccionScreenState();
}

class _PrediccionScreenState extends State<PrediccionScreen> {
  Map<String, dynamic>? _prediccion;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _predecir();
  }

  Future<void> _predecir() async {
    setState(() => _loading = true);
    final data = await context.read<EventosProvider>().predecir(widget.eventoId);
    setState(() { _prediccion = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(backgroundColor: const Color(0xFF0D1B2A),
          title: const Text('Prediccion IA', style: TextStyle(color: Colors.white))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF42A5F5)))
          : _prediccion == null
              ? const Center(child: Text('Error al generar prediccion',
                  style: TextStyle(color: Colors.redAccent)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titulo('${widget.evento['equipo_local']} vs ${widget.evento['equipo_visitante']}'),
                      const SizedBox(height: 24),
                      _resultadoCard(),
                      const SizedBox(height: 20),
                      _probBar('Local (${widget.evento['equipo_local']})',
                          _prediccion!['probabilidad_local']),
                      _probBar('Empate', _prediccion!['probabilidad_empate']),
                      _probBar('Visitante (${widget.evento['equipo_visitante']})',
                          _prediccion!['probabilidad_visitante']),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => SimulacionScreen(
                                  prediccion: _prediccion!, evento: widget.evento))),
                          icon: const Icon(Icons.casino_outlined, color: Colors.white),
                          label: const Text('Simular Apuesta', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _titulo(String text) => Text(text,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));

  Widget _resultadoCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1565C0).withOpacity(0.3),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.5)),
    ),
    child: Column(
      children: [
        const Text('Resultado Predicho', style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 8),
        Text((_prediccion!['resultado_predicho'] as String).toUpperCase(),
            style: const TextStyle(color: Color(0xFF42A5F5), fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text('Confianza: ${((_prediccion!['confianza'] as num) * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );

  Widget _probBar(String label, dynamic valor) {
    final pct = ((valor as num) * 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF42A5F5))),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct / 100,
          backgroundColor: const Color(0xFF1A2E40),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ]),
    );
  }
}
