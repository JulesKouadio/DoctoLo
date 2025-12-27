import 'package:flutter/material.dart';

/// Breakpoints pour le responsive design
class Breakpoints {
  // Mobile: < 600
  static const double mobile = 600;
  // Tablet: 600 - 1024
  static const double tablet = 1024;
  // Desktop: > 1024
  static const double desktop = 1024;
}

/// Extension pour simplifier les vérifications de type d'écran
extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < Breakpoints.mobile;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= Breakpoints.mobile &&
      MediaQuery.of(this).size.width < Breakpoints.desktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= Breakpoints.desktop;

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
}

/// Classe pour gérer le responsive design
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
      MediaQuery.of(context).size.width < Breakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktop;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (size.width >= Breakpoints.desktop) {
      return desktop;
    } else if (size.width >= Breakpoints.mobile) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Utilitaires pour dimensions adaptatives
class ResponsiveSize {
  final BuildContext context;

  ResponsiveSize(this.context);

  /// Largeur adaptative basée sur le type d'écran
  double width({required double mobile, double? tablet, double? desktop}) {
    if (context.isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (context.isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Hauteur adaptative basée sur le type d'écran
  double height({required double mobile, double? tablet, double? desktop}) {
    if (context.isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (context.isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Padding adaptatif
  EdgeInsets padding({
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (context.isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (context.isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Taille de police adaptative
  double fontSize({required double mobile, double? tablet, double? desktop}) {
    if (context.isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (context.isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Nombre de colonnes pour une grille
  int gridCrossAxisCount({required int mobile, int? tablet, int? desktop}) {
    if (context.isDesktop) {
      return desktop ?? tablet ?? mobile;
    } else if (context.isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Largeur maximale pour le contenu (utile pour desktop)
  double get maxContentWidth {
    if (context.isDesktop) {
      return 1200;
    } else if (context.isTablet) {
      return 800;
    }
    return double.infinity;
  }
}

/// Builder pour un layout responsive avec largeur maximale
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    final width = maxWidth ?? responsive.maxContentWidth;

    if (context.isDesktop && centerContent) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: width),
          child: child,
        ),
      );
    }

    return child;
  }
}

/// Grid adaptative
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    final columns = responsive.gridCrossAxisCount(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
