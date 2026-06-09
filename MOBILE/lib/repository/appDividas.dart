import '../models/divida.dart';
import '../models/contato.dart';
import 'configuracaoPersistencia.dart';
import '../db/database.dart' as bancolocal;
import '../services/api.dart';

abstract class AppDividasRepository {  
  Future<List<Divida>> buscarDividas(); 
  Future<void> salvarDivida(Divida divida);
  Future<void> atualizarDivida(Divida divida);
  Future<void> atualizarStatusDivida(int id, String status);
  Future<void> deletarDivida(int id);
  Future<List<Contato>> buscarContatos();  
  Future<void> salvarContato(Contato contato);
  Future<void> atualizarContato(Contato contato);
  Future<void> deletarContato(int id);
}

class AppDividasRepositoryLocal implements AppDividasRepository {
  @override
  Future<List<Divida>> buscarDividas() {
    return bancolocal.buscarDividas();
  }

  @override
  Future<void> salvarDivida(Divida divida) async {    
    await bancolocal.salvarDivida(divida);
  }

  @override
  Future<void> atualizarDivida(Divida divida) async {
    await bancolocal.atualizarDivida(divida);
  }

  @override
  Future<void> atualizarStatusDivida(int id, String status) async {
    await bancolocal.atualizarStatusDivida(id, status);
  }

  @override
  Future<void> deletarDivida(int id) async {
    await bancolocal.deletarDivida(id);
  }

  @override
  Future<List<Contato>> buscarContatos() {    
    return bancolocal.buscarContatos();
  }

  @override
  Future<void> salvarContato(Contato contato) async {    
    await bancolocal.salvarContato(contato);
  }

  @override
  Future<void> atualizarContato(Contato contato) async {
    await bancolocal.atualizarContato(contato);
  }

  @override
  Future<void> deletarContato(int id) async {
    await bancolocal.deletarContato(id);
  }
}

class AppDividasRepositoryRemoto implements AppDividasRepository {
  @override
  Future<List<Divida>> buscarDividas() {
    return ApiService.buscarDividas();
  }

  @override
  Future<void> salvarDivida(Divida divida) async {
    await ApiService.salvarDivida(divida);
  }

  @override
  Future<void> atualizarDivida(Divida divida) async {
    await ApiService.atualizarDivida(divida);
  }

  @override
  Future<void> atualizarStatusDivida(int id, String status) async {
    await ApiService.atualizarStatusDivida(id, status);
  }

  @override
  Future<void> deletarDivida(int id) async {
    await ApiService.deletarDivida(id);
  }

  @override
  Future<List<Contato>> buscarContatos() {
    return ApiService.buscarContatos();
  }

  @override
  Future<void> salvarContato(Contato contato) async {    
    await ApiService.salvarContato(contato);
  }

  @override
  Future<void> atualizarContato(Contato contato) async {
    await ApiService.atualizarContato(contato);
  }

  @override
  Future<void> deletarContato(int id) async {
    await ApiService.deletarContato(id);
  }
}

class RepositorioAppDividas {  
  static AppDividasRepository get instancia {    
    switch (ConfiguracaoPersistencia.origem) {      
      case OrigemPersistencia.local:
        return AppDividasRepositoryLocal();      
      case OrigemPersistencia.remota:
        return AppDividasRepositoryRemoto();
    }
  }
}