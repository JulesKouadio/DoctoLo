import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Widget helper pour simplifier l'utilisation des traductions
///
/// Usage: Tr('hello') au lieu de Text(AppLocalizations.of(context)!.hello)
///
/// Exemple:
/// ```dart
/// Tr('welcome')
/// Tr('save', style: TextStyle(fontWeight: FontWeight.bold))
/// ```
class Tr extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const Tr(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Utiliser la méthode translate pour obtenir le texte
    final text = l10n.translate(translationKey);

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Extension pour faciliter l'accès aux traductions
extension TranslationExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this)!;

  String t(String key) => AppLocalizations.of(this)!.translate(key);
}
