import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  double? tmb;
  double? ndcNenhumaAtividade;
  double? ndcAtividadeModerada;
  double? ndcAtividadeIntensa;
  TabController? _tabController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void calcularTMB(bool isHomem) {
    double peso = double.parse(pesoController.text);
    double altura = double.parse(alturaController.text);
    int idade = int.parse(idadeController.text);

    setState(() {
      tmb = isHomem ? calcularTMBHomem(peso, altura, idade) : calcularTMBMulher(peso, altura, idade);
      ndcNenhumaAtividade = tmb! * 1.25;
      ndcAtividadeModerada = tmb! * 1.35;
      ndcAtividadeIntensa = tmb! * 1.45;
    });

    saveToFirestore();
  }

  void saveToFirestore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'peso': pesoController.text,
        'altura': alturaController.text,
        'idade': idadeController.text,
        'tmb': tmb,
        'ndcNenhumaAtividade': ndcNenhumaAtividade,
        'ndcAtividadeModerada': ndcAtividadeModerada,
        'ndcAtividadeIntensa': ndcAtividadeIntensa,
      }, SetOptions(merge: true));
    }
  }

  double calcularTMBHomem(double peso, double altura, int idade) {
    return 66 + (13.7 * peso) + (5 * altura) - (6.8 * idade);
  }

  double calcularTMBMulher(double peso, double altura, int idade) {
    return 655 + (9.6 * peso) + (1.8 * altura) - (4.7 * idade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de TMB'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Homens'),
            Tab(text: 'Mulheres'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildForm(true),
          buildForm(false),
        ],
      ),
    );
  }

  Widget buildForm(bool isHomem) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextField('Peso (kg)', pesoController),
            buildTextField('Altura (cm)', alturaController),
            buildTextField('Idade', idadeController),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => calcularTMB(isHomem),
              child: Text('Calcular TMB'),
            ),
            SizedBox(height: 20),
            if (tmb != null) ...[
              Text('TMB: ${tmb!.toStringAsFixed(2)}'),
              SizedBox(height: 10),
              Text('Nenhuma atividade física: ${ndcNenhumaAtividade!.toStringAsFixed(2)} NDC'),
              Text('Atividade física moderada: ${ndcAtividadeModerada!.toStringAsFixed(2)} NDC'),
              Text('Atividade física intensa: ${ndcAtividadeIntensa!.toStringAsFixed(2)} NDC'),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
