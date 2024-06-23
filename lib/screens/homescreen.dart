import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cadastro_screen.dart';
import 'editar_cadastro_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de TMB'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pacientes')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum paciente salvo.'));
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              var pacienteDoc = snapshot.data?.docs[index];
              var paciente = pacienteDoc?.data() as Map<String, dynamic>?;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarCadastroScreen(
                        pacienteId: pacienteDoc?.id,
                        pacienteData: paciente,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (paciente != null && paciente.containsKey('imageUrl') && paciente['imageUrl'] != null)
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(paciente['imageUrl']),
                            ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paciente?['nome'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('TMB: ${paciente?['tmb']?.toStringAsFixed(2) ?? ''}'),
                                SizedBox(height: 4),
                                Text('Sexo: ${paciente?['sexo'] ?? ''}'),
                                SizedBox(height: 4),
                                Text('CEP: ${paciente?['cep'] ?? ''}'),
                                SizedBox(height: 4),
                                Text('Peso: ${paciente?['peso'] ?? ''} kg'),
                                SizedBox(height: 4),
                                Text('Altura: ${paciente?['altura'] ?? ''} cm'),
                                SizedBox(height: 4),
                                Text('Idade: ${paciente?['idade'] ?? ''}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
