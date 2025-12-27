# Système de Vérification d'Email - Doctolo

## 🎯 Fonctionnement

### 1. À l'inscription
- L'utilisateur crée son compte avec email/password
- **Automatiquement**, Firebase Auth envoie un email de vérification
- L'utilisateur est redirigé vers la page de vérification d'email

### 2. Réception de l'email
L'utilisateur reçoit un email de Firebase contenant :
- Un lien de vérification unique
- Des instructions

### 3. Clic sur le lien
Quand l'utilisateur clique sur le lien dans l'email :
- **Firebase vérifie automatiquement l'email** côté serveur
- Le statut `emailVerified` de Firebase Auth passe à `true`
- **Aucune action manuelle requise** - tout est géré par Firebase

### 4. Mise à jour dans l'application

#### À la connexion suivante :
```dart
// Le système vérifie automatiquement
await userCredential.user!.reload();
final isEmailVerified = updatedFirebaseUser?.emailVerified ?? false;

// Si vérifié, mise à jour Firestore
if (isEmailVerified && !currentIsVerified) {
  await _firebaseService.updateDocument('users', user.id, {
    'isVerified': true,
  });
}
```

#### Sur la page de vérification :
- Vérification automatique toutes les 3 secondes
- Bouton "Vérifier maintenant" pour vérification manuelle
- Bouton "Renvoyer l'email" (limité à 1x/minute)

## 📱 Pages et Composants

### EmailVerificationPage
**Chemin**: `lib/features/auth/presentation/pages/email_verification_page.dart`

**Fonctionnalités**:
- ✅ Vérification automatique périodique (toutes les 3s)
- ✅ Vérification manuelle sur demande
- ✅ Renvoi d'email avec cooldown de 60s
- ✅ Instructions claires pour l'utilisateur
- ✅ Feedback visuel (loading, statuts)
- ✅ Navigation automatique après vérification réussie

### Modifications AuthBloc

**Nouveaux événements**:
- `AuthEmailVerificationRequested` - Envoie un email de vérification
- `AuthCheckEmailVerificationRequested` - Vérifie si l'email a été vérifié

**Nouveaux états**:
- `AuthEmailVerificationSent` - Email envoyé avec succès
- `AuthEmailVerified` - Email vérifié avec succès
- `AuthEmailNotVerified` - Email non encore vérifié

## 🔄 Flux Complet

```
1. INSCRIPTION
   ↓
2. Création compte Firebase Auth
   ↓
3. Envoi automatique email vérification
   ↓
4. Affichage EmailVerificationPage
   ↓
5. Utilisateur ouvre email
   ↓
6. Utilisateur clique sur lien
   ↓
7. Firebase vérifie l'email (côté serveur)
   ↓
8. App détecte la vérification (auto ou manuelle)
   ↓
9. Mise à jour Firestore: isVerified = true
   ↓
10. Mise à jour cache local (Hive)
   ↓
11. Navigation vers HomePage
```

## 🛡️ Sécurité

### Firebase Auth gère tout
- ✅ Génération de liens sécurisés
- ✅ Expiration des liens (temps limité)
- ✅ Vérification côté serveur
- ✅ Protection contre les attaques
- ✅ Pas de manipulation possible côté client

### Synchronisation isVerified
- Firestore `isVerified` est **toujours synchronisé** avec Firebase Auth `emailVerified`
- Mise à jour automatique à chaque connexion
- Mise à jour automatique lors de la vérification
- Cache local (Hive) synchronisé avec Firestore

## 📝 Configuration

### Personnalisation de l'email (Firebase Console)

1. Aller dans Firebase Console
2. Authentication → Templates
3. Personnaliser le template "Email address verification"
4. Variables disponibles:
   - `%LINK%` - Lien de vérification
   - `%APP_NAME%` - Nom de l'app
   - `%EMAIL%` - Email de l'utilisateur

### Exemple de personnalisation
```html
Bonjour,

Merci de vous être inscrit sur Doctolo !

Pour activer votre compte, veuillez cliquer sur le lien ci-dessous :
%LINK%

Si vous n'avez pas créé de compte, ignorez cet email.

L'équipe Doctolo
```

## 🧪 Test

### Test manuel
1. Créer un nouveau compte
2. Vérifier que l'email est reçu
3. Cliquer sur le lien dans l'email
4. Vérifier que l'app détecte la vérification
5. Confirmer que `isVerified` est à `true` dans Firestore

### Points de vérification
- [ ] Email reçu dans les 30 secondes
- [ ] Lien fonctionnel
- [ ] Redirection après clic
- [ ] Détection automatique dans l'app
- [ ] `isVerified` à `true` dans Firestore
- [ ] Navigation vers la HomePage

## ⚠️ Gestion des erreurs

### Email non reçu
- Vérifier les spams
- Utiliser le bouton "Renvoyer l'email"
- Vérifier que l'email est valide

### Erreurs possibles
- `too-many-requests` : Trop de tentatives, attendre
- `user-not-found` : Utilisateur n'existe pas
- `network-error` : Problème de connexion

## 🎨 Interface Utilisateur

### EmailVerificationPage - Éléments
- 📧 Icône email avec gradient
- 📝 Instructions étape par étape
- 🔄 Indicateur de vérification automatique
- 🔵 Bouton "Vérifier maintenant"
- ✉️ Bouton "Renvoyer l'email" (avec cooldown)
- 💡 Note sur les spams

### Feedback utilisateur
- ✅ SnackBars pour succès
- ❌ SnackBars pour erreurs
- ⏳ Loading indicators
- 🔄 Compteur pour le renvoi d'email

## 🚀 Améliorations futures possibles

1. **Deep linking** : Rediriger vers l'app après clic sur le lien
2. **Notifications push** : Notifier l'utilisateur quand vérifié
3. **Analytics** : Tracker les taux de vérification
4. **Rappels** : Email de rappel si non vérifié après X jours
5. **Alternative** : Vérification par SMS en option

## 📊 Firebase Console - Vérification

Pour vérifier manuellement dans Firebase Console :
1. Authentication → Users
2. Chercher l'utilisateur
3. Colonne "Email verified" doit être ✅
4. Firestore → users → [userId] → isVerified doit être `true`
