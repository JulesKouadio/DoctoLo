# Guide de la Fonctionnalité Ordonnances

## 📋 Vue d'ensemble

Le système d'ordonnances permet aux docteurs de créer et d'envoyer des ordonnances médicales au format PDF directement depuis la messagerie.

## ✨ Fonctionnalités

### 1. Création d'Ordonnance
- Interface complète pour créer une ordonnance
- Formulaire avec validation
- Génération automatique de PDF professionnel
- Envoi direct dans le chat

### 2. Informations Incluses
- **Généralités**
  - Nom de la clinique (optionnel)
  - Nom du docteur (automatique)
  - Nom du patient (automatique)
  - Date de l'ordonnance (automatique)

- **Médicaments** (liste dynamique)
  - Nom du médicament (requis)
  - Posologie (ex: "1 comprimé 3 fois par jour")
  - Durée du traitement (ex: "7 jours")
  - Possibilité d'ajouter plusieurs médicaments

- **Notes** (optionnel)
  - Recommandations supplémentaires
  - Instructions spéciales
  - Conseils au patient

## 🎨 Interface Utilisateur

### Accès à la Fonctionnalité
1. Ouvrir une conversation avec un patient
2. Cliquer sur l'icône d'attachement (📎)
3. Sélectionner "Ordonnance" (uniquement visible pour les docteurs)
4. Remplir le formulaire
5. Cliquer sur "Créer" pour générer et envoyer

### Formulaire d'Ordonnance
```
┌─────────────────────────────────────┐
│ Créer une ordonnance           [Créer]│
├─────────────────────────────────────┤
│                                     │
│ Informations générales              │
│ ┌─────────────────────────────────┐ │
│ │ Nom de la clinique              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 👨‍⚕️ Docteur: Dr. Jean Dupont        │
│ 👤 Patient: Marie Martin            │
│                                     │
├─────────────────────────────────────┤
│                                     │
│ Médicaments                    [+]  │
│ ┌─────────────────────────────────┐ │
│ │ ① Médicament 1           [🗑️]  │ │
│ │ Nom: Paracétamol 500mg          │ │
│ │ Posologie: 1 comprimé 3x/jour   │ │
│ │ Durée: 7 jours                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ② Médicament 2           [🗑️]  │ │
│ │ Nom: Ibuprofène 400mg           │ │
│ │ Posologie: Si douleur           │ │
│ │ Durée: Au besoin                │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│                                     │
│ Notes (optionnel)                   │
│ ┌─────────────────────────────────┐ │
│ │ Prendre les médicaments avec    │ │
│ │ de la nourriture. Repos         │ │
│ │ recommandé.                     │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 📄 Format du PDF Généré

### Structure
```
┌──────────────────────────────────────┐
│  [Cabinet Médical]                   │
│  Dr. Jean Dupont                     │
├──────────────────────────────────────┤
│                                      │
│  PATIENT                             │
│  Marie Martin                        │
│  Date: 15/12/2024                    │
│                                      │
├──────────────────────────────────────┤
│                                      │
│     ORDONNANCE MÉDICALE              │
│                                      │
├──────────────────────────────────────┤
│                                      │
│  ① Paracétamol 500mg                 │
│     Posologie: 1 comprimé 3x/jour    │
│     Durée: 7 jours                   │
│                                      │
│  ② Ibuprofène 400mg                  │
│     Posologie: Si douleur            │
│     Durée: Au besoin                 │
│                                      │
├──────────────────────────────────────┤
│                                      │
│  Notes:                              │
│  Prendre les médicaments avec        │
│  de la nourriture. Repos recommandé. │
│                                      │
├──────────────────────────────────────┤
│                                      │
│              Signature et cachet     │
│                                      │
│              ___________________     │
│              Dr. Jean Dupont         │
│                                      │
└──────────────────────────────────────┘
```

## 🔧 Implémentation Technique

### Fichiers Créés/Modifiés

#### 1. create_prescription_page.dart
Page complète pour créer l'ordonnance avec:
- Formulaire dynamique
- Gestion des médicaments (ajout/suppression)
- Génération PDF avec package `pdf`
- Design professionnel et moderne

#### 2. chat_page.dart (modifié)
Ajout de:
- Option "Ordonnance" dans le bottom sheet d'attachements (uniquement pour docteurs)
- Méthode `_createAndSendPrescription()` pour le flux complet
- Upload automatique vers Firebase Storage
- Envoi comme message de type document

### Flux de Données
```
Docteur clique sur Ordonnance
           ↓
Navigation vers CreatePrescriptionPage
           ↓
Docteur remplit le formulaire
           ↓
Génération PDF avec package pdf
           ↓
Sauvegarde temporaire (path_provider)
           ↓
Upload vers Firebase Storage
           ↓
Suppression du fichier temporaire
           ↓
Envoi du message avec URL
           ↓
Patient reçoit l'ordonnance
```

### Stockage Firebase
```
chat_documents/
  └── {conversationId}/
      └── {timestamp}_Ordonnance_{patientName}_{date}.pdf
```

### Format du Message
```dart
{
  'content': '📋 Ordonnance médicale',
  'type': 'document',
  'fileUrl': 'https://storage.googleapis.com/...',
  'fileName': 'Ordonnance_Marie_Martin_15-12-2024_14-30.pdf',
  'fileSize': 156432,
  'senderId': 'doctorId',
  'receiverId': 'patientId',
  'timestamp': Timestamp.now(),
  'isRead': false
}
```

## 🎯 Validation et Erreurs

### Validation du Formulaire
- ✅ Au moins un médicament requis
- ✅ Nom du médicament obligatoire
- ⚠️ Posologie et durée optionnelles (recommandées)
- ⚠️ Nom de la clinique optionnel
- ⚠️ Notes optionnelles

### Gestion des Erreurs
```dart
try {
  // Génération et envoi
} catch (e) {
  print('❌ Erreur création ordonnance: $e');
  // Affichage SnackBar d'erreur
}
```

## 📱 Utilisation

### Pour le Docteur
1. **Ouvrir le chat** avec un patient
2. **Cliquer sur 📎** (bouton d'attachement)
3. **Sélectionner "Ordonnance"**
4. **Remplir les informations:**
   - Nom de la clinique (optionnel)
   - Ajouter les médicaments avec [+]
   - Pour chaque médicament: nom, posologie, durée
   - Ajouter des notes si nécessaire
5. **Cliquer sur "Créer"**
6. **Attendre la génération** (loader visible)
7. **Confirmation** "Ordonnance envoyée avec succès"

### Pour le Patient
1. Reçoit une notification de nouveau message
2. Voit "📋 Ordonnance médicale" dans le chat
3. Peut cliquer pour télécharger/ouvrir le PDF
4. Peut consulter et imprimer l'ordonnance

## 🎨 Design et Couleurs

### Bottom Sheet - Option Ordonnance
- **Icône:** 📄 `CupertinoIcons.doc_text`
- **Couleur:** Vert (`Colors.green`)
- **Titre:** "Ordonnance"
- **Sous-titre:** "Créer une ordonnance médicale"

### Page de Création
- **Couleur primaire:** `AppColors.primary` (bleu)
- **Fond:** `AppColors.background`
- **Cards:** Blanc avec élévation
- **Badges numérotés:** Cercles bleus pour les médicaments

### PDF
- **En-tête:** Fond bleu clair
- **Texte principal:** Noir
- **Accents:** Bleu pour les titres
- **Cadres:** Gris clair pour les sections

## 🔐 Sécurité

### Permissions
- ✅ Uniquement les docteurs peuvent créer des ordonnances
- ✅ Vérification `widget.isDoctor` avant affichage de l'option
- ✅ Validation côté client du formulaire

### Firestore Rules (à vérifier)
```javascript
// Les docteurs peuvent envoyer des ordonnances
match /messages/{messageId} {
  allow write: if request.auth != null && 
    request.resource.data.senderId == request.auth.uid &&
    (request.resource.data.type == 'document' || 
     request.resource.data.type == 'text');
}
```

### Storage Rules (à vérifier)
```javascript
// Upload d'ordonnances
match /chat_documents/{conversationId}/{fileName} {
  allow write: if request.auth != null &&
    fileName.matches('.*\\.pdf$');
}
```

## 📦 Dépendances

```yaml
dependencies:
  pdf: ^3.11.1              # Génération PDF
  path_provider: ^2.1.4     # Fichiers temporaires
  intl: ^0.20.2             # Formatage dates
  firebase_storage: ^12.3.4 # Upload fichiers
  cloud_firestore: ^5.5.0   # Base de données
```

## 🚀 Améliorations Futures

### Court Terme
- [ ] Modèles d'ordonnances prédéfinis
- [ ] Base de données de médicaments avec auto-complétion
- [ ] Signature électronique du docteur
- [ ] Logo de la clinique dans le PDF

### Long Terme
- [ ] Historique des ordonnances par patient
- [ ] Export batch de plusieurs ordonnances
- [ ] Intégration avec systèmes de pharmacie
- [ ] QR Code pour vérification d'authenticité
- [ ] Multi-langues pour les ordonnances
- [ ] Templates personnalisables par docteur

## 🐛 Résolution de Problèmes

### Le bouton "Ordonnance" n'apparaît pas
- Vérifier que l'utilisateur est bien un docteur (`widget.isDoctor = true`)
- Vérifier que le chat est bien ouvert

### Erreur de génération PDF
- Vérifier les permissions d'écriture
- Vérifier que `path_provider` est bien installé
- Consulter les logs: `❌ Erreur création ordonnance:`

### L'ordonnance n'est pas envoyée
- Vérifier la connexion internet
- Vérifier les règles Firebase Storage
- Vérifier les quotas Firebase

### Le PDF est vide ou incomplet
- Vérifier que tous les champs requis sont remplis
- Vérifier les données avant génération
- Tester avec un seul médicament simple

## 📞 Support

Pour toute question ou problème:
1. Vérifier les logs dans la console Flutter
2. Vérifier les erreurs Firebase
3. Consulter ce guide
4. Contacter l'équipe de développement

---

**Version:** 1.0  
**Date:** Décembre 2024  
**Auteur:** Équipe Doctolo
