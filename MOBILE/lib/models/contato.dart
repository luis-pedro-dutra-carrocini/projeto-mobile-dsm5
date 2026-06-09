// classe que representa um contato no projeto app dividas.
//
// essa classe será usada tanto para:
// - persistência local com sqlite;
// - comunicação remota com a api.
class Contato {
  // id do contato.
  //
  // o tipo int? indica que o id pode ser nulo.
  // isso é importante porque, antes de salvar no banco,
  // o contato ainda não possui um id.
  //
  // normalmente, o id é gerado automaticamente pelo banco de dados.
  final int? id;

  // nome do contato.
  //
  // esse campo é obrigatório, pois todo contato precisa ter um nome.
  final String nome;

  // número da conta associada ao contato.
  //
  // esse campo também é obrigatório, pois será usado
  // posteriormente nas transferências.
  final int numeroConta;

  // construtor da classe Contato.
  //
  // o id é opcional, pois pode não existir no momento da criação do objeto.
  // nome e numeroConta são obrigatórios, por isso usam required.
  Contato({
    this.id,
    required this.nome,
    required this.numeroConta,
  });

  // método usado para converter o objeto Contato em um Map.
  //
  // esse formato é utilizado pelo sqlite para salvar os dados
  // no banco local do dispositivo.
  Map<String, dynamic> toMap() {
    return {
      // id do contato.
      // pode ser nulo quando o contato ainda não foi salvo.
      'id': id,

      // nome do contato.
      'nome': nome,

      // número da conta no padrão usado no banco de dados local.
      //
      // no dart usamos numeroConta.
      // no banco usamos numero_conta.
      'numero_conta': numeroConta,
    };
  }

  // factory constructor usado para criar um objeto Contato
  // a partir de um Map vindo de um JSON.
  //
  // esse método será usado quando o flutter receber contatos da api.
  factory Contato.fromJson(Map<String, dynamic> json) {
    return Contato(
      // id recebido da api.
      id: json['id'],

      // nome recebido da api.
      nome: json['nome'],

      // número da conta recebido da api.
      //
      // na api e no banco, o campo está como numero_conta.
      // no dart, vamos armazenar em numeroConta.
      numeroConta: json['numero_conta'],
    );
  }

  // método usado para converter um objeto Contato em Map
  // no formato esperado pela api.
  //
  // esse Map será transformado em JSON quando enviarmos
  // um contato para o backend.
  Map<String, dynamic> toJson() {
    return {
      // envia o nome do contato.
      'nome': nome,

      // envia o número da conta no padrão que a api espera receber.
      //
      // na rota POST /contatos, criamos o backend esperando numeroConta.
      'numeroConta': numeroConta,
    };
  }

  // sobrescreve o método toString().
  //
  // isso facilita a visualização do objeto no console,
  // no debugPrint ou na tela temporária de testes.
  @override
  String toString() {
    return 'Contato{id: $id, nome: $nome, numeroConta: $numeroConta}';
  }
}