import 'package:tmbpk/tmbpk.dart';
import 'package:test/test.dart';

void main() {
  group('calcularTMB:', () {
    test('Deve retornar 1772.2 para um homem com 70kg, 178cm, 21 anos', () {
      // Arrumação
      double peso = 70;
      double altura = 178;
      int idade = 21;
      String sexo = 'Homem';
      double tmbEsperada = 1772.2;

      // Ação
      double tmbEncontrada = calcularTMB(
        peso: peso,
        altura: altura,
        idade: idade,
        sexo: sexo,
      );

      // Averiguação
      expect(tmbEncontrada, tmbEsperada);
    });

    test('Deve retornar 1330.0 para uma mulher com 55kg, 160cm, 30 anos', () {
      double peso = 55;
      double altura = 160;
      int idade = 30;
      String sexo = 'Mulher';
      double tmbEsperada = 1330.0;

      double tmbEncontrada = calcularTMB(
        peso: peso,
        altura: altura,
        idade: idade,
        sexo: sexo,
      );

      expect(tmbEncontrada, tmbEsperada);
    });

    test('Deve lançar ArgumentError para sexo inválido', () {
      double peso = 70;
      double altura = 178;
      int idade = 21;
      String sexo = 'Outro';

      expect(() => calcularTMB(
        peso: peso,
        altura: altura,
        idade: idade,
        sexo: sexo,
      ), throwsArgumentError);
    });
  });
}
