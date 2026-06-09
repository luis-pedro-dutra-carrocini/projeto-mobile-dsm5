import 'package:flutter/material.dart';

// importa o formulário de novo contato.
// essa tela será aberta quando o usuário clicar no botão "+".
import 'formulario.dart';

// importa o model Contato.
// esse model representa os dados de um contato no aplicativo.
import '../../models/contato.dart';

// importa o formulário de transferência.
// ele será aberto quando o usuário tocar em um contato,
// já enviando o número da conta selecionada.
import '../divida/formulario.dart';

// ALTERAÇÃO:
// importa o repository.
// agora a tela não acessa mais diretamente o SQLite.
// o repository será responsável por decidir se os dados vêm
// da persistência local ou da persistência remota.
import '../../repository/appDividas.dart';

// tela responsável por listar os contatos cadastrados.
class ListaContatos extends StatefulWidget {
  const ListaContatos({super.key});

  @override
  State<ListaContatos> createState() => _ListaContatosState();
}

// classe de estado da tela ListaContatos.
//
// usamos StatefulWidget porque a lista de contatos pode mudar
// durante a execução do aplicativo.
class _ListaContatosState extends State<ListaContatos> {
  // título exibido na AppBar.
  static const _tituloAppBar = 'Contatos';

  // lista local em memória usada apenas para exibição na tela.
  //
  // atenção:
  // essa lista não é a persistência definitiva.
  // ela apenas recebe os dados vindos do repository
  // para que sejam exibidos no ListView.
  final List<Contato> _contatos = [];

  @override
  void initState() {
    super.initState();

    // assim que a tela é aberta, carregamos os contatos.
    //
    // esse carregamento poderá vir do SQLite ou da API,
    // dependendo da configuração definida no repository.
    _carregarContatos();
  }

  // função responsável por carregar os contatos.
  //
  // ela é assíncrona porque pode buscar dados:
  // - no SQLite local;
  // - ou na API remota.
  Future<void> _carregarContatos() async {
    try {
      // ALTERAÇÃO:
      // busca os contatos usando o repository.
      //
      // antes, a tela chamava diretamente buscarContatos()
      // do app_database.dart.
      //
      // agora, a tela chama o repository.
      // ele decidirá se os dados vêm do SQLite ou da API.
      final contatos = await RepositorioAppDividas.instancia.buscarContatos();

      // verifica se a tela ainda está montada antes de chamar setState.
      //
      // isso evita erro caso a resposta demore e o usuário já tenha saído da tela.
      if (!mounted) return;

      // atualiza a lista exibida na tela.
      setState(() {
        // limpa os contatos antigos.
        _contatos.clear();

        // adiciona os contatos recebidos do repository.
        _contatos.addAll(contatos);
      });
    } catch (erro) {
      // se ocorrer algum erro ao carregar os contatos,
      // ele será exibido no console para ajudar no diagnóstico.
      debugPrint('Erro ao carregar contatos: $erro');

      // novamente, verificamos se a tela ainda está montada.
      if (!mounted) return;

      // exibe uma mensagem amigável para o usuário.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar contatos.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // barra superior da tela.
      appBar: AppBar(
        title: const Text(_tituloAppBar),
      ),

      // corpo da tela.
      //
      // se a lista estiver vazia, exibe uma mensagem.
      // caso contrário, exibe os contatos em uma lista dinâmica.
      body: _contatos.isEmpty
          ? const Center(
              child: Text('Nenhum contato encontrado.'),
            )
          : ListView.builder(
              // quantidade de itens da lista.
              itemCount: _contatos.length,

              // função responsável por construir cada item da lista.
              itemBuilder: (context, index) {
                // recupera o contato da posição atual.
                final contato = _contatos[index];

                // cada contato será exibido em um Card.
                return Card(
                  child: ListTile(
                    // ícone exibido à esquerda do item.
                    leading: const Icon(Icons.person),

                    // nome do contato.
                    title: Text(contato.nome),

                    // número da conta do contato.
                    subtitle: Text('Conta: ${contato.numeroConta}'),

                    // ao tocar em um contato, abre o formulário
                    // de transferência com a conta já preenchida.
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FormularioDivida(
                            numeroConta: contato.numeroConta,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      // botão flutuante usado para cadastrar um novo contato.
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        // abre o formulário de novo contato.
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FormularioContato(),
            ),
          );

          // ALTERAÇÃO:
          // ao voltar do formulário, recarregamos a lista.
          //
          // isso é melhor do que tentar adicionar manualmente
          // um contato na lista, porque funciona tanto para:
          // - SQLite local;
          // - API remota.
          await _carregarContatos();
        },
      ),
    );
  }
}