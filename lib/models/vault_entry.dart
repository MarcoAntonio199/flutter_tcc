/// Uma conta salva no cofre (dado mockado em memória — sem persistência real,
/// já que o app é uma demonstração de interface).
class VaultEntry {
  final String id;
  String service;
  String account;
  String password;
  String category; // "Trabalho", "Pessoal", "Bancos", "Redes"

  VaultEntry({
    required this.id,
    required this.service,
    required this.account,
    required this.password,
    required this.category,
  });
}

/// Categorias disponíveis para os chips de filtro do cofre.
const List<String> vaultCategories = ['Trabalho', 'Pessoal', 'Bancos', 'Redes'];
