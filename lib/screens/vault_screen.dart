import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../models/vault_entry.dart';
import '../services/password_api_service.dart';
import '../theme/app_theme.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final PasswordApiService _api = PasswordApiService(baseUrl: 'http://localhost:3000');

  final List<VaultEntry> _entries = [
    VaultEntry(id: '1', service: 'Gmail', account: 'usuario1@email.com', password: 'aB3!kLmZ9', category: 'Pessoal'),
    VaultEntry(id: '2', service: 'Slack - Trabalho', account: 'usuario2@email.com', password: 'Qw9#xTr2P', category: 'Trabalho'),
    VaultEntry(id: '3', service: 'Banco Itaú', account: 'usuario3@email.com', password: 'Zx7u799', category: 'Bancos'),
    VaultEntry(id: '4', service: 'Instagram', account: 'usuario4@email.com', password: 'Lp5&Kj8Rt', category: 'Redes'),
    VaultEntry(id: '5', service: 'Netflix', account: 'usuario5@email.com', password: 'Hy2@Gf6Ds', category: 'Pessoal'),
  ];

  String _search = '';
  String _selectedCategory = 'Todas';

  List<VaultEntry> get _filteredEntries {
    return _entries.where((entry) {
      final matchesSearch = entry.service.toLowerCase().contains(_search.toLowerCase()) ||
          entry.account.toLowerCase().contains(_search.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todas' || entry.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado!')),
    );
  }

  void _openEntryDetail(VaultEntry entry) {
    bool obscure = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(entry.service, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(entry.category, style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 20),
                  const Text('USUÁRIO / EMAIL', style: AppTheme.fieldLabel),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Text(entry.account)),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(entry.account, 'Usuário'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('SENHA', style: AppTheme.fieldLabel),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          obscure ? '•' * entry.password.length : entry.password,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setSheetState(() => obscure = !obscure),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(entry.password, 'Senha'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAddEntrySheet() async {
    final serviceController = TextEditingController();
    final accountController = TextEditingController();
    final passwordController = TextEditingController();
    String category = vaultCategories.first;
    bool generating = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nova conta',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    const Text('NOME DO SERVIÇO', style: AppTheme.fieldLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: serviceController,
                      decoration: const InputDecoration(hintText: 'ex: Spotify'),
                    ),
                    const SizedBox(height: 16),
                    const Text('USUÁRIO / EMAIL', style: AppTheme.fieldLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: accountController,
                      decoration: const InputDecoration(hintText: 'exemplo@gmail.com'),
                    ),
                    const SizedBox(height: 16),
                    const Text('SENHA', style: AppTheme.fieldLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'digite ou gere uma senha',
                        suffixIcon: IconButton(
                          tooltip: 'Gerar senha automaticamente',
                          icon: generating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.autorenew, color: AppTheme.textSecondary),
                          onPressed: generating
                              ? null
                              : () async {
                                  setSheetState(() => generating = true);
                                  try {
                                    final generated = await _api.generatePassword(
                                      length: 16,
                                      selectedOptionIds: const {'lowercase', 'uppercase', 'numbers', 'symbols'},
                                    );
                                    passwordController.text = generated;
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Não foi possível gerar a senha. Verifique a API.')),
                                      );
                                    }
                                  } finally {
                                    setSheetState(() => generating = false);
                                  }
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('CATEGORIA', style: AppTheme.fieldLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: vaultCategories.map((c) {
                        final selected = c == category;
                        return ChoiceChip(
                          label: Text(
                            c,
                            style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w600),
                          ),
                          selected: selected,
                          onSelected: (_) => setSheetState(() => category = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (serviceController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Preencha ao menos o serviço e a senha.')),
                          );
                          return;
                        }
                        setState(() {
                          _entries.insert(
                            0,
                            VaultEntry(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              service: serviceController.text.trim(),
                              account: accountController.text.trim(),
                              password: passwordController.text.trim(),
                              category: category,
                            ),
                          );
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('SALVAR'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Meu Cofre', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    Text(
                      '${_entries.length} contas protegidas',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: _openAddEntrySheet,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => _search = value),
            decoration: const InputDecoration(
              hintText: 'Buscar conta...',
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'Todas',
                  selected: _selectedCategory == 'Todas',
                  onTap: () => setState(() => _selectedCategory = 'Todas'),
                ),
                for (final c in vaultCategories)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _CategoryChip(
                      label: c,
                      selected: _selectedCategory == c,
                      onTap: () => setState(() => _selectedCategory = c),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Nenhuma conta encontrada.', style: TextStyle(color: AppTheme.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return _VaultEntryTile(
                        entry: entry,
                        onTap: () => _openEntryDetail(entry),
                        onCopy: () => _copyToClipboard(entry.password, 'Senha'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w600),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _VaultEntryTile extends StatelessWidget {
  final VaultEntry entry;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  const _VaultEntryTile({required this.entry, required this.onTap, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.vpn_key_outlined, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.service, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(entry.account, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: onCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
