import 'package:flutter/material.dart';
import 'contatos/lista.dart';
import 'divida/lista.dart';
import '../repository/configuracaoPersistencia.dart';
//import 'testes/teste_api.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Variável para controlar a seleção atual
  OrigemPersistencia _origemSelecionada = ConfiguracaoPersistencia.origem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Dívidas"),
        // ALTERAÇÃO: adiciona um subtítulo mostrando a origem atual
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              
              // Título da seção de funcionalidades
              const Text(
                'Funcionalidades',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),

              // Cria uma linha com dois "cards" lado a lado (Contatos e Dívidas)
              Wrap(
                spacing: 12,
                runSpacing: 12,

                children: [
                  // Card: acesso à tela de contatos
                  _FeatureItem(
                    nome: 'Contatos',
                    icone: Icons.people,
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListaContatos(),
                        ),
                      );
                    },
                  ),

                  // Card: acesso à tela de dívidas
                  _FeatureItem(
                    nome: 'Dívidas',
                    icone: Icons.monetization_on,
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListaDividas(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            
              const SizedBox(height: 24),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Origem dos Dados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Radio button para persistência local
                      RadioListTile<OrigemPersistencia>(
                        title: const Text('Local (SQLite)'),
                        subtitle: const Text('Os dados são salvos no dispositivo'),
                        value: OrigemPersistencia.local,
                        groupValue: _origemSelecionada,
                        onChanged: (OrigemPersistencia? value) {
                          if (value != null) {
                            setState(() {
                              _origemSelecionada = value;
                              ConfiguracaoPersistencia.origem = value;
                            });
                            
                            // Mostra snackbar confirmando a mudança
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value == OrigemPersistencia.local 
                                    ? 'Usando dados locais (SQLite)' 
                                    : 'Usando dados remotos (API)'
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      
                      // Radio button para persistência remota
                      RadioListTile<OrigemPersistencia>(
                        title: const Text('Remoto (API)'),
                        subtitle: const Text('Os dados são salvos no servidor'),
                        value: OrigemPersistencia.remota,
                        groupValue: _origemSelecionada,
                        onChanged: (OrigemPersistencia? value) {
                          if (value != null) {
                            setState(() {
                              _origemSelecionada = value;
                              ConfiguracaoPersistencia.origem = value;
                            });
                            
                            // Mostra snackbar confirmando a mudança
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value == OrigemPersistencia.local 
                                    ? 'Usando dados locais (SQLite)' 
                                    : 'Usando dados remotos (API)'
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Ícone informativo
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Os dados serão carregados da fonte selecionada.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String nome;
  final IconData icone;
  final void Function() onClick;

  const _FeatureItem({
    required this.nome,
    required this.icone,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 202, 2, 2),
      borderRadius: BorderRadius.circular(12),

      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),

        child: Container(
          height: 120,
          width: 120,
          padding: const EdgeInsets.all(8),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}