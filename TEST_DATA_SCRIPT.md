# 🧪 Script de Test - Données Patients

## Comment ajouter des données de test via Firebase Console

### Étape 1 : Ajouter les informations médicales d'un patient

1. Allez sur **Firebase Console** → Votre projet `doctolo`
2. Cliquez sur **Firestore Database**
3. Créez une nouvelle collection `patient_medical_info`
4. Ajoutez un document avec l'ID d'un patient existant

**Exemple de document :**
```json
Document ID: [ID_DU_PATIENT]

{
  "bloodGroup": "A+",
  "height": 175,
  "weight": 72.5,
  "allergies": ["Pénicilline", "Pollen"],
  "chronicDiseases": ["Hypertension artérielle"],
  "emergencyContact": "+225 07 12 34 56 78",
  "lastUpdated": [Timestamp automatique]
}
```

### Étape 2 : Enrichir les consultations existantes

1. Allez dans la collection **appointments**
2. Sélectionnez un rendez-vous existant (statut: completed de préférence)
3. Ajoutez les champs suivants :

```json
{
  "diagnosis": "Grippe saisonnière avec fièvre",
  "prescription": "• Paracétamol 1000mg : 3 fois par jour pendant 5 jours\n• Repos recommandé\n• Hydratation importante",
  "notes": "Patient présentait une température de 38.5°C. Symptômes depuis 2 jours."
}
```

### Étape 3 : Créer un patient complet de test

Si vous voulez créer un patient avec toutes les données :

**1. Collection `users` :**
```json
Document ID: [AUTO_GENERATE]

{
  "email": "jean.dupont@test.com",
  "firstName": "Jean",
  "lastName": "Dupont",
  "phone": "+225 07 11 22 33 44",
  "dateOfBirth": [Timestamp: 1990-05-15],
  "gender": "male",
  "role": "patient",
  "createdAt": [Timestamp now],
  "isEmailVerified": true
}
```

**2. Collection `patient_medical_info` :**
```json
Document ID: [MÊME_ID_QUE_USER]

{
  "bloodGroup": "O+",
  "height": 180,
  "weight": 78.0,
  "allergies": ["Aspirine"],
  "chronicDiseases": [],
  "emergencyContact": "+225 07 99 88 77 66",
  "lastUpdated": [Timestamp now]
}
```

**3. Collection `appointments` :**
```json
Document ID: [AUTO_GENERATE]

{
  "patientId": "[ID_DU_PATIENT]",
  "doctorId": "[ID_DU_DOCTEUR]",
  "patientName": "Jean Dupont",
  "doctorName": "Martin",
  "specialty": "Médecine Générale",
  "date": [Timestamp: aujourd'hui],
  "timeSlot": "14:00",
  "type": "Consultation physique",
  "status": "completed",
  "reason": "Mal de tête persistant et fatigue",
  "diagnosis": "Migraine avec tension artérielle légèrement élevée",
  "prescription": "• Ibuprofène 400mg : 2 fois par jour si douleur\n• Magnésium : 1 comprimé le soir\n• Surveiller tension artérielle",
  "notes": "Recommandé de consulter un cardiologue si symptômes persistent.",
  "fee": 15000,
  "createdAt": [Timestamp now]
}
```

## 📋 Groupes sanguins valides
- A+, A-, B+, B-, AB+, AB-, O+, O-

## 🎯 Scénarios de test recommandés

### Scénario 1 : Patient avec plusieurs consultations
Créez 3-4 consultations pour le même patient avec :
- Dates différentes (étalées sur 3 mois)
- Mix de téléconsultation et physique
- Diagnostics variés
- Statuts différents (completed, scheduled)

### Scénario 2 : Patient avec allergies multiples
```json
{
  "allergies": [
    "Pénicilline",
    "Arachides",
    "Latex",
    "Pollen de bouleau"
  ],
  "chronicDiseases": [
    "Asthme",
    "Diabète de type 2"
  ]
}
```

### Scénario 3 : Patient sans informations médicales
Ne créez que le user et les appointments, pas de document medical_info
→ Devrait afficher "Non renseigné"

### Scénario 4 : Filtrage par dates
Créez des consultations avec des dates :
- Il y a 1 semaine
- Il y a 1 mois
- Il y a 3 mois
- Aujourd'hui

Puis testez le filtrage par périodes.

## 🔍 Points à vérifier

- [ ] Les filtres de date fonctionnent
- [ ] La recherche par nom fonctionne (insensible à la casse)
- [ ] Le groupe sanguin s'affiche en rouge
- [ ] Les allergies sont en badges orange
- [ ] Les maladies chroniques en rouge
- [ ] Le type de consultation (télé/physique) est bien affiché
- [ ] Les diagnostics et ordonnances apparaissent
- [ ] Le modal de détails s'ouvre correctement
- [ ] Navigation entre les onglets fonctionne
- [ ] Affichage "Non renseigné" pour données manquantes

## 🚀 Commandes Flutter

```bash
# Lancer l'app
flutter run

# Analyser le code
flutter analyze

# Hot reload pendant le développement
# Appuyez sur 'r' dans le terminal
```

## 💡 Astuces

1. **Pour tester rapidement :** Utilisez un patient existant qui a déjà des rendez-vous et ajoutez juste `patient_medical_info`

2. **Format des dates :** Utilisez toujours des Timestamps Firestore, pas des strings

3. **Ordonnances :** Utilisez `\n` pour les retours à la ligne dans le champ prescription

4. **IDs cohérents :** L'ID du document dans `patient_medical_info` DOIT correspondre à l'ID du user

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez la console Flutter pour les erreurs
2. Vérifiez que les IDs correspondent entre les collections
3. Assurez-vous que le médecin est bien connecté
4. Vérifiez les règles de sécurité Firestore

---

**Note :** Pour une utilisation en production, créez des formulaires dans l'app pour saisir ces données au lieu de passer par Firebase Console.
