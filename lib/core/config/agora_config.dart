

/// IMPORTANT: Ne committez JAMAIS votre App ID dans un repo public!
/// Utilisez des variables d'environnement en production.
class AgoraConfig {
  static const String appId = "6cb217a0c33941fdb297e7b9b0f974d2";

  // Token server URL (optionnel, pour la production avec sécurité renforcée)
  // Si null, utilise le mode sans token (OK pour le développement uniquement)
  static const String? tokenServerUrl = null;

  // Durée de validité du token en secondes (si tokenServerUrl est configuré)
  static const int tokenExpirationTime = 3600; // 1 heure

  /// Vérifie si Agora est correctement configuré
  static bool get isConfigured =>
      appId != "6cb217a0c33941fdb297e7b9b0f974d2" && appId.isNotEmpty;

  /// Retourne un message d'erreur si la configuration est invalide
  static String? get configErrorMessage {
    if (!isConfigured) {
      return 'Agora App ID non configuré. Veuillez modifier lib/core/config/agora_config.dart';
    }
    return null;
  }
}
