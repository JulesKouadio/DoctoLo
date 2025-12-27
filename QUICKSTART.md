# 🚀 Guide de Démarrage Rapide - Doctolo

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé:

- ✅ [Flutter SDK 3.10.3+](https://flutter.dev/docs/get-started/install)
- ✅ [Git](https://git-scm.com/downloads)
- ✅ [Android Studio](https://developer.android.com/studio) ou [Xcode](https://developer.apple.com/xcode/) (selon votre plateforme)
- ✅ Un éditeur de code ([VS Code](https://code.visualstudio.com/) recommandé avec l'extension Flutter)

## 🔧 Installation Étape par Étape

### 1️⃣ Cloner le Projet

```bash
git clone https://github.com/votre-username/doctolo.git
cd doctolo
```

### 2️⃣ Installer les Dépendances

```bash
flutter pub get
```

**Remarque**: Ignorez les erreurs de build_runner pour l'instant, nous les résoudrons après.

### 3️⃣ Configuration Firebase

#### A. Créer un Projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Cliquez sur "Ajouter un projet"
3. Nommez votre projet: `doctolo` (ou votre nom préféré)
4. Activez Google Analytics (recommandé)
5. Choisissez la région **Europe** pour la conformité RGPD

#### B. Ajouter l'App Android

1. Dans Firebase Console, cliquez sur l'icône Android
2. Nom du package: `com.doctolo.app` (ou modifiez dans `android/app/build.gradle`)
3. Téléchargez `google-services.json`
4. Placez le fichier dans: `android/app/google-services.json`

#### C. Ajouter l'App iOS (si nécessaire)

1. Cliquez sur l'icône iOS dans Firebase Console
2. Bundle ID: `com.doctolo.app` (ou modifiez dans Xcode)
3. Téléchargez `GoogleService-Info.plist`
4. Placez le fichier dans: `ios/Runner/GoogleService-Info.plist`

#### D. Activer les Services Firebase

Dans Firebase Console:

**Authentication:**
- Allez dans `Authentication` > `Sign-in method`
- Activez `Email/Password` ✅

**Firestore Database:**
- Allez dans `Firestore Database`
- Créez une base de données
- Choisissez la région: `europe-west1` (Paris) ou `eur3` (Frankfurt)
- Mode de démarrage: `Production`

**Storage:**
- Allez dans `Storage`
- Commencer en mode test (nous ajouterons les règles plus tard)

**Cloud Messaging:**
- Activez Firebase Cloud Messaging (automatique avec la configuration)

### 4️⃣ Configuration des API Keys

Ouvrez `lib/core/constants/app_constants.dart` et remplacez:

```dart
// Agora (pour la téléconsultation)
static const String agoraAppId = 'VOTRE_AGORA_APP_ID';
// Obtenez-le sur: https://www.agora.io

// Stripe (pour les paiements)
static const String stripePublishableKey = 'VOTRE_STRIPE_PUBLISHABLE_KEY';
// Obtenez-le sur: https://dashboard.stripe.com/apikeys

// Google Maps (pour les pharmacies)
static const String googleMapsApiKey = 'VOTRE_GOOGLE_MAPS_API_KEY';
// Obtenez-le sur: https://console.cloud.google.com
```

**Note**: Pour tester l'app sans ces services, vous pouvez laisser les valeurs par défaut (certaines fonctionnalités ne marcheront pas).

### 5️⃣ Générer les Fichiers de Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Cette commande génère les adaptateurs Hive nécessaires pour la base de données locale.

### 6️⃣ Lancer l'Application

#### Sur Émulateur/Simulateur

```bash
# Liste les appareils disponibles
flutter devices

# Lance sur l'appareil connecté
flutter run
```

#### Sur Appareil Physique

**Android:**
1. Activez les options développeur sur votre téléphone
2. Activez le débogage USB
3. Connectez le téléphone via USB
4. Exécutez `flutter run`

**iOS:**
1. Ouvrez Xcode
2. Configurez votre certificat de développement
3. Sélectionnez votre appareil
4. Exécutez `flutter run`

## 🎯 Premier Test

### Créer un Compte

1. Lancez l'app
2. Cliquez sur "Créer un compte"
3. Choisissez "Patient" ou "Professionnel"
4. Remplissez le formulaire:
   - Email: `test@doctolo.com`
   - Mot de passe: `test123456`
   - Prénom: `Test`
   - Nom: `User`
5. Acceptez les conditions
6. Cliquez sur "S'inscrire"

### Se Connecter

Utilisez les identifiants que vous venez de créer.

## 🐛 Résolution des Problèmes Courants

### Erreur: "No Firebase App"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Erreur: "MissingPluginException"

**Solution:**
```bash
flutter pub get
# Sur iOS, exécutez aussi:
cd ios && pod install && cd ..
flutter run
```

### Erreur de Build Runner

**Solution:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur: "Gradle build failed" (Android)

**Solution:**
1. Ouvrez `android/app/build.gradle`
2. Vérifiez que `minSdkVersion` est au moins 21
3. Nettoyez et rebuilder:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### Erreur de Pod Install (iOS)

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## 📱 Structure de Test

### Compte Patient Test

- Email: `patient@test.com`
- Mot de passe: `test123456`
- Rôle: Patient

### Compte Médecin Test

- Email: `doctor@test.com`
- Mot de passe: `test123456`
- Rôle: Professionnel

## 🔑 API Keys Optionnelles (pour plus tard)

### Agora (Téléconsultation)
1. Allez sur [Agora.io](https://www.agora.io)
2. Créez un compte gratuit
3. Créez un projet
4. Copiez l'App ID

### Stripe (Paiements)
1. Allez sur [Stripe Dashboard](https://dashboard.stripe.com)
2. Créez un compte
3. Mode Test: récupérez la clé publique de test
4. Plus tard, passez en mode Live

### Google Maps (Pharmacies)
1. Allez sur [Google Cloud Console](https://console.cloud.google.com)
2. Créez un projet
3. Activez Maps SDK for Android/iOS
4. Créez une clé API
5. Ajoutez des restrictions (optionnel)

## 📚 Prochaines Étapes

Une fois l'app lancée avec succès:

1. ✅ Explorez l'interface patient/médecin
2. ✅ Testez la création de rendez-vous (en développement)
3. ✅ Consultez le code source dans `lib/`
4. ✅ Lisez la documentation complète dans `README.md`
5. ✅ Contribuez au projet! 🎉

## 💡 Conseils

- Utilisez **VS Code** avec les extensions Flutter et Dart pour une meilleure expérience
- Activez **Hot Reload** (R) pour voir vos modifications instantanément
- Consultez les logs avec `flutter logs` pour déboguer
- Utilisez **Flutter DevTools** pour le profiling

## 🆘 Besoin d'Aide?

- 📖 [Documentation Flutter](https://flutter.dev/docs)
- 🔥 [Documentation Firebase](https://firebase.google.com/docs)
- 💬 Ouvrez une issue sur GitHub
- 📧 Contactez-nous: support@doctolo.com

---

**Félicitations! Vous êtes prêt à développer Doctolo! 🎉**
