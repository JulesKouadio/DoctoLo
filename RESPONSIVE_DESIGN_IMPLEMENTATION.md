# Guide de Responsive Design pour Doctolo

## Vue d'ensemble

Le système responsive est maintenant configuré avec les utilitaires dans `/lib/core/utils/responsive.dart`. 
Voici comment l'appliquer à travers l'application.

## Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 1024px  
- **Desktop**: > 1024px

## Modifications Appliquées

### 1. Utilitaires Responsive (`/lib/core/utils/responsive.dart`)

**Créé** avec :
- `Breakpoints` - Constantes de largeur d'écran
- `ResponsiveContext` - Extensions pour vérifier le type d'écran
- `Responsive` - Widget pour layouts conditionnels
- `ResponsiveSize` - Utilitaires pour dimensions adaptatives
- `ResponsiveLayout` - Wrapper pour largeur maximale
- `ResponsiveGrid` - Grille adaptative

### 2. Navigation Adaptative

#### Mobile/Tablet
- `BottomNavigationBar` avec 5 onglets

#### Desktop
- `NavigationRail` latérale
- Layout en 2 colonnes (rail + contenu)

**Implémentation dans `patient_home_page.dart` et `doctor_home_page.dart`:**

```dart
@override
Widget build(BuildContext context) {
  if (context.isDesktop) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(context, l10n),
          const VerticalDivider(width: 1),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
    );
  }
  
  return Scaffold(
    body: _pages[_currentIndex],
    bottomNavigationBar: BottomNavigationBar(...),
  );
}

Widget _buildNavigationRail(BuildContext context, AppLocalizations l10n) {
  return NavigationRail(
    selectedIndex: _currentIndex,
    onDestinationSelected: (index) {
      setState(() => _currentIndex = index);
    },
    labelType: NavigationRailLabelType.all,
    destinations: [...],
  );
}
```

### 3. Padding et Espacement Adaptatifs

Remplacer les valeurs fixes par des valeurs responsives :

**Avant:**
```dart
padding: const EdgeInsets.all(16),
const SizedBox(height: 24),
```

**Après:**
```dart
final responsive = ResponsiveSize(context);

padding: responsive.padding(
  mobile: const EdgeInsets.all(16),
  tablet: const EdgeInsets.all(24),
  desktop: const EdgeInsets.all(32),
),

SizedBox(height: responsive.height(
  mobile: 24,
  tablet: 28, 
  desktop: 32,
)),
```

### 4. Layouts Conditionnels

#### Grilles Adaptatives

**Avant:**
```dart
GridView.count(
  crossAxisCount: 2,
  children: [...],
)
```

**Après:**
```dart
ResponsiveGrid(
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  children: [...],
)
```

#### Wrapping avec ResponsiveLayout

```dart
return ResponsiveLayout(
  child: CustomScrollView(...),
);
```

Cela centre automatiquement le contenu sur desktop avec une largeur maximale de 1200px.

### 5. Tailles de Police Adaptatives

```dart
final responsive = ResponsiveSize(context);

Text(
  'Titre',
  style: TextStyle(
    fontSize: responsive.fontSize(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    ),
  ),
)
```

### 6. Cartes Statistiques (StatCard)

Les StatCards s'adaptent automatiquement grâce au système de grille:

```dart
// Mobile: 2 colonnes
// Tablet: 3 colonnes
// Desktop: 4 colonnes

ResponsiveGrid(
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  spacing: responsive.width(mobile: 12, tablet: 16, desktop: 20),
  children: [
    StatCard(...),
    StatCard(...),
    StatCard(...),
    StatCard(...),
  ],
)
```

### 7. Liste de Rendez-vous/Patients

Sur desktop, afficher plus d'informations ou utiliser un layout différent:

```dart
if (context.isDesktop) {
  return _DesktopAppointmentCard(...);
} else {
  return AppointmentCard(...);
}
```

## Modifications Par Page

### PatientHomePage

1. **Import responsive:**
```dart
import '../../../../core/utils/responsive.dart';
```

2. **Ajouter NavigationRail pour desktop**

3. **Wrapper le contenu dans ResponsiveLayout:**
```dart
return ResponsiveLayout(
  child: CustomScrollView(...),
);
```

4. **Adapter les paddings et espacements:**
- SliverPadding: responsive.padding()
- SizedBox: responsive.height() / responsive.width()
- Row spacing: responsive.width()

5. **Adapter la grille des spécialités:**
```dart
ResponsiveGrid(
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  children: specialties.map((s) => _SpecialtyCard(s)).toList(),
)
```

### DoctorHomePage

Même approche que PatientHomePage:

1. Import responsive
2. NavigationRail pour desktop
3. ResponsiveLayout wrapper
4. Paddings adaptatifs
5. Grille adaptative pour les StatCards:

```dart
ResponsiveGrid(
  mobileColumns: 2,
  tabletColumns: 4,
  desktopColumns: 4,
  children: [
    StatCard(title: 'Patients', value: '156', ...),
    StatCard(title: 'Aujourd\'hui', value: '8', ...),
    StatCard(title: 'En attente', value: '3', ...),
    StatCard(title: 'Revenus', value: '2.4K€', ...),
  ],
)
```

### Pages de Liste (Appointments, Patients, Messages)

1. **Largeur maximale sur desktop:**
```dart
return ResponsiveLayout(
  maxWidth: 900,
  child: ListView(...),
);
```

2. **Padding adaptatif:**
```dart
padding: ResponsiveSize(context).padding(
  mobile: const EdgeInsets.all(16),
  tablet: const EdgeInsets.all(24),
  desktop: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
),
```

3. **Cartes avec espacement adaptatif:**
```dart
final responsive = ResponsiveSize(context);
ListView.separated(
  itemBuilder: (context, index) => AppointmentCard(...),
  separatorBuilder: (context, index) => SizedBox(
    height: responsive.height(mobile: 12, tablet: 16, desktop: 20),
  ),
  itemCount: appointments.length,
)
```

### Pages de Formulaires (AgendaPage, NewAppointment, etc.)

1. **Layout 2 colonnes sur desktop:**
```dart
if (context.isDesktop) {
  return Row(
    children: [
      Expanded(child: _LeftColumn()),
      const SizedBox(width: 32),
      Expanded(child: _RightColumn()),
    ],
  );
}
return Column(children: [_LeftColumn(), _RightColumn()]);
```

2. **Largeur des champs de formulaire:**
```dart
Container(
  constraints: BoxConstraints(
    maxWidth: context.isDesktop ? 600 : double.infinity,
  ),
  child: TextFormField(...),
)
```

## Widgets Personnalisés à Adapter

### QuickSearchCard

```dart
// Ajuster la hauteur selon l'écran
final responsive = ResponsiveSize(context);
Container(
  padding: responsive.padding(
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(20),
    desktop: const EdgeInsets.all(24),
  ),
  child: Column(
    children: [
      TextField(
        style: TextStyle(
          fontSize: responsive.fontSize(
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
      ),
      // ...
    ],
  ),
)
```

### AppointmentCard / PatientListCard

```dart
// Sur desktop, layout horizontal au lieu de vertical
if (context.isDesktop) {
  return _HorizontalLayout();
}
return _VerticalLayout();
```

## Checklist de Vérification

- [ ] Navigation adaptée (Bottom bar mobile, Rail desktop)
- [ ] Paddings responsives (16/24/32)
- [ ] Espacement entre éléments responsive
- [ ] Grilles avec colonnes adaptatives
- [ ] Largeur maximale sur desktop (1200px)
- [ ] Tailles de police adaptatives
- [ ] Images/icônes adaptées en taille
- [ ] Formulaires centrés sur desktop
- [ ] Listes avec espacement adaptatif
- [ ] Dialogs avec largeur adaptée

## Exemple Complet

Voici un exemple complet d'une page adaptée:

```dart
import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    
    return ResponsiveLayout(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(...),
          
          SliverPadding(
            padding: responsive.padding(
              mobile: const EdgeInsets.all(16),
              tablet: const EdgeInsets.all(24),
              desktop: const EdgeInsets.all(32),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Titre
                Text(
                  'Titre Principal',
                  style: TextStyle(
                    fontSize: responsive.fontSize(
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: responsive.height(
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                )),
                
                // Grille de cartes
                ResponsiveGrid(
                  mobileColumns: 2,
                  tabletColumns: 3,
                  desktopColumns: 4,
                  spacing: responsive.width(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                  children: List.generate(
                    8,
                    (index) => Card(child: Text('Item $index')),
                  ),
                ),
                
                SizedBox(height: responsive.height(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                )),
                
                // Contenu conditionnel
                if (context.isDesktop)
                  Row(
                    children: [
                      Expanded(child: _LeftContent()),
                      SizedBox(width: 32),
                      Expanded(child: _RightContent()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _LeftContent(),
                      SizedBox(height: 16),
                      _RightContent(),
                    ],
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Tests Recommandés

1. **Mobile (< 600px):**
   - iPhone SE (375x667)
   - iPhone 13 (390x844)

2. **Tablet (600-1024px):**
   - iPad (768x1024)
   - iPad Pro 11" (834x1194)

3. **Desktop (> 1024px):**
   - MacBook Pro 13" (1280x800)
   - MacBook Pro 16" (1728x1117)
   - Desktop HD (1920x1080)

## Performance

- Les vérifications responsive (`context.isMobile`, etc.) sont légères
- `MediaQuery` est optimisé par Flutter
- Pas d'impact significatif sur les performances

## Maintenance

Lorsque vous créez de nouvelles pages ou widgets:

1. Toujours importer `responsive.dart`
2. Utiliser `ResponsiveLayout` comme wrapper principal
3. Utiliser `ResponsiveSize` pour les dimensions
4. Tester sur au moins 2 tailles d'écran (mobile + desktop)
5. Considérer l'orientation paysage pour les tablettes

## Ressources

- Documentation Flutter Responsive: https://flutter.dev/docs/development/ui/layout/responsive
- Material Design Responsive: https://material.io/design/layout/responsive-layout-grid.html
- Adaptive Design Guidelines: https://flutter.dev/docs/development/ui/layout/building-adaptive-apps
