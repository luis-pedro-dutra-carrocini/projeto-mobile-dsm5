import 'package:flutter/material.dart';
import 'formulario.dart';
import '../../models/divida.dart';

class ListaDevedores extends StatefulWidget {
  final List<Divida> _dividas = [];
  @override
  State<StatefulWidget> createState() {
    return ListaTranferenciaState();
  }
}

class ListaTranferenciaState extends State<ListaDevedores> {
  static const _tituloAppBar = 'Devedores';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tituloAppBar,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: const Color.fromARGB(255, 211, 44, 44),
      ),

      body: widget._dividas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Nenhuma dívida registrada",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Toque no botão + para adicionar",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget._dividas.length,
              itemBuilder: (context, indice) {
                final divida = widget._dividas[indice];
                return ItemDivida(divida);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Botão + Pressionado!");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FormularioDivida();
              },
            ),
          ).then((dividaRecebida) => _atualiza(dividaRecebida));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _atualiza(Divida? dividaRecebida) {
    if (dividaRecebida != null) {
      setState(() {
        widget._dividas.add(dividaRecebida);
      });
    }
  }
}

class ItemDivida extends StatelessWidget {
  final Divida _divida;

  ItemDivida(this._divida);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.monetization_on),
        title: Text(_divida.nomeDevedor.toString()),
        subtitle: Text(_divida.descricaoDivida.toString()),
        trailing: Text(_divida.valor.toString()),
      ),
    );
  }
}
