# Index Firestore requis pour Doctolo

## Collection: appointments

### Index composites nécessaires

1. **Index pour requête des rendez-vous par patient**
   - Collection: `appointments`
   - Champs indexés:
     - `patientId` (Ascending)
     - `date` (Ascending)
   - Mode de requête: Collection

2. **Index pour requête des rendez-vous par docteur**
   - Collection: `appointments`
   - Champs indexés:
     - `doctorId` (Ascending)
     - `date` (Ascending)
   - Mode de requête: Collection

3. **Index pour requête des rendez-vous par patient et statut**
   - Collection: `appointments`
   - Champs indexés:
     - `patientId` (Ascending)
     - `status` (Ascending)
     - `date` (Ascending)
   - Mode de requête: Collection

4. **Index pour requête des rendez-vous par docteur et statut**
   - Collection: `appointments`
   - Champs indexés:
     - `doctorId` (Ascending)
     - `status` (Ascending)
     - `date` (Ascending)
   - Mode de requête: Collection

## Comment créer les index

### Option 1: Via la console Firebase (automatique)
Lorsque vous lancez l'application et qu'une requête nécessite un index, Firebase affiche un lien dans la console. Cliquez sur ce lien pour créer automatiquement l'index.

### Option 2: Via firebase.json (recommandé pour la production)
Créez un fichier `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "patientId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "patientId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Puis déployez avec:
```bash
firebase deploy --only firestore:indexes
```

## Collection: doctors

### Index simple nécessaire (si pas déjà créé)

1. **Index pour recherche par spécialité**
   - Collection: `doctors`
   - Champ: `specialty` (Ascending)

## Collection: users

### Index simple nécessaire (si pas déjà créé)

1. **Index pour recherche par rôle**
   - Collection: `users`
   - Champ: `role` (Ascending)

---

**Note**: Les index simples (sur un seul champ) sont généralement créés automatiquement par Firestore. Seuls les index composites (sur plusieurs champs) nécessitent une création manuelle.
