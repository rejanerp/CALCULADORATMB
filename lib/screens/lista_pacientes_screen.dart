import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListaPacientesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes Salvos'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pacientes')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              var paciente = snapshot.data?.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
