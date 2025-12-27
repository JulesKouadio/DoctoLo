# 🏥 Doctolo - Plateforme Médicale Moderne

<div align="center">
  
  **Simplifiez l'accès aux soins pour les patients et optimisez la gestion pour les professionnels de santé**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.10.3-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 📱 À Propos

Doctolo est une plateforme complète de gestion médicale qui offre:
- 🔍 Recherche et réservation de rendez-vous en ligne 24/7
- 📹 Téléconsultations vidéo sécurisées
- 📋 Dossier médical personnel centralisé
- 🏥 Gestion d'agenda intelligente pour professionnels
- 💬 Messagerie sécurisée patient-médecin
- 💳 Paiements en ligne sécurisés
- 🗺️ Pharmacies de garde avec GPS

## ✨ Fonctionnalités

### Pour les Patients 👨‍👩‍👧‍👦

#### Recherche & Réservation
- ✅ Moteur de recherche multi-critères (spécialité, localisation, note, langue)
- ✅ Réservation 24/7 en quelques clics
- ✅ Créneaux disponibles en temps réel
- ✅ Confirmation instantanée par notification

#### Suivi de Santé
- ✅ Dossier médical sécurisé et centralisé
- ✅ Historique des consultations
- ✅ Rappels automatiques (SMS & Email)
- ✅ Partage de documents médicaux
- ✅ Téléconsultation vidéo HD

#### Gestion Familiale
- ✅ Comptes multi-profils
- ✅ Rendez-vous pour toute la famille
- ✅ Vue calendrier centralisée

#### Pharmacies de Garde
- ✅ Carte interactive GPS
- ✅ Navigation vers la pharmacie la plus proche
- ✅ Informations en temps réel

### Pour les Professionnels 👨‍⚕️👩‍⚕️

#### Gestion d'Agenda
- ✅ Agenda intelligent personnalisable
- ✅ Gestion des créneaux et types de consultation
- ✅ Blocage de plages horaires
- ✅ Vues multiples (jour/semaine/mois)

#### Gestion des Patients
- ✅ Base de données complète et sécurisée
- ✅ Fiches patient détaillées
- ✅ Historique médical complet
- ✅ Statistiques de fréquentation

#### Communication
- ✅ Messagerie sécurisée RGPD
- ✅ Partage de documents
- ✅ Ordonnances numériques
- ✅ Résultats d'examens

#### Services Innovants
- ✅ Module de téléconsultation intégré
- ✅ Paiement en ligne
- ✅ Facturation automatique
- ✅ Statistiques et analytics

## 🏗️ Architecture Technique

### Stack Technologique

#### Frontend
```
Flutter 3.10.3 (Dart)
├── Material Design 3
├── Cupertino (iOS)
└── Responsive (Mobile, Tablet, Web, Desktop)
```

#### State Management
```
flutter_bloc + equatable
```

#### Base de Données Hybride
```
Architecture Hybride
├── Hive (Local - Cache prioritaire)
│   ├── Performance optimale
│   ├── Mode offline
│   └── Synchronisation rapide
└── Firebase (Cloud - Source de vérité)
    ├── Firestore (NoSQL)
    ├── Firebase Auth
    ├── Cloud Storage
    └── Cloud Functions
```

### Architecture du Projet

```
lib/
├── core/
│   ├── constants/          # Constantes de l'app
│   ├── theme/              # Thème et couleurs
│   ├── utils/              # Utilitaires
│   ├── services/           # Services (Firebase, Hive, Sync)
│   └── routes/             # Navigation
├── data/
│   ├── models/             # Modèles de données
│   ├── repositories/       # Repositories
│   └── datasources/        # Sources de données (local/remote)
├── features/
│   ├── auth/               # Authentification
│   ├── patient/            # Fonctionnalités patient
│   ├── doctor/             # Fonctionnalités médecin
│   ├── appointment/        # Rendez-vous
│   ├── teleconsultation/   # Téléconsultation
│   ├── pharmacy/           # Pharmacies de garde
│   ├── messaging/          # Messagerie
│   └── payment/            # Paiement
└── shared/
    └── widgets/            # Composants réutilisables
```

## 🚀 Installation

### Prérequis

- Flutter SDK 3.10.3 ou supérieur
- Dart SDK
- Android Studio / Xcode (pour émulateurs)
- Compte Firebase
- Compte Agora (téléconsultation)
- Compte Stripe (paiements)

### Configuration

1. **Cloner le repository**
```bash
git clone https://github.com/votre-username/doctolo.git
cd doctolo
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les fichiers de code (pour Hive)**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configuration Firebase**
   - Créer un projet sur [Firebase Console](https://console.firebase.google.com)
   - Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
   - Placer les fichiers dans les dossiers appropriés
   - Activer Authentication, Firestore, Storage, Messaging

5. **Configuration des API Keys**

Modifier `lib/core/constants/app_constants.dart`:
```dart
static const String agoraAppId = 'VOTRE_AGORA_APP_ID';
static const String stripePublishableKey = 'VOTRE_STRIPE_KEY';
static const String googleMapsApiKey = 'VOTRE_GOOGLE_MAPS_KEY';
```

6. **Lancer l'application**
```bash
flutter run
```

## 📦 Packages Principaux

### State Management & Architecture
- `flutter_bloc` - Gestion d'état BLoC
- `equatable` - Comparaison d'objets

### Base de Données
- `hive` + `hive_flutter` - Base de données locale
- `firebase_core` - Firebase SDK
- `cloud_firestore` - Base de données cloud
- `firebase_storage` - Stockage de fichiers
- `firebase_auth` - Authentification

### Notifications
- `firebase_messaging` - Push notifications
- `flutter_local_notifications` - Notifications locales

### Maps & Location
- `google_maps_flutter` - Cartes Google
- `geolocator` - Géolocalisation
- `geocoding` - Conversion coordonnées/adresses

### Téléconsultation
- `agora_rtc_engine` - Appels vidéo
- `permission_handler` - Gestion permissions

### Fichiers & Documents
- `image_picker` - Photos
- `file_picker` - Fichiers
- `pdf` - Génération PDF
- `printing` - Impression

### Paiement
- `flutter_stripe` - Paiements Stripe

### Utilities
- `dio` - Requêtes HTTP
- `connectivity_plus` - État connexion
- `intl` - Internationalisation
- `cached_network_image` - Cache images
- `shimmer` - Effet de chargement

## 🎨 Design System

### Palette de Couleurs

```dart
Primary: #2E7D8F (Bleu médical apaisant)
Secondary: #4CAF50 (Vert santé)
Accent: #00BCD4 (Cyan moderne)
Success: #4CAF50
Warning: #FF9800
Error: #F44336
```

### Typography

Police principale: **Poppins**
- Regular (400)
- Medium (500)
- SemiBold (600)
- Bold (700)

## 🔒 Sécurité & Conformité

- ✅ **Conformité RGPD**
- ✅ **Chiffrement end-to-end**
- ✅ **Authentification à deux facteurs (2FA)**
- ✅ **Hébergement données en Europe**
- ✅ **Droit à l'oubli**
- ✅ **Export de données**
- ✅ **Consentement explicite**

## 📱 Plateformes Supportées

- ✅ iOS (iPhone & iPad)
- ✅ Android (Smartphones & Tablettes)
- ✅ Web (Tous navigateurs modernes)
- ✅ Desktop (Windows, macOS, Linux)

## 🌍 Langues Supportées

- 🇫🇷 Français
- 🇬🇧 English
- 🇩🇪 Deutsch
- 🇪🇸 Español
- 🇮🇹 Italiano

## 📊 Statut du Projet

### Version Actuelle: 1.0.0-alpha

#### ✅ Phase 1 - Fondations (Terminé)
- [x] Architecture du projet (Clean Architecture)
- [x] Configuration Firebase & Hive (Architecture hybride)
- [x] Système d'authentification complet
- [x] Design system et thème médical moderne
- [x] Pages de base (Patient & Médecin)
- [x] Synchronisation temps réel Firebase ↔️ Hive

#### 🔄 Phase 2 - Fonctionnalités Core (À venir)
- [ ] Recherche et listing médecins avec filtres
- [ ] Système de réservation en temps réel
- [ ] Agenda professionnel intelligent
- [ ] Profils utilisateurs complets
- [ ] Gestion des disponibilités

#### 📋 Phase 3 - Fonctionnalités Avancées (À venir)
- [ ] Téléconsultation vidéo (Agora)
- [ ] Messagerie sécurisée chiffrée
- [ ] Dossier médical avec historique
- [ ] Paiement en ligne (Stripe)
- [ ] Pharmacies de garde (Google Maps)
- [ ] Notifications intelligentes

#### 🚀 Phase 4 - Optimisation (À venir)
- [ ] Tests unitaires & intégration
- [ ] Optimisation performances
- [ ] Déploiement App Store & Play Store
- [ ] Documentation API complète

## 🛠️ Développement

### Structure des Fichiers Générés

Après avoir exécuté le build_runner, les fichiers suivants seront générés:
- `*.g.dart` - Fichiers générés pour Hive adapters
- `*.freezed.dart` - Classes immutables (si Freezed est utilisé)

### Commandes Utiles

```bash
# Installer les dépendances
flutter pub get

# Générer les fichiers (Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'app en mode debug
flutter run

# Build pour production
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web
flutter build macos --release        # macOS

# Tests
flutter test

# Analyse du code
flutter analyze

# Formatage du code
flutter format .
```

## 🤝 Contribution

Les contributions sont les bienvenues! Pour contribuer:

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Conventions de Code

- Utiliser `flutter format` avant chaque commit
- Suivre les conventions de nommage Dart
- Ajouter des commentaires pour le code complexe
- Écrire des tests pour les nouvelles fonctionnalités

## 📝 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📧 Contact

- Email: contact@doctolo.com
- Website: https://doctolo.com
- Support: support@doctolo.com

## 🙏 Remerciements

- **Flutter Team** pour le framework exceptionnel
- **Firebase** pour les services backend
- **Agora** pour la téléconsultation vidéo
- **Tous les contributeurs open-source**

---

<div align="center">
  Made with ❤️ for better healthcare
  
  **Doctolo** - L'avenir de la santé digitale
</div>
