import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../main.dart';

class MaloteDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> maloteData;

  const MaloteDetailsScreen({super.key, required this.maloteData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malote #${maloteData['id']} Criado'),
        backgroundColor: wickRed,
        foregroundColor: wickWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Malote Gerado com Sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: wickGold,
              ),
            ),
            const SizedBox(height: 30),

            // Exibição do QR Code
            Center(
              child: QrImageView(
                data: maloteData['qr_hash'], // O hash gerado pelo backend
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 20),

            _buildDetailRow('ID do Malote:', '#${maloteData['id']}'),
            _buildDetailRow('Cód. Rastreio:', '${maloteData['barcode']}'),
            _buildDetailRow('Nome:', maloteData['nome']),
            _buildDetailRow('Origem:', maloteData['origem']),
            _buildDetailRow('Para:', maloteData['destinatario']),
            _buildDetailRow('Destino:', maloteData['destino']),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                print('Imprimir etiqueta...');
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('Imprimir Etiqueta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
