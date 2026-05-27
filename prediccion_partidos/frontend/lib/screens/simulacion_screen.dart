import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SimulacionScreen extends StatefulWidget {
  final Map<String, dynamic> prediccion;
  final Map<String, dynamic> evento;
  const SimulacionScreen({super.key, required this.prediccion, required this.evento});
  @override
  State<SimulacionScreen> createState() => _SimulacionScreenState();
}

class _SimulacionScreenState extends State<SimulacionScreen> {
  final _montoCtrl = TextEditingController(text: '10000');
  String _seleccion = 'local';
  Map<String, dynamic>? _resultado;
  bool _loading = false;

  Future<void> _simular() async {
    setState(() => _loading = true);
    final res = await ApiService.simularApuesta(
      widget.prediccion['id'] as int,
      double.tryParse(_montoCtrl.text) ?? 10000,
      _seleccion,
    );
    setState(() { _resultado = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Simulacion de Apuesta', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.4))),
              child: const Row(children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Simulacion virtual. No involucra dinero real.',
                    style: TextStyle(color: Colors.orange, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Selecciona resultado:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            ...['local', 'empate', 'visitante'].map((op) => RadioListTile<String>(
              value: op,
              groupValue: _seleccion,
              title: Text(op[0].toUpperCase() + op.substring(1),
                  style: const TextStyle(color: Colors.white)),
              activeColor: const Color(0xFF42A5F5),
              onChanged: (v) => setState(() => _seleccion = v!),
            )),
            const SizedBox(height: 16),
            TextField(
              controller: _montoCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Monto virtual (COP)',
                labelStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF42A5F5)),
                filled: true, fillColor: const Color(0xFF1A2E40),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _simular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Calcular simulacion', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            if (_resultado != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.4)),
                ),
                child: Column(children: [
                  const Text('Ganancia Estimada', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  Text('\$${_resultado!['ganancia_estimada']}',
                      style: const TextStyle(color: Colors.greenAccent,
                          fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Cuota: ${_resultado!['cuota']}x',
                      style: const TextStyle(color: Colors.white70)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
