 // import 'package:flutter/material.dart';

class Divida {
  final double valor;
  final String nomeDevedor;
  final String descricaoDivida;

  Divida(this.valor, this.nomeDevedor, this.descricaoDivida);

  @override
  String toString() {
    return "Divida{valor: $valor, nomeDevedor: $nomeDevedor, descricaoDivida: $descricaoDivida}";
  }
}