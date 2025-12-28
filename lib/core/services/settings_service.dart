import 'package:flutter/material.dart';
import '../constants/app_settings_constants.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  // Notifiers pour réactivité dans l'UI
  final ValueNotifier<String> languageNotifier = ValueNotifier(
    AppSettingsConstants.defaultLanguage,
  );
  final ValueNotifier<CurrencyInfo> currencyNotifier = ValueNotifier(
    AppSettingsConstants.availableCurrencies[AppSettingsConstants
        .defaultCurrency]!,
  );

  /// Initialise les paramètres depuis le cache local
  Future<void> initialize() async {
    // Charger la langue
    final savedLanguage = _hiveService.getSetting(
      AppSettingsConstants.languageKey,
      defaultValue: AppSettingsConstants.defaultLanguage,
    );
    languageNotifier.value = savedLanguage;

    // Charger la devise
    final savedCurrencyCode = _hiveService.getSetting(
      AppSettingsConstants.currencyKey,
      defaultValue: AppSettingsConstants.defaultCurrency,
    );
    currencyNotifier.value =
        AppSettingsConstants.availableCurrencies[savedCurrencyCode] ??
        AppSettingsConstants.availableCurrencies[AppSettingsConstants
            .defaultCurrency]!;
  }

  /// Charge les paramètres depuis Firestore pour un utilisateur
  Future<void> loadUserSettings(String userId) async {
    try {
      final doc = await _firebaseService.getDocument('users', userId);

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Charger la langue
        if (data['preferredLanguage'] != null) {
          await setLanguage(data['preferredLanguage']);
        }

        // Charger la devise
        if (data['preferredCurrency'] != null) {
          await setCurrency(data['preferredCurrency']);
        }
      }
    } catch (e) {
      print('⚠️ Erreur chargement paramètres utilisateur: $e');
    }
  }

  /// Définit la langue de l'application
  Future<void> setLanguage(String languageCode, {String? userId}) async {
    if (!AppSettingsConstants.availableLanguages.containsKey(languageCode)) {
      print('⚠️ Langue non supportée: $languageCode');
      return;
    }

    // Mettre à jour le cache local
    await _hiveService.saveSetting(
      AppSettingsConstants.languageKey,
      languageCode,
    );
    languageNotifier.value = languageCode;

    // Mettre à jour Firestore si userId fourni
    if (userId != null) {
      try {
        await _firebaseService.updateDocument('users', userId, {
          'preferredLanguage': languageCode,
        });
      } catch (e) {
        print('⚠️ Erreur sauvegarde langue dans Firestore: $e');
      }
    }

    print('✅ Langue mise à jour: $languageCode');
  }

  /// Définit la devise de l'application
  Future<void> setCurrency(String currencyCode, {String? userId}) async {
    final currency = AppSettingsConstants.availableCurrencies[currencyCode];
    if (currency == null) {
      print('⚠️ Devise non supportée: $currencyCode');
      return;
    }

    // Mettre à jour le cache local
    await _hiveService.saveSetting(
      AppSettingsConstants.currencyKey,
      currencyCode,
    );
    currencyNotifier.value = currency;

    // Mettre à jour Firestore si userId fourni
    if (userId != null) {
      try {
        await _firebaseService.updateDocument('users', userId, {
          'preferredCurrency': currencyCode,
        });
      } catch (e) {
        print('⚠️ Erreur sauvegarde devise dans Firestore: $e');
      }
    }

    print('✅ Devise mise à jour: $currencyCode');
  }

  /// Récupère la langue actuelle
  String get currentLanguage => languageNotifier.value;

  /// Récupère la devise actuelle
  CurrencyInfo get currentCurrency => currencyNotifier.value;

  /// Formate un montant avec la devise actuelle
  String formatCurrency(double amount) {
    return currentCurrency.format(amount);
  }

  /// Obtient le nom de la langue actuelle
  String get currentLanguageName =>
      AppSettingsConstants.availableLanguages[currentLanguage] ?? 'Français';

  /// Réinitialise aux paramètres par défaut
  Future<void> resetToDefaults({String? userId}) async {
    await setLanguage(AppSettingsConstants.defaultLanguage, userId: userId);
    await setCurrency(AppSettingsConstants.defaultCurrency, userId: userId);
  }
}
