# 📅 Agenda Professionnel - Documentation

## Vue d'ensemble

L'agenda professionnel est un système de gestion de calendrier intelligent pour les médecins, permettant de visualiser, gérer et interagir avec leurs rendez-vous de manière intuitive et responsive.

## 📁 Fichier Principal

**Localisation:** `lib/features/doctor/presentation/pages/agenda_page.dart`  
**Lignes de code:** ~900 lignes  
**Package utilisé:** `table_calendar: ^3.1.2`

## 🎨 Fonctionnalités Principales

### 1. Calendrier Mensuel Interactif

#### Vue TableCalendar
- **Formats disponibles:**
  - Mois complet (défaut)
  - 2 semaines
  - Semaine

- **Navigation:**
  - Flèches gauche/droite pour changer de mois
  - Menu dropdown pour changer de format
  - Bouton refresh pour actualiser les données

- **Indicateurs visuels:**
  - Jour d'aujourd'hui: cercle bleu clair
  - Jour sélectionné: cercle bleu foncé (AppColors.primary)
  - Jours avec rendez-vous: markers colorés (jusqu'à 3 points)
  - Week-end: texte rouge

#### Configuration
```dart
TableCalendar(
  locale: 'fr_FR',
  startingDayOfWeek: StartingDayOfWeek.monday,
  firstDay: DateTime.now() - 365 jours,
  lastDay: DateTime.now() + 365 jours,
  eventLoader: _getEventsForDay,
)
```

### 2. Layouts Responsives

#### Mobile (< 650px)
- Calendrier en haut
- Liste des RDV en bas (timeline vertical)
- Vue complète en scroll

#### Tablette (650px - 1100px)
- Calendrier en haut
- Grid 2 colonnes pour les RDV

#### Desktop (> 1100px)
- Split screen:
  - Calendrier à gauche (40% largeur)
  - Liste timeline à droite (60% largeur)
  - Vue simultanée sans scroll

### 3. Vue Timeline des Rendez-vous

#### Composant: `_AppointmentTimelineCard`

**Design:**
- Ligne de temps verticale avec connecteurs
- Boîte horaire colorée selon le statut
- Carte d'information à droite avec:
  - Icône type (vidéo/hôpital)
  - Nom du patient
  - Badge de statut
  - Heure complète
  - Type de consultation

**Code structure:**
```dart
Row(
  Timeline (60x60px box + vertical line),
  Card with patient info,
)
```

**Tri:** Automatique par heure croissante

### 4. Bottom Sheet Détails

**Déclenchement:** Clic sur n'importe quelle carte de RDV

**Contenu:**
- Avatar circulaire avec icône
- Nom du patient + badge statut
- Détails complets:
  - Date (formatée en français)
  - Heure (plage complète)
  - Type de consultation
  - Tarif
  - Motif (si renseigné)

**Actions contextuelles:**

**Si statut = 'pending':**
- Bouton "Refuser" (rouge)
- Bouton "Confirmer" (vert)

**Si statut = 'confirmed' ET type = 'telemedicine':**
- Bouton "Démarrer la consultation" (bleu)

**Draggable:** Oui, avec handle en haut

### 5. Gestion des Statuts

#### Couleurs des statuts
```dart
- pending (En attente): Orange
- confirmed (Confirmé): Vert
- completed (Terminé): Bleu
- cancelled (Annulé): Rouge
```

#### Actions disponibles

**Confirmer un RDV:**
1. Clic sur "Confirmer"
2. Update Firestore: `status: 'confirmed'` + `confirmedAt: timestamp`
3. SnackBar de succès
4. Reload automatique

**Refuser un RDV:**
1. Clic sur "Refuser"
2. Dialog avec champ texte pour raison
3. Update Firestore: `status: 'cancelled'` + `cancellationReason` + `cancelledAt`
4. SnackBar orange
5. Reload automatique

### 6. États Vides

**Message affiché quand aucun RDV:**
- Icône calendrier grisée (80px)
- Texte "Aucun rendez-vous"
- Date sélectionnée formatée

**Centré verticalement et horizontalement**

## 🔄 Flux de Données

### Chargement Initial
```dart
initState() → _loadAppointments()
  ↓
Query Firestore: appointments where doctorId = currentUser
  ↓
Grouper par date (DateTime sans heure)
  ↓
Stocker dans Map<DateTime, List<Appointment>>
  ↓
Mettre à jour _selectedEvents pour la date sélectionnée
```

### Sélection d'une Date
```dart
User clique sur une date
  ↓
_onDaySelected() appelé
  ↓
setState: _selectedDay = nouvelleDateDate
  ↓
_selectedEvents.value = _getEventsForDay(nouvelleDatelected)
  ↓
ValueListenableBuilder rebuild la liste
```

### Actualisation Manuelle
```dart
User clique sur refresh icon
  ↓
_loadAppointments() relance la query
  ↓
Rebuild complet avec nouvelles données
```

## 📊 Architecture des Composants

### Widgets Principaux

1. **AgendaPage** (StatefulWidget)
   - Gère l'état global
   - Contient le TableCalendar
   - Orchestre les layouts responsives

2. **_AppointmentTimelineCard** (StatelessWidget)
   - Affichage timeline avec ligne verticale
   - Optimisé pour mobile/desktop

3. **_AppointmentCard** (StatelessWidget)
   - Carte compacte pour grid view
   - Utilisé en tablette

4. **_DetailRow** (StatelessWidget)
   - Ligne de détail réutilisable
   - Icône + Label + Valeur

### State Management

**Variables d'état:**
```dart
- _selectedEvents: ValueNotifier<List<Appointment>>
- _calendarFormat: CalendarFormat (month/twoWeeks/week)
- _focusedDay: DateTime
- _selectedDay: DateTime?
- _events: Map<DateTime, List<Appointment>>
- _isLoading: bool
```

**Pourquoi ValueNotifier?**
- Performance optimisée
- Rebuild seulement la liste des RDV
- Calendar reste stable

## 🎯 Avantages du Design

### UX Médecin
1. **Vision globale:** Voir tout le mois en un coup d'œil
2. **Markers visuels:** Savoir quels jours ont des RDV
3. **Détails rapides:** Un clic pour voir tout
4. **Actions rapides:** Confirmer/Refuser depuis le détail
5. **Formats flexibles:** Adapter la vue selon besoin

### Performance
1. **Chargement unique:** Une seule query Firestore au démarrage
2. **Tri local:** Pas de re-query à chaque sélection
3. **ValueNotifier:** Rebuilds ciblés
4. **Lazy loading:** Timeline construit seulement les visibles

### Responsive
1. **Adaptation automatique:** 3 layouts différents
2. **Optimal pour chaque écran:**
   - Mobile: Max info en scroll
   - Tablette: Grid équilibré
   - Desktop: Split view productive

## 🔧 Personnalisation

### Changer les couleurs
```dart
// Dans _getStatusColor()
case 'pending': return Colors.orange; // Modifier ici
```

### Changer le format de date
```dart
DateFormat('EEEE d MMMM yyyy', 'fr_FR') // Format français complet
DateFormat('dd/MM/yyyy', 'fr_FR')       // Format court
```

### Ajuster les markers
```dart
calendarStyle: CalendarStyle(
  markersMaxCount: 3, // Nombre max de points par jour
  markerDecoration: BoxDecoration(
    color: AppColors.accent, // Couleur des markers
  ),
)
```

### Modifier l'intervalle de dates
```dart
firstDay: DateTime.now().subtract(Duration(days: 90)),  // 3 mois avant
lastDay: DateTime.now().add(Duration(days: 180)),       // 6 mois après
```

## 🚀 Fonctionnalités Futures Possibles

### Court terme
- [ ] Filtre par statut dans l'agenda
- [ ] Recherche de patient dans l'agenda
- [ ] Export PDF de l'agenda du mois
- [ ] Statistiques du jour (nb RDV, CA estimé)

### Moyen terme
- [ ] Drag & drop pour déplacer un RDV
- [ ] Notification avant RDV
- [ ] Blocage de créneaux (congés, pause)
- [ ] Vue semaine détaillée (horaire par horaire)

### Long terme
- [ ] Synchronisation Google Calendar
- [ ] Rappels automatiques patients
- [ ] Gestion salle d'attente virtuelle
- [ ] Analytics avancées (taux annulation, heures de pointe)

## 📝 Notes Techniques

### Dépendances requises
```yaml
table_calendar: ^3.1.2
intl: ^0.20.2
cloud_firestore: ^5.4.4
```

### Initialisation locale française
**Important:** Dans `main.dart`, initialiser:
```dart
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}
```

### Structure Firestore requise
```
appointments/
  {appointmentId}/
    - doctorId: string
    - patientId: string
    - patientName: string
    - date: Timestamp
    - timeSlot: string
    - type: string (physical/telemedicine)
    - status: string (pending/confirmed/completed/cancelled)
    - fee: number
    - reason: string (optional)
```

### Index Firestore
**Requis:**
- `appointments` collection:
  - doctorId (ASC) + date (ASC)

## 🎨 Styling & Thème

### Palette utilisée
- Primary: `AppColors.primary` (bleu médical)
- Accent: `AppColors.accent` (markers)
- Error: `AppColors.error` (week-end)
- Status colors: Orange/Vert/Bleu/Rouge

### Spacing constants
- Card padding: 12px
- Section spacing: 16px
- Timeline width: 60px
- Avatar radius: 30px

### Border radius
- Cards: 12px
- Status badges: 8-12px
- Buttons: défaut Material

---

**Créé:** Janvier 2025  
**Version:** 1.0  
**Statut:** ✅ Production Ready
