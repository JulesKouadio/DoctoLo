# Guide de Configuration Firebase

## Erreur: `internal-error` lors de l'inscription

Cette erreur se produit généralement car **Firebase Authentication n'est pas activée** dans votre console Firebase.

## ✅ Solution: Activer Authentication dans Firebase Console

### Étape 1: Accéder à Firebase Console
1. Allez sur https://console.firebase.google.com
2. Sélectionnez votre projet **"doctolo"**

### Étape 2: Activer Authentication
1. Dans le menu de gauche, cliquez sur **"Authentication"** (🔐)
2. Cliquez sur **"Get Started"** si c'est votre première fois
3. Allez dans l'onglet **"Sign-in method"**

### Étape 3: Activer Email/Password
1. Cherchez **"Email/Password"** dans la liste des fournisseurs
2. Cliquez dessus pour l'éditer
3. **Activez** le toggle "Enable"
4. Cliquez sur **"Save"**

### Étape 4: Configurer Firestore (si pas encore fait)
1. Dans le menu de gauche, cliquez sur **"Firestore Database"**
2. Cliquez sur **"Create database"**
3. Choisissez **"Start in test mode"** (pour le développement)
4. Sélectionnez une région (par exemple: `europe-west1`)
5. Cliquez sur **"Enable"**

### Étape 5: Règles Firestore (Important!)
Dans l'onglet **"Rules"** de Firestore, assurez-vous d'avoir ces règles pour le développement:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour les utilisateurs
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Règles pour les rendez-vous
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null;
    }
    
    // Règles pour les autres collections
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Étape 6: Configurer Storage (optionnel)
1. Dans le menu de gauche, cliquez sur **"Storage"**
2. Cliquez sur **"Get Started"**
3. Suivez les étapes de configuration

## 🔍 Vérification

Après avoir activé Authentication:

1. Relancez l'application Flutter
2. Essayez de créer un compte
3. Vérifiez les logs pour voir si l'erreur persiste

## 📱 Tester l'inscription

Utilisez ces données de test:
- Email: test@example.com
- Mot de passe: Test123456
- Prénom: Test
- Nom: User

## ⚠️ Problèmes courants

### Erreur: "internal-error"
→ Authentication Email/Password pas activée

### Erreur: "permission-denied" 
→ Règles Firestore trop restrictives

### Erreur: "network-request-failed"
→ Problème de connexion internet ou Firebase inaccessible

## 📧 Support

Si l'erreur persiste après avoir suivi ces étapes, vérifiez:
1. Que votre projet Firebase est bien sélectionné
2. Que vous avez les permissions administrateur sur le projet
3. Les logs complets dans la console Flutter
