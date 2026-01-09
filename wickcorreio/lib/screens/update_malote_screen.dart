import 'package:flutter/material.dart';
import 'package:wickcorreio/services/api_service.dart';
import '../main.dart';

class UpdateMaloteScreen extends StatefulWidget {
  final String userRe;
  final String userLocation;

  const UpdateMaloteScreen({
    super.key,
    required this.userRe,
    required this.userLocation,
  });

  @override
  State<UpdateMaloteScreen> createState() => _UpdateMaloteScreenState();
}

class _UpdateMaloteScreenState extends State<UpdateMaloteScreen> {
  final _apiService = ApiService();
  final _codigoController = TextEditingController();
  bool _isLoading = false;

  void _handleUpdate() async {
    final codigo = _codigoController.text
        .trim(); // .trim() remove espaços em branco
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o código de rastreio do malote.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.atualizarMalote(
      codigo,
      widget.userRe,
      widget.userLocation,
    );

    setState(() => _isLoading = false);

    _codigoController.clear(); // Limpa o campo após a tentativa

    // Mostra um diálogo com o resultado para o usuário
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result['success'] ? 'Sucesso!' : 'Atenção'),
          content: Text(
            result['success'] ? result['data']['message'] : result['message'],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Status do Malote'),
        backgroundColor: wickRed,
        foregroundColor: wickWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.track_changes, size: 80, color: wickGold),
            const SizedBox(height: 20),
            const Text(
              'Digite o código de rastreio da etiqueta para registrar a movimentação do malote.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código de Rastreio (Ex: WK000001)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_2),
              ),
              onSubmitted: (_) =>
                  _handleUpdate(), // Permite dar "Enter" no teclado
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Atualizar Status',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Espaço para o botão de scan no futuro
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade de scan a ser implementada!'),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Escanear QR Code'),
              style: TextButton.styleFrom(foregroundColor: wickRed),
            ),
          ],
        ),
      ),
    );
  }
}
