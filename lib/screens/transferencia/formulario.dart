import 'package:flutter/material.dart';
import '../../components/editorText.dart';
import '../../components/editorNumber.dart';
import '../../models/divida.dart';

class FormularioDivida extends StatefulWidget {
  final TextEditingController _controladorNomeDevedor =
      TextEditingController();
  final TextEditingController _controladorCampoValor = TextEditingController();
  final TextEditingController _controladorDescricaoDivida = TextEditingController();
  @override
  State<StatefulWidget> createState() {
    return FormularioDividaState();
  }
}

class FormularioDividaState extends State<FormularioDivida> {
  
  static const _tituloAppBar = 'Criando Dívida';
  static const _rotuloCampoValor = 'Valor';
  static const _dicaCampoValor = '0.00';

  static const _rotuloCamponomeDevedor = 'Nome do Devedor';
  static const _dicaNomeDevedor = 'Carlos Alberto';
  static const _textBotaoConfirmar = 'Confirmar';

  static const _rotuloCampoDescricaoDivida = 'Descrição da Dívida';
  static const _dicaDescricaoDivida = 'Emprestado para comprar um presente';

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tituloAppBar,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            EditorText(
              controlador: widget._controladorNomeDevedor,
              rotulo: _rotuloCamponomeDevedor,
              dica: _dicaNomeDevedor,
              icone: Icons.people_alt_outlined
            ),

            EditorNumber(
              controlador: widget._controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.monetization_on,
            ),

            EditorText(
              controlador: widget._controladorDescricaoDivida,
              rotulo: _rotuloCampoDescricaoDivida,
              dica: _dicaDescricaoDivida,
              icone: Icons.edit_document
            ),

            ElevatedButton(
              child: Text(_textBotaoConfirmar),
              onPressed: () {
                debugPrint("Clicou no Confirmar!");
                _criaTransferencia(
                  context,
                  widget._controladorNomeDevedor,
                  widget._controladorCampoValor,
                  widget._controladorDescricaoDivida,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _criaTransferencia(
  BuildContext context,
  TextEditingController controladorNomeDevedor,
  TextEditingController controladorCampoValor,
  TextEditingController controladorDescricaoDivida
) {
  final String? nomeDevedor = controladorNomeDevedor.text;
  final String? descricaoDivida = controladorDescricaoDivida.text;
  final double valor = double.parse(controladorCampoValor.text.replaceAll(',', '.'));

  if (nomeDevedor != null && valor != null && descricaoDivida != null) {
    final dividaCriada = Divida(valor, nomeDevedor, descricaoDivida);
    debugPrint("Criando Dívida...");
    debugPrint("$dividaCriada");
    Navigator.pop(context, dividaCriada);
  }
}