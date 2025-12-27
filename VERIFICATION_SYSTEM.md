# Système de Vérification des Professionnels de Santé

## Vue d'ensemble

Le système de vérification des professionnels de santé garantit que seuls les médecins vérifiés apparaissent dans les résultats de recherche. Cela protège les patients et maintient la qualité du service.

## Processus de Vérification

### 1. Inscription Initiale (Patient ou Professionnel)

L'utilisateur s'inscrit avec :
- Email
- Mot de passe
- Nom et prénom
- Téléphone
- Rôle (Patient ou Professionnel de santé)

### 2. Vérification Professionnelle (Uniquement pour les Professionnels)

Après l'inscription, les professionnels de santé sont redirigés vers la page `ProfessionalVerificationPage` où ils doivent fournir :

#### Documents Obligatoires :
1. **Identifiant Médecin** : Numéro d'ordre ou identifiant professionnel
2. **CNI Recto** : Photo de la carte d'identité nationale (face avant)
3. **CNI Verso** : Photo de la carte d'identité nationale (face arrière)
4. **Spécialité** : Sélection dans la liste des spécialités médicales
5. **Email vérifié** : L'utilisateur doit confirmer son email

#### Statuts de Vérification :
- `pending` : En attente de vérification par l'administrateur
- `approved` : Professionnel vérifié et autorisé
- `rejected` : Demande rejetée (avec raison)

### 3. Validation Administrateur

Les administrateurs accèdent à `VerificationRequestsPage` pour :
- Consulter les demandes en attente
- Voir les photos CNI et l'identifiant médecin
- Approuver ou rejeter les demandes
- Ajouter une raison en cas de rejet

### 4. Visibilité dans la Recherche

**Conditions pour apparaître dans les résultats :**
- `verificationStatus` = `approved` dans la collection `doctors`
- `isVerified` = `true` dans la collection `users`
- Email vérifié

## Structure Firestore

### Collection `users`
```json
{
  "id": "user123",
  "email": "doctor@example.com",
  "firstName": "Jean",
  "lastName": "Dupont",
  "phoneNumber": "+22500000000",
  "role": "doctor",
  "isVerified": true,
  "isProfessional": true,
  "verificationStatus": "approved",
  "createdAt": "Timestamp"
}
```

### Collection `doctors`
```json
{
  "userId": "user123",
  "medicalId": "ORD123456",
  "specialty": "Médecin généraliste",
  "cniRectoUrl": "https://storage.googleapis.com/.../cni_recto.jpg",
  "cniVersoUrl": "https://storage.googleapis.com/.../cni_verso.jpg",
  "verificationStatus": "approved",
  "isVerified": true,
  "submittedAt": "Timestamp",
  "approvedAt": "Timestamp",
  "rating": 0.0,
  "reviewCount": 0
}
```

## Flux de Données

```
1. Inscription
   ↓
2. Création compte users (role=doctor)
   ↓
3. Redirection → ProfessionalVerificationPage
   ↓
4. Upload CNI + Identifiant médecin
   ↓
5. Création document doctors (status=pending)
   ↓
6. Administrateur valide
   ↓
7. Update: verificationStatus=approved, isVerified=true
   ↓
8. Professionnel visible dans recherche
```

## Sécurité

### Règles Firestore (à ajouter) :

```javascript
// Collection doctors - Lecture publique des profils approuvés uniquement
match /doctors/{doctorId} {
  allow read: if resource.data.verificationStatus == 'approved';
  allow create: if request.auth != null 
    && request.auth.uid == request.resource.data.userId;
  allow update: if request.auth != null 
    && (request.auth.uid == resource.data.userId 
        || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
}

// Collection users - Lecture publique limitée
match /users/{userId} {
  allow read: if request.auth != null;
  allow create: if request.auth.uid == userId;
  allow update: if request.auth.uid == userId 
    || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

## Fichiers Modifiés/Créés

### Nouveaux Fichiers :
- `lib/features/auth/presentation/pages/professional_verification_page.dart` : Page de vérification professionnelle
- `lib/features/admin/presentation/pages/verification_requests_page.dart` : Page admin pour gérer les demandes
- `VERIFICATION_SYSTEM.md` : Cette documentation

### Fichiers Modifiés :
- `lib/features/auth/presentation/pages/register_page.dart` : Redirection vers vérification si professionnel
- `lib/features/search/presentation/pages/search_professional_page.dart` : Filtre sur professionnels vérifiés uniquement

## Accès Admin

Pour accéder à la page de vérification des demandes, l'administrateur doit naviguer vers :
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const VerificationRequestsPage(),
  ),
);
```

**Note:** Ajoutez un bouton dans le menu administrateur ou dans les paramètres pour accéder à cette page.

## Tests Recommandés

1. **Inscription Patient** : Vérifier redirection vers EmailVerificationPage
2. **Inscription Professionnel** : Vérifier redirection vers ProfessionalVerificationPage
3. **Upload Photos** : Tester capture et upload des CNI
4. **Validation Email** : Confirmer que le bouton "Vérifier email" fonctionne
5. **Recherche** : Vérifier que seuls les professionnels approuvés apparaissent
6. **Admin - Approbation** : Tester l'approbation d'une demande
7. **Admin - Rejet** : Tester le rejet avec raison
8. **Filtres Admin** : Tester les filtres (pending/approved/rejected)

## Améliorations Futures

- [ ] Notifications push lors de l'approbation/rejet
- [ ] Dashboard admin avec statistiques des vérifications
- [ ] Vérification automatique via API d'ordre des médecins
- [ ] Expiration des documents (renouvellement annuel)
- [ ] Historique des vérifications
- [ ] Support multi-pays avec différents types d'ID
