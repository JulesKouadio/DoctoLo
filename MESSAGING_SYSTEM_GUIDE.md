# 💬 Guide du Système de Messagerie Doctolo

## 📋 Vue d'ensemble

Le système de messagerie permet aux patients et docteurs de communiquer de manière sécurisée avec support de texte, images et documents médicaux.

## 🏗️ Architecture

### Collections Firestore

#### 1. **conversations**
```json
{
  "participants": ["patientId", "doctorId"],
  "participantsInfo": {
    "userId": {
      "id": "userId",
      "name": "Nom Complet",
      "avatar": "photoUrl",
      "role": "patient|doctor",
      "specialty": "Spécialité" // Seulement pour docteurs
    }
  },
  "lastMessage": "Dernier message texte",
  "lastMessageTime": Timestamp,
  "lastMessageType": "text|image|document|audio",
  "unreadCount": {
    "userId": 0
  },
  "createdAt": Timestamp
}
```

#### 2. **messages**
```json
{
  "conversationId": "conversationId",
  "senderId": "userId",
  "senderName": "Nom Complet",
  "senderAvatar": "photoUrl",
  "receiverId": "userId",
  "content": "Contenu du message",
  "type": "text|image|document|audio",
  "fileUrl": "https://...", // Pour images/documents
  "fileName": "nom_fichier.pdf",
  "fileSize": 1234567, // En bytes
  "timestamp": Timestamp,
  "isRead": false
}
```

## 📱 Fonctionnalités

### Pour les Patients

1. **Rechercher un docteur**
   - Recherche par nom ou spécialité
   - Voir les infos : avatar, spécialité, ville, note
   - Cliquer pour démarrer une conversation

2. **Liste des conversations**
   - Voir toutes les conversations actives
   - Badge de messages non lus
   - Aperçu du dernier message
   - Heure du dernier message

3. **Chat en temps réel**
   - Envoyer des messages texte
   - Envoyer des photos (galerie)
   - Envoyer des documents (PDF, DOC, DOCX, JPG, PNG)
   - Voir l'état de lecture (✓ = envoyé, ✓✓ = lu)
   - Télécharger/ouvrir les documents reçus

### Pour les Docteurs

1. **Liste des conversations**
   - Voir tous les patients qui ont écrit
   - Badge de messages non lus
   - Aperçu du dernier message
   - Pas de recherche manuelle (les patients initialisent)

2. **Chat en temps réel**
   - Mêmes fonctionnalités que les patients
   - Recevoir des documents médicaux
   - Répondre aux questions

## 🔧 Fichiers créés

### Modèles
- `lib/data/models/message_model.dart`
  - `MessageModel` : Représente un message
  - `ConversationModel` : Représente une conversation
  - Enums : `MessageType` (text, image, document, audio)

### Pages
- `lib/features/messages/presentation/pages/conversations_list_page.dart`
  - Liste de toutes les conversations
  - Recherche locale
  - Indicateurs de messages non lus
  - Bouton pour nouvelle conversation (patients)

- `lib/features/messages/presentation/pages/search_doctors_page.dart`
  - Recherche de docteurs (patients uniquement)
  - Filtrage par nom/spécialité
  - Création automatique de conversations

- `lib/features/messages/presentation/pages/chat_page.dart`
  - Interface de chat en temps réel
  - Envoi de texte, images, documents
  - Marquage automatique comme lu
  - Gestion de l'upload
  - Preview des images
  - Ouverture des documents

## 🔥 Règles Firestore

Ajoutez ces règles dans Firebase Console :

```javascript
// Conversations
match /conversations/{conversationId} {
  allow read: if request.auth != null && 
    request.auth.uid in resource.data.participants;
  
  allow create: if request.auth != null && 
    request.auth.uid in request.resource.data.participants;
  
  allow update: if request.auth != null && 
    request.auth.uid in resource.data.participants;
}

// Messages
match /messages/{messageId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.senderId || 
     request.auth.uid == resource.data.receiverId);
  
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.senderId;
  
  allow update: if request.auth != null && 
    request.auth.uid == resource.data.receiverId &&
    request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isRead']);
}
```

## 📦 Storage Firebase

Configuration pour le stockage des fichiers :

```javascript
// Rules pour Firebase Storage
match /chat_images/{conversationId}/{fileName} {
  allow read: if request.auth != null;
  allow write: if request.auth != null &&
    request.resource.size < 10 * 1024 * 1024 && // Max 10MB
    request.resource.contentType.matches('image/.*');
}

match /chat_documents/{conversationId}/{fileName} {
  allow read: if request.auth != null;
  allow write: if request.auth != null &&
    request.resource.size < 20 * 1024 * 1024 && // Max 20MB
    request.resource.contentType.matches('(application/pdf|application/msword|application/vnd.openxmlformats-officedocument.wordprocessingml.document|image/.*)');
}
```

## 📊 Index Firestore

Les index ont été ajoutés dans `firestore.indexes.json` :

1. **messages** - conversationId + timestamp
2. **messages** - conversationId + receiverId + isRead

Déployez avec :
```bash
firebase deploy --only firestore:indexes --project doctolo
```

## 🎨 UI/UX

### Couleurs
- Messages envoyés : `AppColors.primary` (bleu)
- Messages reçus : Blanc
- Background : `AppColors.background`

### Icônes
- 📷 Photo
- 📄 Document
- ✓ Envoyé
- ✓✓ Lu

### États
- Loading : CircularProgressIndicator
- Empty : Illustration avec message
- Erreur : Icône + message d'erreur

## 🚀 Utilisation

### Patient
1. Va dans l'onglet "Messages"
2. Clique sur le bouton "+" ou l'icône de recherche
3. Recherche un docteur par nom ou spécialité
4. Clique sur le docteur pour démarrer la conversation
5. Envoie un message, une photo ou un document

### Docteur
1. Va dans l'onglet "Messages"
2. Voit toutes les conversations initiées par les patients
3. Clique sur une conversation pour répondre
4. Peut envoyer texte, images et documents

## 📝 Notes importantes

1. **Création de conversation** : Seuls les patients peuvent créer une nouvelle conversation
2. **Messages non lus** : Marqués automatiquement comme lus à l'ouverture du chat
3. **Taille des fichiers** :
   - Images : Max 10 MB
   - Documents : Max 20 MB
4. **Formats supportés** : PDF, DOC, DOCX, JPG, JPEG, PNG
5. **Temps réel** : Utilise Firestore Snapshots pour les mises à jour en direct

## 🔒 Sécurité

- Authentification Firebase Auth requise
- Règles Firestore pour limiter l'accès aux participants
- Upload limité par taille et type de fichier
- Pas d'accès aux conversations des autres utilisateurs

## 📱 Responsive

- Interface adaptée mobile et tablette
- Scroll automatique vers le dernier message
- Gestion du clavier
- SafeArea pour les zones sécurisées

## 🐛 Gestion des erreurs

- Try-catch sur tous les appels Firebase
- Messages d'erreur utilisateur-friendly
- Prints de debug dans la console
- Indicateurs de chargement

## 🔄 Mises à jour futures possibles

- [ ] Messages audio/vocaux
- [ ] Appel vidéo depuis le chat
- [ ] Réactions aux messages (emoji)
- [ ] Suppression de messages
- [ ] Modification de messages
- [ ] Messages épinglés
- [ ] Recherche dans les messages
- [ ] Partage de localisation
- [ ] Aperçu de lien
- [ ] Notifications push
