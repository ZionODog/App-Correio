import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _reController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  String? _selectedLocation;
  late Future<List<String>> _localidadesFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _localidadesFuture = _apiService.getLocalidades();
  }

  void _handleRegister() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma localização.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.register(
      _reController.text,
      _passwordController.text,
      _selectedLocation!,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );

    if (result['success'] && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
        backgroundColor: wickWhite,
        elevation: 1,
      ),
      backgroundColor: wickWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/wickbold_logo.png', height: 80),
              const SizedBox(height: 40),

              TextField(
                controller: _reController,
                decoration: const InputDecoration(labelText: 'RE (Registro)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 20),

              FutureBuilder<List<String>>(
                future: _localidadesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return FormField(
                      builder: (FormFieldState<dynamic> state) {
                        return InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Erro ao carregar localidades: ${snapshot.error}',
                    );
                  } else if (snapshot.hasData) {
                    return DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      hint: const Text('Selecione a localização'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: snapshot.data!.map((String location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLocation = newValue;
                        });
                      },
                    );
                  }
                  return const Text('Nenhuma localidade encontrada.');
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
