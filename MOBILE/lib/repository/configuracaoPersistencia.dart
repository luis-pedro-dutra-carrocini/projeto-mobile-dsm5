// enum usado para representar as possíveis origens de persistência do app.
//
// local  → os dados serão salvos e buscados no SQLite.
// remota → os dados serão salvos e buscados pela API no Render.
enum OrigemPersistencia {
  local,
  remota,
}

// classe responsável por centralizar a configuração de persistência.
//
// agora a escolha pode ser alterada dinamicamente em tempo de execução.
class ConfiguracaoPersistencia {
  // ALTERAÇÃO: variável estática que pode ser modificada em tempo de execução
  static OrigemPersistencia _origem = OrigemPersistencia.local;
  
  // Getter para acessar a origem atual
  static OrigemPersistencia get origem => _origem;
  
  // Setter para alterar a origem
  static set origem(OrigemPersistencia novaOrigem) {
    _origem = novaOrigem;
  }
  
  // Método para alternar entre local e remoto
  static void alternarOrigem() {
    if (_origem == OrigemPersistencia.local) {
      _origem = OrigemPersistencia.remota;
    } else {
      _origem = OrigemPersistencia.local;
    }
  }
}