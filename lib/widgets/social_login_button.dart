import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Botão de "Entrar com Google/Apple" apenas ilustrativo — como pedido,
/// sem autenticação real. Ao tocar, mostra um aviso rápido explicando isso.
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const SocialLoginButton({super.key, required this.icon, required this.label});

  void _showExampleNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Este é apenas um botão de exemplo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showExampleNotice(context),
      icon: Icon(icon, size: 20, color: AppTheme.textPrimary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPrimary,
      ),
    );
  }
}
