# Guide de Test - Système de Vérification des Professionnels

## Configuration Préalable

Assurez-vous que :
1. Firebase est correctement configuré
2. Les règles Firestore permettent la lecture/écriture
3. Firebase Storage est activé pour l'upload des images
4. L'app a les permissions caméra (iOS/Android)

## Test 1 : Inscription Patient (Devrait fonctionner comme avant)

### Étapes :
1. Ouvrir l'app
2. Cliquer sur "Créer un compte"
3. Remplir le formulaire :
   - Email : `patient@test.com`
   - Mot de passe : `Test1234!`
   - Prénom : `Jean`
   - Nom : `Dupont`
   - Téléphone : `+22500000001`
   - **Rôle : Patient**
4. Accepter les termes
5. Cliquer sur "S'inscrire"

### Résultat Attendu :
✅ Redirection vers `EmailVerificationPage`
✅ Document créé dans `users` avec `role: patient`
✅ Pas de document dans `doctors`

### Vérification Firestore :
```
users/[userId] : {
  email: "patient@test.com",
  role: "patient",
  isVerified: false,
  ...
}
```

---

## Test 2 : Inscription Professionnel (Nouveau flux)

### Étapes :
1. Ouvrir l'app
2. Cliquer sur "Créer un compte"
3. Remplir le formulaire :
   - Email : `doctor@test.com`
   - Mot de passe : `Test1234!`
   - Prénom : `Marie`
   - Nom : `Martin`
   - Téléphone : `+22500000002`
   - **Rôle : Professionnel de santé**
4. Accepter les termes
5. Cliquer sur "S'inscrire"

### Résultat Attendu :
✅ Redirection vers `ProfessionalVerificationPage`
✅ Document créé dans `users` avec `role: doctor`
✅ Affichage du formulaire de vérification

### Vérification Firestore :
```
users/[userId] : {
  email: "doctor@test.com",
  role: "doctor",
  isVerified: false,
  isProfessional: false (pas encore vérifié),
  ...
}
```

---

## Test 3 : Soumission Documents Professionnels

### Sur ProfessionalVerificationPage :

#### Étape 3.1 : Vérification Email
1. Cliquer sur "Email non vérifié"
2. Ouvrir l'email reçu
3. Cliquer sur le lien de vérification
4. Revenir dans l'app
5. Cliquer à nouveau sur "Email non vérifié" pour rafraîchir

**Résultat Attendu :**
✅ Badge devient "Email vérifié" avec icône verte

#### Étape 3.2 : Identifiant Médecin
1. Remplir le champ "Identifiant Médecin" : `ORD123456`

#### Étape 3.3 : Spécialité
1. Sélectionner une spécialité : `Médecin généraliste`

#### Étape 3.4 : Photos CNI
1. Cliquer sur "Photo CNI Recto"
2. Prendre une photo ou sélectionner depuis galerie
3. Vérifier que l'aperçu s'affiche
4. Répéter pour "Photo CNI Verso"

#### Étape 3.5 : Soumission
1. Cliquer sur "Soumettre pour vérification"
2. Attendre l'upload (peut prendre quelques secondes)

### Résultat Attendu :
✅ Message "Demande de vérification envoyée"
✅ Retour à la page précédente
✅ Document créé dans `doctors` avec status `pending`

### Vérification Firestore :
```
doctors/[userId] : {
  userId: "[userId]",
  medicalId: "ORD123456",
  specialty: "Médecin généraliste",
  cniRectoUrl: "https://...",
  cniVersoUrl: "https://...",
  verificationStatus: "pending",
  isVerified: false,
  submittedAt: Timestamp
}

users/[userId] : {
  ...
  isProfessional: true,
  verificationStatus: "pending"
}
```

### Vérification Storage :
```
verification_documents/
  └── [userId]/
      ├── cni_recto.jpg
      └── cni_verso.jpg
```

---

## Test 4 : Recherche AVANT Approbation

### Étapes :
1. Se connecter avec un compte patient
2. Aller sur la page de recherche de professionnels
3. Lancer une recherche

### Résultat Attendu :
❌ Le docteur `doctor@test.com` NE doit PAS apparaître
✅ Message "Aucun professionnel trouvé"

**Raison :** `verificationStatus != 'approved'`

---

## Test 5 : Page Admin - Validation

### Accès Admin :
```dart
// Ajouter temporairement dans doctor_home_page.dart
// Dans la section Settings :
ListTile(
  leading: const Icon(CupertinoIcons.checkmark_shield),
  title: const Text('Vérification (Admin)'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerificationRequestsPage(),
      ),
    );
  },
),
```

### Étapes :
1. Naviguer vers `VerificationRequestsPage`
2. Vérifier que la demande apparaît dans l'onglet "En attente"
3. Voir les infos :
   - Nom : Marie Martin
   - Email : doctor@test.com
   - ID Médecin : ORD123456
   - Spécialité : Médecin généraliste
4. Cliquer sur les photos CNI pour agrandir
5. Cliquer sur "Approuver"

### Résultat Attendu :
✅ Message "Professionnel approuvé avec succès"
✅ La carte disparaît de l'onglet "En attente"
✅ La carte apparaît dans l'onglet "Approuvées"

### Vérification Firestore :
```
doctors/[userId] : {
  ...
  verificationStatus: "approved",
  isVerified: true,
  approvedAt: Timestamp
}

users/[userId] : {
  ...
  verificationStatus: "approved",
  isVerified: true
}
```

---

## Test 6 : Recherche APRÈS Approbation

### Étapes :
1. Se connecter avec un compte patient
2. Aller sur la page de recherche
3. Lancer une recherche

### Résultat Attendu :
✅ Le docteur "Marie Martin" apparaît maintenant dans les résultats
✅ Peut cliquer pour voir le profil complet

### Vérification Console :
```
Query: doctors where verificationStatus == 'approved'
Results: [
  {
    userId: "...",
    specialty: "Médecin généraliste",
    ...
  }
]
```

---

## Test 7 : Rejet d'une Demande

### Étapes :
1. Créer un nouveau compte professionnel (`doctor2@test.com`)
2. Soumettre les documents
3. Dans VerificationRequestsPage, cliquer sur "Rejeter"
4. Entrer une raison : "Documents illisibles, merci de soumettre à nouveau"
5. Confirmer

### Résultat Attendu :
✅ Message "Demande rejetée"
✅ La carte apparaît dans l'onglet "Rejetées"
✅ La raison est enregistrée

### Vérification Firestore :
```
doctors/[userId2] : {
  ...
  verificationStatus: "rejected",
  isVerified: false,
  rejectedAt: Timestamp,
  rejectionReason: "Documents illisibles..."
}
```

---

## Test 8 : Filtres de Recherche

### Étape 8.1 : Filtre par Spécialité
1. Sur SearchProfessionalPage
2. Sélectionner "Cardiologue" dans le dropdown
3. Lancer la recherche

**Résultat :** Seuls les cardiologues approuvés apparaissent

### Étape 8.2 : Filtre Téléconsultation
1. Sélectionner "Téléconsultation"
2. Lancer la recherche

**Résultat :** Seuls les docteurs avec `offersTelemedicine: true` apparaissent

---

## Cas d'Erreur à Tester

### Erreur 1 : Upload Photo Échoue
**Simulation :** Désactiver internet pendant l'upload
**Résultat Attendu :** Message d'erreur, pas de crash

### Erreur 2 : Email Non Vérifié
**Simulation :** Essayer de soumettre sans vérifier l'email
**Résultat Attendu :** SnackBar "Veuillez vérifier votre email avant de continuer"

### Erreur 3 : Champs Manquants
**Simulation :** Soumettre sans remplir l'identifiant médecin
**Résultat Attendu :** Validation formulaire, message "Identifiant requis"

### Erreur 4 : Photos Manquantes
**Simulation :** Soumettre sans les 2 photos CNI
**Résultat Attendu :** SnackBar "Veuillez fournir les deux faces de votre CNI"

---

## Checklist Finale

- [ ] Patient peut s'inscrire normalement
- [ ] Professionnel redirigé vers page de vérification
- [ ] Upload des 2 photos CNI fonctionne
- [ ] Email doit être vérifié
- [ ] Demande créée avec status "pending"
- [ ] Photos stockées dans Firebase Storage
- [ ] Admin voit les demandes en attente
- [ ] Admin peut agrandir les photos
- [ ] Approbation met à jour Firestore correctement
- [ ] Rejet enregistre la raison
- [ ] Recherche ne montre que les approuvés
- [ ] Filtres (spécialité, téléconsultation) fonctionnent
- [ ] Pas de crash si erreur réseau

---

## Commandes Utiles

### Vérifier les documents Firestore :
```bash
# Via Firebase Console
https://console.firebase.google.com/project/[PROJECT_ID]/firestore/data
```

### Logs Flutter :
```bash
flutter logs | grep -E "verification|upload|doctor"
```

### Effacer les données de test :
```javascript
// Dans Firestore Console, supprimer :
- Collection doctors avec verificationStatus = "pending"
- Collection users avec email de test
- Storage verification_documents/[userId]
```

---

## Support

Si un test échoue :
1. Vérifier les logs console
2. Vérifier les données Firestore
3. Vérifier les permissions Firebase
4. Vérifier les règles Firestore (voir VERIFICATION_SYSTEM.md)
