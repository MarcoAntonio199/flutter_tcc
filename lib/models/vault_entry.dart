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

const List<String> vaultCategories = ['Trabalho', 'Pessoal', 'Bancos', 'Redes'];
