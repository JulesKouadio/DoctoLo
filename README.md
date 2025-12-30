# 🏥 DoctoLo - Plateforme Médicale

Application Flutter de gestion médicale pour patients et professionnels de santé.

---

## 📱 Fonctionnalités

### Patients
- Recherche de médecins (spécialité, localisation, note)
- Réservation de rendez-vous en ligne
- Téléconsultation vidéo
- Messagerie sécurisée avec les médecins
- Dossier médical personnel
- Pharmacies de garde avec GPS

### Médecins
- Gestion d'agenda intelligent
- Base de données patients
- Téléconsultation intégrée
- Ordonnances numériques
- Messagerie sécurisée
- Statistiques

---

## 🏗️ Architecture

### Stack Technique
- **Frontend**: Flutter 3.10+ (iOS, Android, Web, Desktop)
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **State Management**: flutter_bloc
- **Cache Local**: Hive
- **Téléconsultation**: Agora RTC
- **Paiements**: Stripe

### Structure du Projet

```
lib/
├── core/
│   ├── constants/      # Constantes globales
│   ├── theme/          # Thème et couleurs
│   ├── utils/          # Utilitaires (responsive, size_config)
│   ├── services/       # Services (Firebase, Hive, Sync)
│   ├── l10n/           # Internationalisation
│   └── routes/         # Navigation
├── data/
│   ├── models/         # Modèles de données (UserModel, etc.)
│   ├── repositories/   # Repositories
│   └── datasources/    # Sources de données
├── features/
│   ├── auth/           # Authentification (login, register)
│   ├── patient/        # Pages patient
│   ├── doctor/         # Pages médecin
│   ├── appointment/    # Rendez-vous
│   ├── messages/       # Messagerie
│   ├── pharmacy/       # Pharmacies de garde
│   └── settings/       # Paramètres
└── shared/
    └── widgets/        # Composants réutilisables
```

---

## 🔄 Architecture Hybride (Hive + Firebase)

### Principe
- **Lecture**: Hive (local) en priorité → Firebase si absent
- **Écriture**: Hive immédiat + Firebase async
- **Sync**: Listeners Firebase temps réel

### Flux
```
User Action → Hive (cache) → Firebase (sync) → Listeners → Autres appareils
```

---

## 📐 Responsive Design

L'app est responsive sur tous les écrans :

| Type    | Largeur      | Layout                    |
|---------|--------------|---------------------------|
| Mobile  | < 600px      | BottomNavigationBar       |
| Tablet  | 600-1024px   | NavigationRail + Contenu  |
| Desktop | > 1024px     | NavigationRail large      |

### Utilitaires (`lib/core/utils/responsive.dart`)
```dart
// Extensions
context.isMobile   // < 600px
context.isTablet   // 600-1024px
context.isDesktop  // > 1024px

// Widgets adaptatifs
showAdaptiveSheet()       // BottomSheet mobile, Dialog desktop
showAdaptiveSimpleSheet() // Version simple
```

---

## 🔥 Configuration Firebase

### Collections Firestore
```
/users/{userId}           - Données utilisateur
/doctors/{doctorId}       - Profil médecin
/appointments/{id}        - Rendez-vous
/conversations/{id}       - Conversations
/messages/{id}            - Messages
/pharmacies/{id}          - Pharmacies de garde
/notifications/{id}       - Notifications
```

### Règles de Sécurité (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /appointments/{id} {
      allow read, write: if request.auth != null;
    }
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Installation

### Prérequis
- Flutter SDK 3.10+
- Compte Firebase
- Compte Agora (téléconsultation)

### Étapes

```bash
# 1. Cloner le repo
git clone https://github.com/JulesKouadio/DoctoLo.git
cd doctolo

# 2. Installer les dépendances
flutter pub get

# 3. Générer les fichiers Hive
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Lancer l'application
flutter run
```

### Configuration API Keys

Créer/modifier `lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  static const String agoraAppId = 'VOTRE_AGORA_APP_ID';
  static const String stripePublishableKey = 'VOTRE_STRIPE_KEY';
  static const String googleMapsApiKey = 'VOTRE_GOOGLE_MAPS_KEY';
}
```

### Configuration Firebase
1. Créer un projet sur [Firebase Console](https://console.firebase.google.com)
2. Activer Authentication (Email/Password)
3. Activer Firestore Database
4. Activer Storage
5. Télécharger les fichiers de config:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

---

## 📦 Packages Principaux

| Catégorie        | Package                    | Usage                    |
|------------------|----------------------------|--------------------------|
| State            | flutter_bloc               | Gestion d'état           |
| Database         | hive, cloud_firestore      | Local + Cloud            |
| Auth             | firebase_auth              | Authentification         |
| Notifications    | firebase_messaging         | Push notifications       |
| Maps             | google_maps_flutter        | Cartes                   |
| Video            | agora_rtc_engine           | Téléconsultation         |
| Payments         | flutter_stripe             | Paiements                |
| Files            | image_picker, file_picker  | Upload fichiers          |
| PDF              | pdf, printing              | Ordonnances              |

---

## 🎨 Design System

### Couleurs
```dart
Primary:   #2E7D8F  // Bleu médical
Secondary: #4CAF50  // Vert santé
Accent:    #00BCD4  // Cyan
Success:   #4CAF50
Warning:   #FF9800
Error:     #F44336
```

### Typographie
Police: **Poppins** (Regular, Medium, SemiBold, Bold)

---

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage
```

---

## 📱 Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web

# macOS
flutter build macos
```

---

## 📄 Licence

MIT License - Voir fichier LICENSE

---

**Développé avec ❤️ en Flutter**
