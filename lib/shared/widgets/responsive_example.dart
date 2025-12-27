import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/stat_card.dart';

/// Exemple de widget responsive adapté pour mobile, tablet et desktop
class ResponsiveExampleWidget extends StatelessWidget {
  const ResponsiveExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);

    return ResponsiveLayout(
      child: CustomScrollView(
        slivers: [
          // AppBar responsive
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Page Responsive',
              style: TextStyle(
                fontSize: responsive.fontSize(
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Contenu avec padding adaptatif
          SliverPadding(
            padding: responsive.padding(
              mobile: const EdgeInsets.all(16),
              tablet: const EdgeInsets.all(24),
              desktop: const EdgeInsets.all(32),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section 1: Grille de statistiques
                _buildStatsSection(context, responsive),

                SizedBox(
                  height: responsive.height(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),

                // Section 2: Layout conditionnel (colonne mobile, ligne desktop)
                _buildConditionalLayout(context),

                SizedBox(
                  height: responsive.height(
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),

                // Section 3: Grille adaptative
                _buildAdaptiveGrid(context, responsive),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, ResponsiveSize responsive) {
    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      spacing: responsive.width(mobile: 12, tablet: 16, desktop: 20),
      runSpacing: responsive.height(mobile: 12, tablet: 16, desktop: 20),
      children: const [
        StatCard(
          title: 'Total',
          value: '156',
          icon: CupertinoIcons.person_2,
          color: AppColors.primary,
        ),
        StatCard(
          title: 'Actif',
          value: '42',
          icon: CupertinoIcons.checkmark_circle,
          color: AppColors.success,
        ),
        StatCard(
          title: 'En attente',
          value: '8',
          icon: CupertinoIcons.clock,
          color: AppColors.warning,
        ),
        StatCard(
          title: 'Terminé',
          value: '106',
          icon: CupertinoIcons.checkmark_seal,
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildConditionalLayout(BuildContext context) {
    final content1 = CustomCard(
      child: Container(
        height: 150,
        alignment: Alignment.center,
        child: const Text('Contenu 1'),
      ),
    );

    final content2 = CustomCard(
      child: Container(
        height: 150,
        alignment: Alignment.center,
        child: const Text('Contenu 2'),
      ),
    );

    // Sur desktop: 2 colonnes côte à côte
    if (context.isDesktop) {
      return Row(
        children: [
          Expanded(child: content1),
          const SizedBox(width: 20),
          Expanded(child: content2),
        ],
      );
    }

    // Sur mobile/tablet: empilé verticalement
    return Column(children: [content1, const SizedBox(height: 16), content2]);
  }

  Widget _buildAdaptiveGrid(BuildContext context, ResponsiveSize responsive) {
    final columns = responsive.gridCrossAxisCount(
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: responsive.width(mobile: 12, tablet: 16, desktop: 20),
        mainAxisSpacing: responsive.height(mobile: 12, tablet: 16, desktop: 20),
        childAspectRatio: 1.2,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return CustomCard(
          child: Center(
            child: Text(
              'Item ${index + 1}',
              style: TextStyle(
                fontSize: responsive.fontSize(
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Navigation adaptative: Bottom bar (mobile/tablet) ou Rail (desktop)
class ResponsiveNavigationExample extends StatefulWidget {
  const ResponsiveNavigationExample({super.key});

  @override
  State<ResponsiveNavigationExample> createState() =>
      _ResponsiveNavigationExampleState();
}

class _ResponsiveNavigationExampleState
    extends State<ResponsiveNavigationExample> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Home')),
    const Center(child: Text('Search')),
    const Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    // Sur desktop, utiliser une navigation latérale
    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.house),
                  selectedIcon: Icon(CupertinoIcons.house_fill),
                  label: Text('Accueil'),
                ),
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.search),
                  selectedIcon: Icon(CupertinoIcons.search),
                  label: Text('Recherche'),
                ),
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.person),
                  selectedIcon: Icon(CupertinoIcons.person_fill),
                  label: Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      );
    }

    // Sur mobile/tablet, utiliser la barre de navigation du bas
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
