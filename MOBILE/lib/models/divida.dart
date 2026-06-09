// classe que representa uma transferência no projeto app dividas.
// essa classe será usada tanto para a persistência local quanto
// para a comunicação com a api remota.
class Divida {
  // id da transferência.
  // o int? indica que o id pode ser nulo.
  // isso acontece porque, antes de salvar no banco, a transferência ainda não tem id.
  // normalmente, quem gera o id é o banco de dados.
  final int? id;

  // valor monetário da transferência.
  final double valor;

  // número da conta de destino da transferência.
  final int numeroConta;

  // descrição da dívida.
  final String? descricao;

  // status da dívida, que pode ser "pendente" ou "paga".
  final String? status;

  // construtor da classe.
  // valor e numeroConta continuam sendo obrigatórios,
  // mantendo compatibilidade com a versão anterior do projeto.
  //
  // o id é opcional e nomeado, por isso aparece entre chaves: {this.id}
  Divida(this.valor, this.numeroConta, this.descricao, this.status, {this.id});

  // factory constructor usado para criar um objeto Divida
  // a partir de um Map vindo de um JSON.
  //
  // esse método será usado quando o Flutter receber dados da api.
  factory Divida.fromJson(Map<String, dynamic> json) {
    // pega o valor recebido no campo "valor" do JSON.
    //
    // dependendo do banco ou da api, esse valor pode chegar como:
    // - número: 150.75
    // - texto: "150.75"
    final valorRecebido = json['valor'];

    // variável que armazenará o valor convertido para double.
    double valorConvertido;

    // verifica se o valor recebido veio como String.
    if (valorRecebido is String) {
      // se veio como texto, converte para double.
      valorConvertido = double.parse(valorRecebido);
    } else {
      // se veio como número, converte para double de forma segura.
      //
      // usamos "as num" porque o valor pode ser int ou double.
      // depois usamos toDouble() para garantir o tipo double.
      valorConvertido = (valorRecebido as num).toDouble();
    }

    // retorna um novo objeto Divida preenchido
    // com os dados recebidos da api.
    return Divida(
      // valor já convertido para double.
      valorConvertido,

      // no banco e na api, o campo está como numero_conta.
      // no Dart, usamos numeroConta.
      json['numero_conta'],

      // descrição da dívida, que pode ser nula.
      json['descricao'],

      // status da dívida, que pode ser nulo.
      json['status'],

      // id recebido da api.
      id: json['id'],
    );
  }

  // método usado para converter um objeto Divida em Map.
  //
  // esse Map será transformado em JSON quando enviarmos dados
  // do Flutter para a api.
  Map<String, dynamic> toJson() {
    return {
      // envia o valor da transferência.
      'valor': valor,

      // envia o número da conta no padrão esperado pela api.
      //
      // repare que aqui usamos numeroConta, pois foi esse nome
      // que definimos no body da requisição POST da api.
      'numeroConta': numeroConta,

      // envia a descrição da dívida.
      'descricao': descricao,
    };
  }

  // sobrescreve o método toString().
  //
  // isso facilita a visualização do objeto no console,
  // no debugPrint ou em testes simples na tela.
  @override
  String toString() {
    return 'Divida{id: $id, valor: $valor, numeroConta: $numeroConta, descricao: $descricao}';
  }
}