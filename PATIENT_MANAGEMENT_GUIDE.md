# Guide d'utilisation - Gestion des Patients (Médecin)

## 📋 Vue d'ensemble

Le système de gestion des patients permet aux médecins de :
- **Filtrer** les patients par intervalle de dates
- **Rechercher** un patient par nom
- **Consulter** l'historique complet des consultations
- **Visualiser** les informations médicales détaillées

## 🎯 Fonctionnalités

### 1. Liste des Patients (`patients_list_page.dart`)

#### Filtrage par date
- Bouton **"Filtrer par période"** : Ouvre un sélecteur de plage de dates
- Affiche uniquement les patients ayant eu des consultations dans la période sélectionnée
- Bouton ❌ pour effacer les filtres

#### Recherche par nom
- Champ de recherche en temps réel
- Recherche insensible à la casse
- Filtre les résultats instantanément

#### Affichage
- **Avatar** avec initiale du patient
- **Nom complet** du patient
- **Dernière visite** (date formatée)
- **Nombre de consultations** total

### 2. Détails du Patient (`patient_detail_page.dart`)

#### Onglet 1 : Informations Médicales
Affiche les données de santé du patient :

**Informations personnelles :**
- Nom complet
- Email
- Téléphone
- Date de naissance
- Genre

**Informations médicales :**
- 🩸 **Groupe sanguin** (A+, B+, O-, etc.)
- 📏 **Taille** (en cm)
- ⚖️ **Poids** (en kg)
- 🚨 **Contact d'urgence**

**Alertes médicales :**
- 🔴 **Allergies** (liste avec badges orange)
- 💔 **Maladies chroniques** (liste avec badges rouges)

#### Onglet 2 : Historique des Consultations
Liste chronologique inversée de toutes les consultations :

**Informations affichées :**
- 📅 **Date et heure** de la consultation
- 🏥 **Type** : Téléconsultation ou Au cabinet
- 📝 **Raison** de consultation
- ✅ **Diagnostic** du médecin
- 💊 **Ordonnance** prescrite
- 📊 **Statut** : En attente / Confirmé / Terminé / Annulé
- 📄 **Notes** supplémentaires

**Interaction :**
- Cliquer sur une consultation ouvre un modal détaillé
- Vue en glissement (draggable sheet)

## 💾 Structure des Données

### Collection `patient_medical_info`
```firestore
patient_medical_info/{patientId}
  - bloodGroup: string (ex: "A+", "O-")
  - height: number (en cm)
  - weight: number (en kg)
  - allergies: array<string>
  - chronicDiseases: array<string>
  - emergencyContact: string
  - lastUpdated: timestamp
```

### Collection `appointments`
Les consultations existantes peuvent être enrichies avec :
```firestore
appointments/{appointmentId}
  - patientId: string
  - doctorId: string
  - date: timestamp
  - reason: string (raison de consultation)
  - type: string (type de consultation)
  - status: string
  - diagnosis: string (NOUVEAU - diagnostic du médecin)
  - prescription: string (NOUVEAU - ordonnance)
  - notes: string (NOUVEAU - notes supplémentaires)
```

## 🔧 Comment Ajouter les Informations Médicales

### Pour un Patient (via interface utilisateur - À DÉVELOPPER)

Une future page permettra aux patients de renseigner :
```dart
// Page : patient_medical_info_form.dart (À CRÉER)
await FirebaseFirestore.instance
  .collection('patient_medical_info')
  .doc(patientId)
  .set({
    'bloodGroup': 'A+',
    'height': 175.0,
    'weight': 70.5,
    'allergies': ['Pénicilline', 'Arachides'],
    'chronicDiseases': ['Hypertension'],
    'emergencyContact': '+225 07 XX XX XX XX',
    'lastUpdated': FieldValue.serverTimestamp(),
  });
```

### Pour Ajouter Diagnostic et Ordonnance (Médecin - À DÉVELOPPER)

Après une consultation, le médecin pourra compléter :
```dart
// Page : complete_consultation_page.dart (À CRÉER)
await FirebaseFirestore.instance
  .collection('appointments')
  .doc(appointmentId)
  .update({
    'diagnosis': 'Grippe saisonnière',
    'prescription': '''
      - Paracétamol 1000mg : 3x/jour pendant 5 jours
      - Vitamine C : 1x/jour
      - Repos recommandé
    ''',
    'notes': 'Patient fébrile, température 38.5°C',
    'status': 'completed',
  });
```

## 📝 Exemple d'utilisation manuelle (Firebase Console)

Pour tester immédiatement avec des données :

### 1. Ajouter des infos médicales à un patient
```
Collection : patient_medical_info
Document ID : {patientId}
Données :
{
  "bloodGroup": "O+",
  "height": 180,
  "weight": 75.5,
  "allergies": ["Pénicilline"],
  "chronicDiseases": ["Diabète de type 2"],
  "emergencyContact": "+225 07 12 34 56 78",
  "lastUpdated": [Timestamp now]
}
```

### 2. Compléter une consultation existante
```
Collection : appointments
Document ID : {appointmentId existant}
Ajouter les champs :
{
  "diagnosis": "Infection respiratoire haute",
  "prescription": "Amoxicilline 500mg 3x/jour pendant 7 jours",
  "notes": "Revoir dans 1 semaine si symptômes persistent"
}
```

## 🎨 Interface Utilisateur

### Couleurs et Icônes
- **Groupe sanguin** : 🩸 Rouge
- **Téléconsultation** : 📹 Accent (violet)
- **Au cabinet** : 🏥 Primary (bleu)
- **Allergies** : ⚠️ Orange
- **Maladies chroniques** : ❤️ Rouge

### Navigation
```
Dashboard Médecin
  └─ Onglet "Patients"
      └─ PatientsListPage
          ├─ Filtres par date
          ├─ Recherche
          └─ Clic sur patient
              └─ PatientDetailPage
                  ├─ Onglet "Infos médicales"
                  └─ Onglet "Historique consultations"
```

## 🚀 Prochaines Étapes Recommandées

1. **Formulaire de saisie des infos médicales** (patient)
   - Page dédiée pour que les patients renseignent leurs données
   - Validation des données (groupe sanguin, taille, poids)

2. **Page de complétion de consultation** (médecin)
   - Formulaire post-consultation
   - Champs : diagnostic, ordonnance, notes
   - Bouton "Terminer la consultation"

3. **Génération d'ordonnances PDF**
   - Intégration avec `pdf` package
   - Template d'ordonnance professionnelle
   - Export et partage

4. **Système de notifications**
   - Notification au patient quand ordonnance disponible
   - Rappel de suivi

5. **Statistiques avancées**
   - Dashboard avec graphiques
   - Évolution du poids/taille
   - Historique des diagnostics

## 📱 Responsive Design

Toutes les pages sont entièrement responsives :
- **Mobile** : Liste verticale, cards en pleine largeur
- **Tablette** : Grid 2 colonnes
- **Desktop** : Grid 3 colonnes

## ✅ Checklist de Test

- [ ] Filtrer par date (sélectionner une période)
- [ ] Rechercher un patient par nom
- [ ] Voir les détails d'un patient
- [ ] Consulter les infos médicales (groupe sanguin, taille)
- [ ] Voir l'historique des consultations
- [ ] Afficher le type de consultation (télé/cabinet)
- [ ] Consulter diagnostic et ordonnance
- [ ] Effacer les filtres

---

**Note :** Les données de diagnostic et ordonnance doivent être ajoutées via Firebase Console ou en créant les pages de formulaire appropriées.
