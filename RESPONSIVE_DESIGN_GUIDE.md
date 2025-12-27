# 📱 Guide de Responsive Design - Doctolo

## Vue d'ensemble

L'application Doctolo implémente un design **moderne, responsive et adaptatif** qui s'adapte automatiquement aux différentes tailles d'écran (mobile, tablette, desktop).

## 🎨 Système de Responsive

### Breakpoints

```dart
- Mobile:  < 650px
- Tablette: 650px - 1100px
- Desktop: > 1100px
```

### Widget ResponsiveLayout

Situé dans `lib/shared/widgets/responsive_layout.dart`

#### Composants principaux:

1. **ResponsiveLayout**
   - Affiche différents widgets selon la taille d'écran
   ```dart
   ResponsiveLayout(
     mobile: MobileWidget(),
     tablet: TabletWidget(),  // optionnel, utilise mobile par défaut
     desktop: DesktopWidget(), // optionnel, utilise tablet ou mobile
   )
   ```

2. **ResponsivePadding**
   - Ajuste automatiquement le padding selon l'écran
   - Mobile: 16px horizontal
   - Tablette: 32px horizontal
   - Desktop: 48px horizontal

3. **ResponsiveGrid**
   - Grille adaptative
   - Mobile: 1 colonne
   - Tablette: 2 colonnes
   - Desktop: 3 colonnes

4. **ResponsiveRow**
   - Passe de Row (desktop/tablet) à Column (mobile)
   - Parfait pour les layouts flexibles

### Extensions Context

```dart
context.isMobile   // bool
context.isTablet   // bool
context.isDesktop  // bool

context.responsiveValue(
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
)
```

## 📄 Pages Responsives Implémentées

### 1. Page de Profil Professionnel (`doctor_profile_page.dart`)

#### Adaptations:
- **SliverAppBar**: Header collapsible avec image du médecin
- **Stats Row**: Devient une colonne sur mobile avec ResponsiveRow
- **Cartes de consultation**: S'empilent verticalement sur mobile
- **Taille des éléments**: Icônes et textes ajustés selon l'écran

```dart
// Avant (fixe)
Row(
  children: [
    Expanded(child: StatItem(...)),
    Expanded(child: StatItem(...)),
    Expanded(child: StatItem(...)),
  ],
)

// Après (responsive)
ResponsiveRow(
  children: [
    StatItem(...),
    StatItem(...),
    StatItem(...),
  ],
)
```

### 2. Liste des Rendez-vous (`appointments_list_page.dart`)

#### Adaptations selon l'écran:

**Mobile:**
- ListView vertical
- 1 carte par ligne
- Onglets scrollables

**Tablette:**
- GridView 2 colonnes
- Espacement 16px
- childAspectRatio: 1.2

**Desktop:**
- GridView 3 colonnes
- Espacement 20px
- childAspectRatio: 1.3

```dart
ResponsiveLayout(
  mobile: _buildMobileList(context, appointments),
  tablet: _buildTabletGrid(context, appointments),
  desktop: _buildDesktopGrid(context, appointments),
)
```

## 🎯 Bonnes Pratiques

### 1. Utiliser ResponsiveRow au lieu de Row pour les layouts horizontaux

❌ **Mauvais:**
```dart
Row(
  children: [
    Expanded(child: Widget1()),
    SizedBox(width: 16),
    Expanded(child: Widget2()),
  ],
)
```

✅ **Bon:**
```dart
ResponsiveRow(
  spacing: 16,
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

### 2. Utiliser ResponsivePadding pour les marges cohérentes

```dart
ResponsivePadding(
  child: Column(
    children: [...],
  ),
)
```

### 3. Ajuster les tailles de police et icônes

```dart
Icon(
  Icons.star,
  size: context.isMobile ? 20 : 24,
)

Text(
  'Title',
  style: TextStyle(
    fontSize: context.responsiveValue(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    ),
  ),
)
```

### 4. Gérer les grilles adaptatives

Pour les listes de cartes, utilisez ResponsiveGrid:

```dart
ResponsiveGrid(
  spacing: 16,
  children: items.map((item) => ItemCard(item: item)).toList(),
)
```

### 5. TabBar scrollable sur mobile

```dart
TabBar(
  isScrollable: context.isMobile,
  tabs: [...],
)
```

## 🎪 Composants Responsive Existants

### Cartes de Rendez-vous
- Adaptation automatique de la taille
- Actions regroupées sur mobile
- Plus d'informations visibles sur desktop

### Cartes de Type de Consultation
- Layout horizontal sur desktop
- Layout vertical sur mobile
- Espacement ajusté

### Statistiques
- Row sur desktop/tablette
- Column sur mobile
- Bordures ajoutées pour meilleure séparation

## 🔧 Migration d'un Composant Vers Responsive

### Étape 1: Importer le helper
```dart
import '../../../../shared/widgets/responsive_layout.dart';
```

### Étape 2: Identifier les zones fixes
Cherchez les Row, Column, Padding avec valeurs fixes

### Étape 3: Remplacer par les équivalents responsive
- `Row` → `ResponsiveRow`
- `Padding` → `ResponsivePadding`
- `GridView` → Wrapper dans `ResponsiveLayout`
- Tailles fixes → `context.responsiveValue()`

### Étape 4: Tester sur différentes tailles
- Simulateur iPhone (mobile)
- Simulateur iPad (tablette)
- Redimensionner la fenêtre sur desktop

## 📊 Exemples Concrets

### Profil du Médecin - Stats

**Avant:**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _StatItem(...),
    Container(width: 1, height: 40, color: Colors.grey[300]),
    _StatItem(...),
    Container(width: 1, height: 40, color: Colors.grey[300]),
    _StatItem(...),
  ],
)
```

**Après:**
```dart
ResponsiveRow(
  spacing: 8,
  children: [
    _StatItem(...),
    _StatItem(...),
    _StatItem(...),
  ],
)

// Dans _StatItem
Container(
  padding: EdgeInsets.symmetric(
    vertical: context.isMobile ? 12 : 16,
    horizontal: context.isMobile ? 8 : 16,
  ),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(12),
  ),
  child: ...,
)
```

### Liste de Rendez-vous

**Fonction de construction adaptative:**
```dart
Widget _buildLayout(BuildContext context, List<Doc> appointments) {
  if (context.isMobile) {
    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) => AppointmentCard(...),
    );
  }
  
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.isTablet ? 2 : 3,
      crossAxisSpacing: context.responsiveValue(mobile: 12, tablet: 16, desktop: 20),
      mainAxisSpacing: context.responsiveValue(mobile: 12, tablet: 16, desktop: 20),
    ),
    itemBuilder: (context, index) => AppointmentCard(...),
  );
}
```

## 🚀 Prochaines Étapes

- [ ] Ajouter des tests de responsive design
- [ ] Implémenter un mode paysage optimisé pour mobile
- [ ] Créer des variantes desktop avec sidebars
- [ ] Optimiser les animations pour chaque taille d'écran

## 📝 Notes Importantes

1. **Performance**: ResponsiveLayout rebuild lors du resize, utilisez-le judicieusement
2. **Consistency**: Utilisez toujours les mêmes breakpoints dans toute l'app
3. **Testing**: Testez sur vrais appareils quand possible, pas seulement simulateurs
4. **Accessibilité**: Les tailles de police et boutons doivent rester accessibles sur tous les écrans

---

**Créé par:** Assistant AI
**Date:** Janvier 2025
**Version:** 1.0
