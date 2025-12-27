# 📚 Documentation Technique - Doctolo

## 🏗️ Architecture

### Vue d'Ensemble

Doctolo utilise une **Clean Architecture** avec séparation claire des responsabilités:

```
┌─────────────────────────────────────────────┐
│           Presentation Layer                │
│  (UI, Pages, Widgets, BLoC/Cubit)          │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│           Domain Layer                      │
│  (Business Logic, Use Cases, Entities)     │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│           Data Layer                        │
│  (Repositories, Data Sources, Models)      │
└─────────────────────────────────────────────┘
```

### Flux de Données

```
User Interaction (UI)
    ↓
BLoC/Cubit (State Management)
    ↓
Repository (Data Abstraction)
    ↓
    ├─→ Hive Service (Local - Cache)
    └─→ Firebase Service (Remote - Source of Truth)
```

## 🔄 Synchronisation Hybride Hive ↔️ Firebase

### Principe

L'architecture hybride garantit:
- ✅ **Performance**: Lecture prioritaire depuis Hive (local)
- ✅ **Offline-First**: Fonctionnement sans connexion
- ✅ **Sync Automatique**: Synchronisation temps réel avec Firebase
- ✅ **Source de Vérité**: Firebase comme master database

### Flux de Synchronisation

#### 1. Inscription Utilisateur
```dart
Utilisateur s'inscrit
    ↓
Firebase Auth (création compte)
    ↓
Firestore (sauvegarde données utilisateur)
    ↓
Listener Firebase (détecte le nouveau user)
    ↓
Hive (synchronisation locale automatique)
```

#### 2. Modification de Données
```dart
Utilisateur modifie ses données
    ↓
Hive (sauvegarde locale immédiate) ← Performance
    ↓
Firebase (synchronisation async) ← Backup
    ↓
Listener Firebase (propage aux autres appareils)
```

#### 3. Lecture de Données
```dart
App lance une requête
    ↓
Vérifie Hive d'abord (cache)
    │
    ├─→ Données présentes → Retour immédiat
    │
    └─→ Données absentes → Fetch Firebase
            ↓
        Sauvegarde dans Hive
            ↓
        Retour des données
```

## 🧩 Structure des Modèles

### UserModel

```dart
@HiveType(typeId: 0)
class UserModel {
  final String id;              // Firebase UID
  final String email;
  final String firstName;
  final String lastName;
  final String role;            // 'patient' | 'doctor'
  final DateTime createdAt;
  final bool isVerified;
  
  // Méthodes
  String get fullName => '$firstName $lastName';
  Map<String, dynamic> toJson();
  factory UserModel.fromJson(Map<String, dynamic> json);
}
```

### AppointmentModel

```dart
@HiveType(typeId: 2)
class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final String status;          // 'pending' | 'confirmed' | 'cancelled'
  final double fee;
  final bool isTelemedicine;
  
  // Computed properties
  bool get isUpcoming;
  bool get canCancel;
}
```

## 🎯 BLoC Pattern

### Structure d'un BLoC

```dart
// 1. Events (actions utilisateur)
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}

// 2. States (états de l'UI)
abstract class AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
}

// 3. BLoC (logique business)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onLoginRequested(event, emit) async {
    emit(AuthLoading());
    // Logique de connexion
    emit(AuthAuthenticated(user: user));
  }
}
```

### Utilisation dans l'UI

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    if (state is AuthAuthenticated) {
      return HomePage(user: state.user);
    }
    return LoginPage();
  },
)
```

## 🔐 Authentification

### Flux d'Authentification

```dart
1. User entre email/password
2. AuthBloc reçoit LoginRequested
3. Firebase Auth vérifie les credentials
4. Si succès:
   - Récupère les données user depuis Firestore
   - Sauvegarde dans Hive
   - Initialise les listeners de sync
   - Émet AuthAuthenticated
5. UI redirige vers HomePage
```

### Gestion des Sessions

```dart
// Au démarrage de l'app
AuthBloc checks:
  1. Firebase Auth: user connecté?
  2. Hive: données user en cache?
  3. Si les deux OK → Auto-login
  4. Sinon → Affiche LoginPage
```

## 🔥 Firebase Structure

### Collections Firestore

```
/users/{userId}
  - email: string
  - firstName: string
  - lastName: string
  - role: string
  - createdAt: timestamp

/doctors/{doctorId}
  - userId: string (ref)
  - specialty: string
  - rating: number
  - consultationFee: number
  - availability: map

/appointments/{appointmentId}
  - patientId: string (ref)
  - doctorId: string (ref)
  - dateTime: timestamp
  - status: string
  - fee: number
```

### Règles de Sécurité

```javascript
// Exemple: Appointments
match /appointments/{appointmentId} {
  allow read: if request.auth.uid == resource.data.patientId 
              || request.auth.uid == resource.data.doctorId;
  
  allow create: if request.auth != null;
  
  allow update: if request.auth.uid == resource.data.patientId 
                || request.auth.uid == resource.data.doctorId;
}
```

## 🎨 Theming

### Couleurs

```dart
AppColors.primary      // #2E7D8F - Bleu médical
AppColors.secondary    // #4CAF50 - Vert santé
AppColors.accent       // #00BCD4 - Cyan
AppColors.success      // #4CAF50
AppColors.warning      // #FF9800
AppColors.error        // #F44336
```

### Typography

```dart
// Headings
displayLarge   // 32px, Bold
displayMedium  // 28px, Bold
displaySmall   // 24px, SemiBold

// Body
bodyLarge      // 16px, Regular
bodyMedium     // 14px, Regular
bodySmall      // 12px, Regular
```

## 📱 Navigation

### Routes Principales

```dart
/                       → AuthWrapper (vérifie auth)
/login                  → LoginPage
/register               → RegisterPage
/patient/home           → PatientHomePage
/doctor/home            → DoctorHomePage
/appointment/book       → BookAppointmentPage
/teleconsultation       → TeleconsultationPage
```

## 🧪 Tests

### Tests Unitaires

```dart
// test/unit/auth_bloc_test.dart
test('Login with valid credentials should emit AuthAuthenticated', () {
  // Arrange
  final authBloc = AuthBloc();
  
  // Act
  authBloc.add(LoginRequested(
    email: 'test@test.com',
    password: 'password123'
  ));
  
  // Assert
  expectLater(
    authBloc.stream,
    emitsInOrder([
      isA<AuthLoading>(),
      isA<AuthAuthenticated>(),
    ])
  );
});
```

### Tests Widget

```dart
testWidgets('LoginPage shows email and password fields', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Mot de passe'), findsOneWidget);
});
```

## 🚀 Performance

### Optimisations

1. **Images**: Utiliser `cached_network_image`
2. **Listes**: Utiliser `ListView.builder` pour grandes listes
3. **State**: Minimiser les rebuilds avec `const` widgets
4. **Hive**: Index les champs fréquemment recherchés
5. **Firebase**: Utiliser `limit()` pour les queries

### Monitoring

```dart
// Firebase Performance
final trace = FirebasePerformance.instance.newTrace('load_doctors');
await trace.start();
// ... opération
await trace.stop();
```

## 🔧 Debugging

### Logs Structurés

```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error, stackTrace);
```

### Flutter DevTools

```bash
# Lancer DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 📦 Build & Release

### Android

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🔄 CI/CD (à implémenter)

### GitHub Actions

```yaml
name: Build & Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk
```

## 📚 Ressources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [BLoC Library](https://bloclibrary.dev)
- [Hive Documentation](https://docs.hivedb.dev)

---

**Dernière mise à jour**: Décembre 2025
