# Configuration des Règles Firestore

## Problème
L'inscription se bloque à l'étape "Saving user profile to Firestore" car les règles Firestore bloquent l'écriture.

## Solution: Configurer les Règles Firestore

### Étape 1: Accéder aux Règles
1. Allez sur https://console.firebase.google.com/project/doctolo
2. Cliquez sur **"Firestore Database"** dans le menu de gauche
3. Cliquez sur l'onglet **"Rules"**

### Étape 2: Copier les Règles de Développement

Remplacez le contenu par ces règles:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Règles pour les utilisateurs
    match /users/{userId} {
      // Permettre la création lors de l'inscription
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Permettre la lecture de son propre profil
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Permettre la mise à jour de son propre profil
      allow update: if request.auth != null && request.auth.uid == userId;
      
      // Interdire la suppression
      allow delete: if false;
    }
    
    // Règles pour les rendez-vous
    match /appointments/{appointmentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }
    
    // Règles pour les dossiers médicaux
    match /medical_records/{recordId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }
    
    // Bloquer tout le reste
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Étape 3: Publier les Règles
1. Cliquez sur le bouton **"Publish"** en haut de la page
2. Confirmez la publication

### Étape 4: Tester
1. Retournez dans l'app Flutter
2. Hot reload avec `r` dans le terminal
3. Réessayez l'inscription

## Règles Temporaires pour Tests (Plus Permissives)

Si vous voulez juste tester rapidement, utilisez ces règles (⚠️ DÉVELOPPEMENT SEULEMENT):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Ces règles permettent à tout utilisateur authentifié de lire/écrire partout.**

## Vérification

Après avoir publié les règles, l'inscription devrait:
1. ✅ Créer le compte Firebase Auth
2. ✅ Sauvegarder le profil dans Firestore (ne devrait plus bloquer)
3. ✅ Sauvegarder localement dans Hive
4. ✅ Envoyer l'email de vérification
5. ✅ Rediriger vers la page d'accueil

## En cas de Problème

Si ça bloque toujours:
1. Vérifiez les logs Flutter pour voir l'erreur exacte
2. Vérifiez que Firestore Database est bien créé (pas juste les règles)
3. Essayez de créer un document manuellement dans la console Firestore
