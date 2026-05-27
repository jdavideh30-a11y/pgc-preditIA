import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      final auth = context.read<AuthProvider>();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 80, color: Color(0xFF42A5F5)),
            const SizedBox(height: 24),
            const Text('PredictIA', style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
              letterSpacing: 2,
            )),
            const SizedBox(height: 8),
            Text('Prediccion de partidos con IA',
              style: TextStyle(color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFF42A5F5)),
          ],
        ),
      ),
    );
  }
}
