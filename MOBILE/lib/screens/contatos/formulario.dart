import 'package:flutter/material.dart';

// importa o componente Editor.
// ele padroniza os campos de texto usados no projeto.
import '../../components/editor.dart';

// importa o model Contato.
import '../../models/contato.dart';

// ALTERAÇÃO:
// importa o repository.
// ele será responsável por decidir se o contato será salvo
// no SQLite local ou na API remota.
import '../../repository/appDividas.dart';

class FormularioContato extends StatefulWidget {
  const FormularioContato({super.key});

  @override
  State<FormularioContato> createState() => _FormularioContatoState();
}

class _FormularioContatoState extends State<FormularioContato> {
  // controlador do campo de nome.
  final TextEditingController _controladorNome = TextEditingController();

  // controlador do campo de número da conta.
  final TextEditingController _controladorConta = TextEditingController();

  // controla se o app está salvando o contato.
  //
  // false → não está salvando.
  // true  → está salvando.
  bool _salvando = false;

  @override
  void dispose() {
    // libera os controladores da memória ao fechar a tela.
    _controladorNome.dispose();
    _controladorConta.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // barra superior da tela.
      appBar: AppBar(
        title: const Text('Novo Contato'),
      ),

      // permite rolagem caso o conteúdo não caiba na tela.
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.0),

            // campo para digitar o nome do contato.
            Editor(
              controlador: _controladorNome,
              rotulo: 'Nome',
              dica: 'Ex: Maria Oliveira',
              icone: Icons.person,
              tipoTeclado: TextInputType.text,
            ),

            // campo para digitar o número da conta.
            Editor(
              controlador: _controladorConta,
              rotulo: 'Número da conta',
              dica: '0000',
              icone: Icons.numbers,
              tipoTeclado: TextInputType.number,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),

              // botão responsável por salvar o contato.
              child: ElevatedButton(
                // se estiver salvando, o botão fica desabilitado.
                onPressed: _salvando ? null : _salvarContato,

                // se estiver salvando, mostra um indicador.
                // caso contrário, mostra o texto "Salvar".
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // função responsável por validar e salvar o contato.
  Future<void> _salvarContato() async {
    // recupera o nome digitado e remove espaços antes e depois.
    final String nome = _controladorNome.text.trim();

    // tenta converter o número da conta para inteiro.
    final int? conta = int.tryParse(
      _controladorConta.text,
    );

    // valida se o nome foi preenchido.
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome do contato.'),
        ),
      );
      return;
    }

    // valida se a conta é um número válido e maior que zero.
    if (conta == null || conta <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número da conta inválido.'),
        ),
      );
      return;
    }

    // cria o objeto Contato com os dados informados.
    final contatoCriado = Contato(
      nome: nome,
      numeroConta: conta,
    );

    try {
      // indica que o salvamento começou.
      setState(() {
        _salvando = true;
      });

      // ALTERAÇÃO:
      // salva o contato usando o repository.
      //
      // antes, o formulário chamava diretamente salvarContato()
      // do app_database.dart.
      //
      // agora, o repository decidirá se o contato será salvo:
      // - no SQLite local;
      // - ou na API remota.
      await RepositorioAppDividas.instancia.salvarContato(contatoCriado);

      // se a tela não estiver mais montada, interrompe a execução.
      if (!mounted) return;

      // mostra mensagem de sucesso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contato salvo com sucesso.'),
        ),
      );

      // fecha a tela e volta para a lista.
      Navigator.pop(context);
    } catch (erro) {
      // se ocorrer erro, verifica se a tela ainda está montada.
      if (!mounted) return;

      // mostra mensagem de erro.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar contato: $erro'),
        ),
      );
    } finally {
      // o finally executa dando certo ou dando erro.
      //
      // aqui encerramos o estado de carregamento.
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }
}