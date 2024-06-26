import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tmbpk/tmbpk.dart';

class EditarCadastroScreen extends StatefulWidget {
  final String? pacienteId;
  final Map<String, dynamic>? pacienteData;

  EditarCadastroScreen({this.pacienteId, this.pacienteData});

  @override
  _EditarCadastroScreenState createState() => _EditarCadastroScreenState();
}

class _EditarCadastroScreenState extends State<EditarCadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomeController;
  late TextEditingController cepController;
  late TextEditingController enderecoController;
  late TextEditingController numeroController;
  late TextEditingController complementoController;
  late TextEditingController bairroController;
  late TextEditingController pesoController;
  late TextEditingController alturaController;
  late TextEditingController idadeController;
  double? tmb;
  String? sexoSelecionado;
  File? _image;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.pacienteData?['nome']);
    cepController = TextEditingController(text: widget.pacienteData?['cep']);
    enderecoController = TextEditingController(text: widget.pacienteData?['endereco']);
    numeroController = TextEditingController(text: widget.pacienteData?['numero']);
    complementoController = TextEditingController(text: widget.pacienteData?['complemento']);
    bairroController = TextEditingController(text: widget.pacienteData?['bairro']);
    pesoController = TextEditingController(text: widget.pacienteData?['peso']);
    alturaController = TextEditingController(text: widget.pacienteData?['altura']);
    idadeController = TextEditingController(text: widget.pacienteData?['idade']);
    sexoSelecionado = widget.pacienteData?['sexo'];
    tmb = widget.pacienteData?['tmb'];
    imageUrl = widget.pacienteData?['imageUrl'];
  }

  void calcularETmb() {
    if (_formKey.currentState?.validate() ?? false) {
      double peso = double.parse(pesoController.text);
      double altura = double.parse(alturaController.text);
      int idade = int.parse(idadeController.text);

      setState(() {
        tmb = calcularTMB(
          peso: peso,
          altura: altura,
          idade: idade,
          sexo: sexoSelecionado ?? '',
        );
      });

      updateFirestore();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('Nenhuma imagem selecionada.');
        }
      });
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> buscarEndereco() async {
    if (cepController.text.isNotEmpty) {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/${cepController.text}/json/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          enderecoController.text = data['logradouro'];
          bairroController.text = data['bairro'];
        });
      } else {
        print('Erro ao buscar endereço');
      }
    }
  }

  Future<void> updateFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      await FirebaseFirestore.instance.collection('pacientes').doc(widget.pacienteId).update({
        'nome': nomeController.text,
        'sexo': sexoSelecionado,
        'cep': cepController.text,
        'endereco': enderecoController.text,
        'numero': numeroController.text,
        'complemento': complementoController.text,
        'bairro': bairroController.text,
        'peso': pesoController.text,
        'altura': alturaController.text,
        'idade': idadeController.text,
        'tmb': tmb,
        'userId': user.uid,
        'imageUrl': imageUrl,
      });
      Navigator.pop(context);
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageReference = FirebaseStorage.instance.ref().child('pacientes/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cadastro de Paciente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTextFormField('Nome', nomeController),
                DropdownButtonFormField<String>(
                  value: sexoSelecionado,
                  hint: Text('Selecione o Sexo'),
                  onChanged: (String? newValue) {
                    setState(() {
                      sexoSelecionado = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione o sexo' : null,
                  items: <String>['Homem', 'Mulher']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                buildTextFormField('CEP', cepController, onChanged: (value) {
                  if (value.length == 8) {
                    buscarEndereco();
                  }
                }),
                buildTextFormField('Endereço', enderecoController),
                buildTextFormField('Número', numeroController),
                buildTextFormField('Complemento', complementoController),
                buildTextFormField('Bairro', bairroController),
                buildTextFormField('Peso (kg)', pesoController),
                buildTextFormField('Altura (cm)', alturaController),
                buildTextFormField('Idade', idadeController),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => pickImage(ImageSource.gallery),
                      child: Text('Selecionar da Galeria'),
                    ),
                    ElevatedButton(
                      onPressed: () => pickImage(ImageSource.camera),
                      child: Text('Tirar Foto'),
                    ),
                  ],
                ),
                if (imageUrl != null)
                  Image.network(imageUrl!, height: 200),
                if (_image != null)
                  Image.file(_image!, height: 200),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: calcularETmb,
                  child: Text('Calcular TMB e Atualizar'),
                ),
                SizedBox(height: 20),
                if (tmb != null) Text('TMB: ${tmb!.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField(String labelText, TextEditingController controller, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Preencha o campo $labelText';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}
