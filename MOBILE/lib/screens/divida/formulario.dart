import 'package:flutter/material.dart';
import '../../models/divida.dart';
import '../../components/editor.dart';
import '../../repository/appDividas.dart';

class FormularioDivida extends StatefulWidget {
  final int? numeroConta;
  final Divida? divida; // Para edição

  const FormularioDivida({
    super.key,
    this.numeroConta,
    this.divida,
  });

  @override
  State<FormularioDivida> createState() => _FormularioDividaState();
}

class _FormularioDividaState extends State<FormularioDivida> {
  final TextEditingController _controladorCampoNumeroConta = TextEditingController();
  final TextEditingController _controladorCampoValor = TextEditingController();
  final TextEditingController _controladorCampoDescricao = TextEditingController();

  static const _rotuloCampoValor = 'Valor';
  static const _dicaCampoValor = '0,00';
  static const _rotuloCampoNumeroConta = 'Número da conta';
  static const _dicaCampoNumeroConta = '0000';
  static const _rotuloCampoDescricao = 'Descrição';
  static const _dicaCampoDescricao = 'Emprestado para pagar contas';
  static const _textoBotaoConfirmar = 'Confirmar';

  bool _salvando = false;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    
    // Se for edição, preenche os campos
    if (widget.divida != null) {
      _editando = true;
      _controladorCampoNumeroConta.text = widget.divida!.numeroConta.toString();
      _controladorCampoValor.text = widget.divida!.valor.toString();
      _controladorCampoDescricao.text = widget.divida!.descricao ?? '';
    }
    // Se recebeu número da conta (vindo do contato)
    else if (widget.numeroConta != null) {
      _controladorCampoNumeroConta.text = widget.numeroConta.toString();
    }
  }

  @override
  void dispose() {
    _controladorCampoNumeroConta.dispose();
    _controladorCampoValor.dispose();
    _controladorCampoDescricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editando Dívida' : 'Criando Dívida'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16.0),
            Editor(
              controlador: _controladorCampoNumeroConta,
              rotulo: _rotuloCampoNumeroConta,
              dica: _dicaCampoNumeroConta,
              icone: Icons.numbers,
              tipoTeclado: TextInputType.number,
            ),
            Editor(
              controlador: _controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.monetization_on,
              tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            ),
            Editor(
              controlador: _controladorCampoDescricao,
              rotulo: _rotuloCampoDescricao,
              dica: _dicaCampoDescricao,
              icone: Icons.description,
              tipoTeclado: TextInputType.text,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvarDivida,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(_textoBotaoConfirmar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarDivida() async {
    final int? numeroConta = int.tryParse(_controladorCampoNumeroConta.text);
    final textoValor = _controladorCampoValor.text.replaceAll(',', '.');
    final double? valor = double.tryParse(textoValor);

    if (numeroConta == null || numeroConta <= 0) {
      _mostrarErro('Número da conta inválido.');
      return;
    }

    if (valor == null || valor <= 0) {
      _mostrarErro('Valor deve ser maior que 0.');
      return;
    }

    final String descricao = _controladorCampoDescricao.text.trim();

    try {
      setState(() => _salvando = true);

      if (_editando && widget.divida != null) {
        // Atualizar dívida existente
        final dividaAtualizada = Divida(
          valor,
          numeroConta,
          descricao,
          widget.divida!.status,
          id: widget.divida!.id,
        );
        await RepositorioAppDividas.instancia.atualizarDivida(dividaAtualizada);
        
        if (!mounted) return;
        _mostrarSucesso('Dívida atualizada com sucesso.');
      } else {
        // Criar nova dívida
        final dividaCriada = Divida(valor, numeroConta, descricao, 'pendente');
        await RepositorioAppDividas.instancia.salvarDivida(dividaCriada);
        
        if (!mounted) return;
        _mostrarSucesso('Dívida salva com sucesso.');
      }

      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      _mostrarErro('Erro ao salvar dívida: $erro');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dívida salva com sucesso.')),
    );
  }
}