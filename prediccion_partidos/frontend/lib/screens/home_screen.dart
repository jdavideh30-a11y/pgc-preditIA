import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'eventos_screen.dart';
import 'historial_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final _pages = const [
    EventosScreen(),
    HistorialScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Row(children: [
          const Icon(Icons.sports_soccer, color: Color(0xFF42A5F5)),
          const SizedBox(width: 8),
          const Text('PredictIA',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          Text(auth.username ?? '',
              style: const TextStyle(color: Colors.white54)),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A2E40),
        selectedItemColor: const Color(0xFF42A5F5),
        unselectedItemColor: Colors.white38,
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Eventos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy), label: 'Asistente IA'),
        ],
      ),
    );
  }
}