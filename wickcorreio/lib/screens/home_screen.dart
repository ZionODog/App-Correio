import 'package:flutter/material.dart';
import '../main.dart';
import 'package:wickcorreio/screens/add_malote_screen.dart';
import 'package:wickcorreio/screens/login_screen.dart';
import 'package:wickcorreio/screens/update_malote_screen.dart';
import 'package:wickcorreio/screens/verify_malotes_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userLocation;
  final String userRe;
  const HomeScreen({
    super.key,
    required this.userLocation,
    required this.userRe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WickCorreio'),
        backgroundColor: wickRed,
        foregroundColor: wickWhite,
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Logo
            Image.asset('assets/images/wickbold_logo.png', height: 60),
            const SizedBox(height: 40),

            // Grid com os botões
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Duas colunas
                crossAxisSpacing: 20, // Espaço horizontal
                mainAxisSpacing: 20, // Espaço vertical
                childAspectRatio:
                    1.0, // Deixa os botões perfeitamente quadrados
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.add_box_outlined,
                    label: 'Adicionar Malote',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMaloteScreen(
                            userLocation: userLocation,
                            userRe: userRe,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.qr_code_scanner_outlined,
                    label: 'Atualizar Malote',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateMaloteScreen(
                            userRe: userRe,
                            userLocation: userLocation,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.search_outlined,
                    label: 'Verificar Malote',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerifyMalotesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar os botões quadrados e evitar repetição de código
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: wickGold), // Ícone Dourado
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
