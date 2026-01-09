import 'package:flutter/material.dart';
import 'package:wickcorreio/screens/malote_details_screen.dart';
import 'package:wickcorreio/services/api_service.dart';
import '../main.dart';

class AddMaloteScreen extends StatefulWidget {
  final String userLocation;
  final String userRe;

  const AddMaloteScreen({
    super.key,
    required this.userLocation,
    required this.userRe,
  });

  @override
  State<AddMaloteScreen> createState() => _AddMaloteScreenState();
}

class _AddMaloteScreenState extends State<AddMaloteScreen> {
  final _apiService = ApiService();
  late TextEditingController _origemController;
  final _nomeController = TextEditingController();
  final _paraQuemController = TextEditingController();

  // Variáveis de estado para o dropdown
  String? _selectedDestino;
  late Future<List<String>> _localidadesFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _origemController = TextEditingController(text: widget.userLocation);
    // Inicia a busca pelas localidades assim que a tela é construída
    _localidadesFuture = _apiService.getLocalidades();
  }

  @override
  void dispose() {
    _origemController.dispose();
    _nomeController.dispose();
    _paraQuemController.dispose();
    super.dispose();
  }

  void _gerarMalote() async {
    // Validação para garantir que um destino foi selecionado
    if (_selectedDestino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um destino.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final maloteInfo = {
      "nome": _nomeController.text,
      "origem": _origemController.text,
      "destinatario": _paraQuemController.text,
      "destino": _selectedDestino!, // Usa o valor do dropdown
      "created_by_re": widget.userRe,
    };

    final result = await _apiService.addMalote(maloteInfo);

    setState(() => _isLoading = false);

    if (result['success'] && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              MaloteDetailsScreen(maloteData: result['data']['malote']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erro desconhecido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Malote'),
        backgroundColor: wickRed,
        foregroundColor: wickWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(controller: _nomeController, label: 'Nome'),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _origemController,
              label: 'Origem',
              enabled: false,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _paraQuemController,
              label: 'Para quem',
            ),
            const SizedBox(height: 20),

            // --- DROPDOWN COM FUTUREBUILDER ---
            FutureBuilder<List<String>>(
              future: _localidadesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhuma localidade encontrada.');
                } else {
                  return DropdownButtonFormField<String>(
                    value: _selectedDestino,
                    hint: const Text('Selecione o destino'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: snapshot.data!.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDestino = newValue;
                      });
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isLoading ? null : _gerarMalote,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Gerar Malote', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        filled: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
