import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/password_option.dart';

class PasswordApiException implements Exception {
  final String message;
  PasswordApiException(this.message);

  @override
  String toString() => message;
}

class PasswordApiService {

  final String baseUrl;

  PasswordApiService({required this.baseUrl});

  Future<CharacterSetsResponse> fetchCharacterSets() async {
    final uri = Uri.parse('$baseUrl/api/character-sets');

    final response = await http.get(uri).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode != 200) {
      throw PasswordApiException(
        'Não foi possível carregar as opções (status ${response.statusCode}).',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return CharacterSetsResponse.fromJson(data);
  }

  Future<String> generatePassword({
    required int length,
    required Set<String> selectedOptionIds,
    String customCharacters = '',
    bool excludeAmbiguous = false,
    bool excludeDuplicates = false,
  }) async {
    final uri = Uri.parse('$baseUrl/api/generate');

    final body = {
      'length': length,
      'lowercase': selectedOptionIds.contains('lowercase'),
      'uppercase': selectedOptionIds.contains('uppercase'),
      'numbers': selectedOptionIds.contains('numbers'),
      'symbols': selectedOptionIds.contains('symbols'),
      'spaces': selectedOptionIds.contains('spaces'),
      'customCharacters': customCharacters,
      'excludeAmbiguous': excludeAmbiguous,
      'excludeDuplicates': excludeDuplicates,
    };

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw PasswordApiException(
        data['error'] as String? ?? 'Erro desconhecido ao gerar a senha.',
      );
    }

    return data['password'] as String;
  }
}
