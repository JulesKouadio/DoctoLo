# UI Components Documentation

## Structure des composants

### 📁 `/lib/shared/widgets/`
Bibliothèque de widgets réutilisables pour toute l'application.

---

## Widgets disponibles

### 1. **CustomCard**
Carte de base avec design cohérent.

```dart
CustomCard(
  onTap: () {}, // Optionnel
  padding: EdgeInsets.all(16),
  color: Colors.white,
  elevation: 4.0,
  borderRadius: BorderRadius.circular(12),
  child: YourWidget(),
)
```

**Propriétés:**
- `child` - Widget enfant (required)
- `padding` - Padding interne (optional)
- `onTap` - Callback au clic (optional)
- `color` - Couleur de fond (optional, default: white)
- `elevation` - Hauteur de l'ombre (optional, default: 4)
- `borderRadius` - Bordures arrondies (optional)

---

### 2. **StatCard**
Carte de statistique avec icône, valeur et titre.

```dart
StatCard(
  title: 'Patients',
  value: '156',
  icon: Icons.people,
  color: AppColors.primary,
  onTap: () {}, // Optionnel
)
```

**Utilisation:** Affichage de métriques clés (nombre de patients, rendez-vous, revenus, etc.)

---

### 3. **SectionHeader**
En-tête de section avec titre et action optionnelle.

```dart
SectionHeader(
  title: 'Prochains rendez-vous',
  actionText: 'Voir tout',
  onActionTap: () {},
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

**Utilisation:** Séparer visuellement les sections d'une page avec un titre et un lien "Voir plus".

---

### 4. **QuickSearchCard**
Carte de recherche rapide avec gradient et filtres de spécialités.

```dart
QuickSearchCard(
  onTap: () {
    // Navigation vers la page de recherche
  },
)
```

**Fonctionnalités:**
- Design gradient attractif
- Icône de recherche
- 4 filtres rapides (Médecin généraliste, Dentiste, Dermatologue, Pédiatre)
- Animation au clic

**Utilisation:** Page d'accueil patient pour accès rapide à la recherche de professionnels.

---

### 5. **AppointmentCard**
Carte de rendez-vous avec informations médecin et horaires.

```dart
AppointmentCard(
  doctorName: 'Dr. Marie Dubois',
  specialty: 'Cardiologue',
  date: '12 Janvier 2024',
  time: '14:30',
  avatarUrl: 'https://...', // Optionnel
  onTap: () {}, // Voir détails
  onCancel: () {}, // Annuler RDV (optionnel)
)
```

**Fonctionnalités:**
- Avatar du médecin (placeholder si non fourni)
- Nom et spécialité
- Badge date/heure stylisé
- Bouton d'annulation optionnel

**Utilisation:** Affichage des rendez-vous à venir (patient) ou du jour (professionnel).

---

### 6. **PatientListCard**
Carte patient pour les professionnels de santé.

```dart
PatientListCard(
  patientName: 'Marie Dubois',
  patientId: 'PAT001234',
  lastVisit: '12 Jan 2024',
  nextAppointment: '15 Jan 2024', // Optionnel
  avatarUrl: 'https://...', // Optionnel
  onTap: () {}, // Voir dossier patient
)
```

**Fonctionnalités:**
- Avatar patient
- ID patient
- Dernière visite
- Badge "Prochain RDV" si rendez-vous planifié
- Navigation vers le dossier patient

**Utilisation:** Liste de patients pour les professionnels.

---

### 7. **AgendaSlotCard**
Créneau horaire de l'agenda professionnel.

```dart
AgendaSlotCard(
  time: '09:00',
  patientName: 'Marie Dubois',
  appointmentType: 'Consultation',
  isCompleted: false,
  patientAvatarUrl: 'https://...', // Optionnel
  onTap: () {}, // Voir détails
  onMarkComplete: () {}, // Marquer comme terminé
)
```

**Fonctionnalités:**
- Badge horaire stylisé
- Avatar et nom du patient
- Icône dynamique selon le type (consultation, téléconsultation, urgence, suivi)
- État visuel (complété = fond vert)
- Bouton "Marquer comme terminé"

**Utilisation:** Agenda du jour pour les professionnels.

---

## 📄 Pages implémentées

### **PatientHomePage** (`/lib/features/patient/presentation/pages/patient_home_page.dart`)

**Structure:**
1. **AppBar** avec salutation personnalisée et notifications
2. **QuickSearchCard** - Recherche de professionnels
3. **StatCards** - Rendez-vous (3) et Ordonnances (12)
4. **Actions rapides** - Téléconsultation et Pharmacies
5. **Section rendez-vous** - Liste des prochains RDV avec AppointmentCard
6. **Spécialités populaires** - Grille horizontale

**Navigation:** 5 onglets (Accueil, Rendez-vous, Dossier, Messages, Profil)

---

### **DoctorHomePage** (`/lib/features/doctor/presentation/pages/doctor_home_page.dart`)

**Structure:**
1. **AppBar** avec salutation Dr. [Nom] et notifications
2. **StatCards** (2x2 grid):
   - Patients: 156
   - Aujourd'hui: 8 RDV
   - En attente: 3 patients
   - Revenus: 2.4K €
3. **Actions rapides** - Nouveau patient et Téléconsultation
4. **Agenda du jour** - 3 créneaux avec AgendaSlotCard
5. **Patients récents** - 2 patients avec PatientListCard

**Navigation:** 5 onglets (Tableau de bord, Agenda, Patients, Messages, Profil)

---

## 🎨 Thème et couleurs

Tous les widgets utilisent `AppColors` défini dans `/lib/core/theme/app_colors.dart`:
- `primary` - Couleur principale
- `secondary` - Couleur secondaire
- `accent` - Couleur d'accent
- `success` - Vert pour succès/validation
- `warning` - Orange pour avertissements
- `error` - Rouge pour erreurs
- `textPrimary` - Texte principal
- `textSecondary` - Texte secondaire

---

## 🚀 Import simplifié

Au lieu d'importer chaque widget individuellement:
```dart
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/stat_card.dart';
// etc...
```

Utilisez l'export unifié:
```dart
import '../../../../shared/widgets/widgets.dart';
```

---

## 📝 TODO & Prochaines étapes

### ✅ Complété
- [x] Structure de navigation (Bottom Nav)
- [x] Page d'accueil Patient avec UI complète
- [x] Page d'accueil Professionnel avec UI complète
- [x] Widgets réutilisables (7 widgets)

### 🔄 À implémenter
- [ ] Module de recherche de professionnels (filtres, Firestore)
- [ ] Système de réservation de rendez-vous
- [ ] Gestion d'agenda pour professionnels (calendar)
- [ ] Carte des pharmacies de garde (Google Maps)
- [ ] Système de notifications push (FCM)
- [ ] Pages de détails (rendez-vous, patient, etc.)
- [ ] Intégration des données réelles (Firestore queries)

---

## 💡 Bonnes pratiques

1. **Widgets privés vs publics:**
   - Widgets réutilisables → `/lib/shared/widgets/`
   - Widgets spécifiques à une page → Classe privée `_WidgetName` dans la même page

2. **Gestion des états:**
   - Données mockées pour la démo UI
   - Intégration BLoC pour la logique métier (à venir)

3. **Navigation:**
   - Utiliser `Navigator.push()` pour les transitions
   - TODO: Implémenter named routes dans `/lib/core/routes/`

4. **Performances:**
   - `const` constructors partout où possible
   - ListView.builder pour listes longues
   - Image caching pour les avatars

---

## 🐛 Debug

Si vous rencontrez des erreurs:

1. **Import manquant:** Vérifiez que `widgets.dart` exporte bien tous les widgets
2. **Hot reload:** Parfois un hot restart est nécessaire après ajout de widgets
3. **Couleurs undefined:** Assurez-vous que `AppColors` est importé
4. **Navigation:** Vérifiez que `AuthWrapper` route bien selon `user.role`

```bash
# Rebuild complet
flutter clean
flutter pub get
flutter run
```
