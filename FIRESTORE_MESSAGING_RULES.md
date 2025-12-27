# 🔥 Règles Firestore pour la Messagerie

## Instructions

Allez dans **Firebase Console** → **Firestore Database** → **Règles** et ajoutez ces règles :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Règle de base pour l'authentification
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Règle pour vérifier si l'utilisateur est le propriétaire
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn();
      allow delete: if isSignedIn();
    }
    
    // Conversations collection - NOUVEAU
    match /conversations/{conversationId} {
      // Peut lire si l'utilisateur est participant
      allow read: if isSignedIn() && 
        request.auth.uid in resource.data.participants;
      
      // Peut créer si l'utilisateur est dans les participants
      allow create: if isSignedIn() && 
        request.auth.uid in request.resource.data.participants;
      
      // Peut mettre à jour si l'utilisateur est participant
      allow update: if isSignedIn() && 
        request.auth.uid in resource.data.participants;
    }
    
    // Messages collection - NOUVEAU
    match /messages/{messageId} {
      // Peut lire si l'utilisateur est l'expéditeur ou le destinataire
      allow read: if isSignedIn() && 
        (request.auth.uid == resource.data.senderId || 
         request.auth.uid == resource.data.receiverId);
      
      // Peut créer si l'utilisateur est l'expéditeur
      allow create: if isSignedIn() && 
        request.auth.uid == request.resource.data.senderId;
      
      // Peut mettre à jour seulement le champ isRead si c'est le destinataire
      allow update: if isSignedIn() && 
        request.auth.uid == resource.data.receiverId &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isRead']);
    }
  }
}
```

## 🔥 Règles Firebase Storage

Allez dans **Firebase Console** → **Storage** → **Règles** et ajoutez :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Règles pour les images de chat
    match /chat_images/{conversationId}/{fileName} {
      // Peut lire si authentifié
      allow read: if request.auth != null;
      
      // Peut écrire si authentifié et taille < 10MB et type image
      allow write: if request.auth != null &&
        request.resource.size < 10 * 1024 * 1024 && // Max 10MB
        request.resource.contentType.matches('image/.*');
    }
    
    // Règles pour les documents de chat
    match /chat_documents/{conversationId}/{fileName} {
      // Peut lire si authentifié
      allow read: if request.auth != null;
      
      // Peut écrire si authentifié, taille < 20MB et type autorisé
      allow write: if request.auth != null &&
        request.resource.size < 20 * 1024 * 1024 && // Max 20MB
        (request.resource.contentType.matches('application/pdf') ||
         request.resource.contentType.matches('application/msword') ||
         request.resource.contentType.matches('application/vnd.openxmlformats-officedocument.wordprocessingml.document') ||
         request.resource.contentType.matches('image/.*'));
    }
    
    // Règles existantes pour d'autres fichiers
    match /profile_pictures/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /medical_documents/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## ✅ Checklist de configuration

### 1. Firestore Rules
- [ ] Copier les règles Firestore ci-dessus
- [ ] Aller dans Firebase Console → Firestore Database → Règles
- [ ] Coller et publier

### 2. Storage Rules
- [ ] Copier les règles Storage ci-dessus
- [ ] Aller dans Firebase Console → Storage → Règles
- [ ] Coller et publier

### 3. Index Firestore
```bash
cd /Users/apple/doctolo
firebase deploy --only firestore:indexes --project doctolo
```

### 4. Test des règles

#### Test Conversation
```javascript
// Dans Firebase Console → Firestore → Règles → Simulateur
Operation: get
Path: /conversations/test123
Auth: Authenticated as user123

// Données simulées
{
  "participants": ["user123", "user456"]
}
// Résultat attendu: ✅ Autorisé
```

#### Test Message
```javascript
// Dans Firebase Console → Firestore → Règles → Simulateur
Operation: create
Path: /messages/msg123
Auth: Authenticated as user123

// Données simulées
{
  "senderId": "user123",
  "receiverId": "user456",
  "content": "Hello"
}
// Résultat attendu: ✅ Autorisé
```

## 🔒 Sécurité

Ces règles garantissent que :

1. ✅ Seuls les participants peuvent voir leurs conversations
2. ✅ Seuls expéditeur et destinataire peuvent voir les messages
3. ✅ Les utilisateurs ne peuvent pas se faire passer pour d'autres
4. ✅ Les fichiers uploadés respectent les limites de taille
5. ✅ Seuls les types de fichiers autorisés peuvent être uploadés
6. ✅ Le champ `isRead` ne peut être modifié que par le destinataire

## ⚠️ Important

- **Ne pas** publier les règles en mode test (allow read, write: if true)
- **Toujours** tester les règles avant de publier en production
- **Surveiller** les logs Firebase pour les violations de règles
- **Réviser** régulièrement les règles de sécurité

## 📝 Notes

- Les règles Firestore s'appliquent au niveau du document
- Les règles Storage s'appliquent au niveau du fichier
- Les règles sont évaluées de haut en bas
- Une règle "allow" suffit pour autoriser l'accès
- Toutes les règles doivent être "deny" pour refuser l'accès
