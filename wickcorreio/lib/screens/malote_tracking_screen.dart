import 'package:flutter/material.dart';
import 'package:wickcorreio/services/api_service.dart';
import '../main.dart';

class MaloteTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> malote;

  const MaloteTrackingScreen({super.key, required this.malote});

  @override
  State<MaloteTrackingScreen> createState() => _MaloteTrackingScreenState();
}

class _MaloteTrackingScreenState extends State<MaloteTrackingScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _historicoFuture;

  // Mapa para associar status a ícones
  final Map<String, IconData> statusIcons = {
    'Criado na Origem': Icons.inventory_2_outlined,
    'Em trânsito para Centro de Distribuição': Icons.local_shipping_outlined,
    'Recebido no Centro de Distribuição': Icons.warehouse_outlined,
    'Em trânsito para o destino final': Icons.route_outlined,
    'Entregue': Icons.task_alt_outlined,
  };

  @override
  void initState() {
    super.initState();
    _historicoFuture = _apiService.getMaloteHistorico(widget.malote['barcode']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rastreio: ${widget.malote['barcode']}'),
        backgroundColor: wickRed,
        foregroundColor: wickWhite,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historicoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum histórico de rastreio encontrado.'),
            );
          }

          final historico = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historico.length,
            itemBuilder: (context, index) {
              final evento = historico[index];
              final status = evento['status'];
              final icon = statusIcons[status] ?? Icons.help_outline;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: wickGold,
                          foregroundColor: wickWhite,
                          child: Icon(icon),
                        ),
                        if (index < historico.length - 1)
                          Container(
                            height: 60,
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Local: ${evento['localizacao']}'),
                          const SizedBox(height: 4),
                          Text(
                            evento['timestamp'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
