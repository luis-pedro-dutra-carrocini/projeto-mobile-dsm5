import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/divida.dart';
import 'formulario.dart';
import '../../repository/appDividas.dart';

class ListaDividas extends StatefulWidget {
  const ListaDividas({super.key});

  @override
  State<StatefulWidget> createState() {
    return ListaTranferenciasState();
  }
}

class ListaTranferenciasState extends State<ListaDividas> {
  static const _tituloAppBar = "Dívidas";
  final List<Divida> _dividas = [];

  @override
  void initState() {
    super.initState();
    _carregarDividas();
  }

  Future<void> _carregarDividas() async {
    try {
      final dividas = await RepositorioAppDividas.instancia.buscarDividas();

      if (!mounted) return;

      setState(() {
        _dividas.clear();
        _dividas.addAll(dividas);
      });
    } catch (erro) {
      debugPrint('Erro ao carregar dívidas: $erro');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dívidas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar)),
      body: _dividas.isEmpty
          ? const Center(child: Text('Nenhuma dívida encontrada!'))
          : ListView.builder(
              itemCount: _dividas.length,
              itemBuilder: (context, indice) {
                final divida = _dividas[indice];
                return ItemDivida(
                  divida: divida,
                  onStatusChanged: _carregarDividas,
                  onEdit: _carregarDividas,
                  onDelete: _carregarDividas,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioDivida()),
          );
          await _carregarDividas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ItemDivida extends StatelessWidget {
  final Divida divida;
  final VoidCallback onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemDivida({
    super.key,
    required this.divida,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _alterarStatus(BuildContext context) async {
    final novoStatus = divida.status == 'paga' ? 'pendente' : 'paga';
    
    try {
      await RepositorioAppDividas.instancia.atualizarStatusDivida(
        divida.id!,
        novoStatus,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status alterado para $novoStatus')),
        );
        onStatusChanged();
      }
    } catch (erro) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar status: $erro')),
        );
      }
    }
  }

  Future<void> _editarDivida(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioDivida(divida: divida),
      ),
    );
    
    if (result == true && context.mounted) {
      onEdit();
    }
  }

  Future<void> _deletarDivida(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta dívida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmar == true) {
      try {
        await RepositorioAppDividas.instancia.deletarDivida(divida.id!);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dívida excluída com sucesso')),
          );
          onDelete();
        }
      } catch (erro) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $erro')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat formato = NumberFormat.simpleCurrency(locale: 'pt_BR');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: divida.status == 'paga' ? Colors.green : Colors.red,
          child: Icon(
            divida.status == 'paga' ? Icons.check : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          formato.format(divida.valor).toString(),
          style: TextStyle(
            decoration: divida.status == 'paga' 
                ? TextDecoration.lineThrough 
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conta: ${divida.numeroConta}'),
            if (divida.descricao != null && divida.descricao!.isNotEmpty)
              Text(
                divida.descricao!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'status':
                await _alterarStatus(context);
                break;
              case 'editar':
                await _editarDivida(context);
                break;
              case 'excluir':
                await _deletarDivida(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz),
                  SizedBox(width: 8),
                  Text('Alterar status'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'excluir',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _alterarStatus(context),
      ),
    );
  }
}