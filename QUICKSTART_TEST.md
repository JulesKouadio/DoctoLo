# 🚀 Quick Start Guide - Doctolo

## Étapes pour Tester l'Application

### 1. Créer les Index Firestore (REQUIS)

L'application nécessite des index composites pour fonctionner. Vous avez 2 options:

#### Option A: Via la Console Firebase (Rapide)
1. Lancez l'application avec `flutter run`
2. Lorsqu'une erreur d'index apparaît dans la console, vous verrez un lien comme:
   ```
   https://console.firebase.google.com/v1/r/project/doctolo/firestore/indexes?create_composite=...
   ```
3. Cliquez sur ce lien (CMD+Click dans le terminal)
4. Firebase créera automatiquement l'index
5. Attendez 2-3 minutes que l'index se construise
6. Relancez l'app avec hot restart (Shift+R)

#### Option B: Via Firebase CLI (Pour production)
```bash
cd /Users/apple/doctolo
firebase deploy --only firestore:indexes
```

### 2. Créer des Données de Test

#### A. Créer un compte Médecin:
1. Lancez l'app
2. Inscription → Rôle: "Professionnel de santé"
3. Remplissez le profil
4. Allez dans "Profil" → Configurez:
   - **Disponibilités:** Ajoutez des créneaux (ex: Lundi 09:00-17:00)
   - **Types de consultation:** Activez physique ET téléconsultation + tarifs
   - **Documents:** Uploadez un CV (optionnel)

#### B. Créer un compte Patient:
1. Déconnectez-vous
2. Inscription → Rôle: "Patient"
3. Remplissez le profil

### 3. Tester le Flow de Réservation

#### Depuis le compte Patient:
1. **Accueil** → Clic sur "Rechercher un professionnel"
2. **Recherche:**
   - Sélectionnez une spécialité (ex: "Médecin généraliste")
   - Filtrez par type si besoin
   - Cliquez sur la carte d'un médecin
3. **Profil du médecin:**
   - Consultez les informations
   - Scrollez pour voir tous les détails
   - Cliquez sur "Prendre rendez-vous" en bas
4. **Réservation:**
   - **Étape 1:** Choisissez le type (cabinet ou téléconsultation)
   - **Étape 2:** 
     - Sélectionnez une date dans le picker horizontal
     - Choisissez un créneau horaire disponible
   - **Étape 3:** 
     - Vérifiez le résumé
     - Ajoutez un motif (optionnel)
     - Confirmez
5. **Confirmation:**
   - Dialog de succès avec animation
   - Redirection automatique
6. **Voir le rendez-vous:**
   - Onglet "Rendez-vous" (2ème icône bottom nav)
   - Trouvez votre RDV dans l'onglet "En attente"
   - Cliquez pour voir les détails

#### Depuis le compte Médecin:
1. **Agenda** (2ème onglet)
2. Onglet "En attente"
3. Trouvez le RDV créé par le patient
4. Cliquez sur "Confirmer"
5. Le RDV passe dans "Confirmés"

### 4. Tester le Responsive

#### Sur Simulateur iOS:
```bash
# iPhone (Mobile)
flutter run -d "iPhone 16 Plus"

# iPad (Tablette)
flutter run -d "iPad Pro 12.9"
```

#### Sur Chrome (Desktop):
```bash
flutter run -d chrome

# Dans Chrome DevTools:
# - F12 → Toggle Device Toolbar
# - Testez différentes résolutions:
#   - 375px (Mobile)
#   - 768px (Tablette)
#   - 1920px (Desktop)
```

### 5. Vérifier les Fonctionnalités

#### ✅ Checklist Patient:
- [ ] Recherche de médecins avec filtres
- [ ] Affichage du profil détaillé
- [ ] Réservation complète (3 étapes)
- [ ] Liste des rendez-vous avec onglets
- [ ] Détails du rendez-vous (bottom sheet)
- [ ] Annulation d'un rendez-vous
- [ ] Responsive sur mobile/tablette/desktop

#### ✅ Checklist Médecin:
- [ ] Configuration des disponibilités
- [ ] Configuration des types de consultation
- [ ] Upload de documents
- [ ] Visualisation de l'agenda
- [ ] Confirmation d'un rendez-vous
- [ ] Annulation d'un rendez-vous
- [ ] Responsive sur mobile/tablette/desktop

---

## 🐛 Troubleshooting

### Problème: Index manquant
**Symptôme:** Erreur `[cloud_firestore/failed-precondition] The query requires an index`
**Solution:** Créez l'index (voir Étape 1)

### Problème: Pas de créneaux disponibles
**Symptôme:** "Aucun créneau disponible pour cette date"
**Solution:** 
1. Connectez-vous en tant que médecin
2. Profil → "Mes disponibilités"
3. Ajoutez des créneaux pour le jour de la semaine souhaité

### Problème: Upload de document échoue
**Symptôme:** Erreur lors de l'upload
**Solution:**
1. Vérifiez que Firebase Storage est activé
2. Vérifiez les règles de sécurité Storage:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /doctors/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### Problème: Layout cassé sur une taille d'écran
**Symptôme:** Overflow, éléments mal positionnés
**Solution:**
1. Vérifiez que ResponsiveLayout est bien importé
2. Utilisez ResponsiveRow au lieu de Row
3. Ajustez les childAspectRatio des GridView

---

## 📱 Recommandations de Test

### Appareils prioritaires:
1. **iPhone 14/15 Pro** (Mobile principal)
2. **iPad Air** (Tablette)
3. **Chrome Desktop** (Desktop)

### Scénarios à tester:
1. **Happy Path:** Recherche → Profil → Réservation → Confirmation
2. **Edge Cases:**
   - Médecin sans disponibilités
   - Patient annule un RDV
   - Médecin refuse un RDV
   - Journée complète (tous les créneaux pris)
3. **Responsive:**
   - Rotation écran (portrait/paysage)
   - Resize window (Chrome)
   - Navigation entre vues

---

## 🎯 Métriques de Succès

L'implémentation est réussie si:
- ✅ Le flow complet fonctionne sans crash
- ✅ Les données sont bien sauvegardées dans Firestore
- ✅ Le responsive s'adapte sur les 3 tailles
- ✅ Les animations sont fluides
- ✅ Les messages d'erreur sont clairs
- ✅ La navigation est intuitive

---

## 📞 Support

En cas de problème:
1. Vérifiez les logs de la console
2. Consultez `IMPLEMENTATION_SUMMARY.md` pour les détails techniques
3. Lisez `RESPONSIVE_DESIGN_GUIDE.md` pour le responsive
4. Vérifiez `FIRESTORE_INDEXES.md` pour les index

---

**Prêt à tester?** Lancez `flutter run` et suivez le guide! 🚀
