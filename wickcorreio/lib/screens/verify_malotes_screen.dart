import 'package:flutter/material.dart';
import 'package:wickcorreio/screens/malote_tracking_screen.dart';
import 'package:wickcorreio/services/api_service.dart';
import '../main.dart';

class VerifyMalotesScreen extends StatefulWidget {
  const VerifyMalotesScreen({super.key});

  @override
  State<VerifyMalotesScreen> createState() => _VerifyMalotesScreenState();
}

class _VerifyMalotesScreenState extends State<VerifyMalotesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _malotesFuture;

  @override
  void initState() {
    super.initState();
    // Carrega a lista inicial
    _malotesFuture = _apiService.getMalotes();
  }

  void _searchMalotes(String query) {
    setState(() {
      _malotesFuture = _apiService.getMalotes(searchTerm: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Malotes'),
        backgroundColor: wickRed,
        foregroundColor: wickWhite,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onSubmitted: _searchMalotes,
              decoration: InputDecoration(
                labelText: 'Pesquisar por nome ou código',
                suffixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _malotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum malote encontrado.'));
                }

                final malotes = snapshot.data!;
                return ListView.builder(
                  itemCount: malotes.length,
                  itemBuilder: (context, index) {
                    final malote = malotes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text('${malote['barcode']} - ${malote['nome']}'),
                        subtitle: Text('Status: ${malote['status']}'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: wickRed,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MaloteTrackingScreen(malote: malote),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
