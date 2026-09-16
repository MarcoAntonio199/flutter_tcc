import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../models/password_option.dart';
import '../services/password_api_service.dart';
import '../theme/app_theme.dart';

/// Versão discreta do gerador: mesma API do site, mas sem cores fortes,
/// cards coloridos ou ícones chamativos — se encaixando no visual do resto
/// do app (preto e branco, bordas finas, tipografia limpa).
class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final PasswordApiService _api = PasswordApiService(baseUrl: 'http://localhost:3000');

  bool _loadingOptions = true;
  String? _loadError;
  List<PasswordOption> _availableOptions = [];
  final Set<String> _selectedOptionIds = {};

  int _length = 16;
  int _minLength = 4;
  int _maxLength = 32;

  bool _generating = false;
  String? _generatedPassword;
  String? _generateError;

  @override
  void initState() {
    super.initState();
    _loadCharacterSets();
  }

  Future<void> _loadCharacterSets() async {
    setState(() {
      _loadingOptions = true;
      _loadError = null;
    });

    try {
      final result = await _api.fetchCharacterSets();
      setState(() {
        _availableOptions = result.options;
        _minLength = result.length.min;
        _maxLength = result.length.max.clamp(result.length.min, 64);
        _length = result.length.defaultValue;
        _selectedOptionIds
          ..clear()
          ..addAll(['lowercase', 'uppercase', 'numbers']);
      });
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      setState(() => _loadingOptions = false);
    }
  }

  Future<void> _handleGenerate() async {
    if (_selectedOptionIds.isEmpty) {
      setState(() {
        _generateError = 'Marque pelo menos um tipo de caractere.';
        _generatedPassword = null;
      });
      return;
    }

    setState(() {
      _generating = true;
      _generateError = null;
    });

    try {
      final password = await _api.generatePassword(
        length: _length,
        selectedOptionIds: _selectedOptionIds,
      );
      setState(() => _generatedPassword = password);
    } catch (e) {
      setState(() {
        _generateError = e.toString();
        _generatedPassword = null;
      });
    } finally {
      setState(() => _generating = false);
    }
  }

  void _copyToClipboard() {
    if (_generatedPassword == null) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha copiada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _loadingOptions
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : _loadError != null
              ? _buildLoadErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 40, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Não foi possível conectar à API.\n$_loadError',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _loadCharacterSets, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text('Gerador de senha', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Crie senhas fortes para suas contas',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          if (_generatedPassword != null) _buildPasswordDisplay(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tamanho', style: AppTheme.fieldLabel),
              Text('$_length', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(
            value: _length.toDouble(),
            min: _minLength.toDouble(),
            max: _maxLength.toDouble(),
            divisions: _maxLength - _minLength,
            onChanged: (value) => setState(() => _length = value.round()),
          ),
          const SizedBox(height: 8),
          const Text('Tipos de caracteres', style: AppTheme.fieldLabel),
          const SizedBox(height: 4),
          ..._availableOptions.map(
            (option) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(option.label, style: const TextStyle(fontSize: 14)),
              value: _selectedOptionIds.contains(option.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedOptionIds.add(option.id);
                  } else {
                    _selectedOptionIds.remove(option.id);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          if (_generateError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _generateError!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _generating ? null : _handleGenerate,
            child: _generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text('GERAR SENHA'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPasswordDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
        color: AppTheme.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              _generatedPassword!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16, letterSpacing: 0.5),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 20, color: AppTheme.textSecondary),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}
