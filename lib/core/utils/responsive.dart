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

/// Enum pour le type d'appareil
enum DeviceType { mobile, tablet, desktop }

/// Extension pour obtenir le type d'appareil
extension DeviceTypeExtension on BuildContext {
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    if (width >= 1024) {
      return DeviceType.desktop;
    } else if (width >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

/// Wrapper pour les formulaires responsives avec ConstrainedBox
/// Utilise le pattern de login_page.dart pour tous les formulaires
class ResponsiveFormWrapper extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final bool centerContent;
  final Color? backgroundColor;

  const ResponsiveFormWrapper({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth = 500,
    this.desktopMaxWidth = 450,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.centerContent = true,
    this.backgroundColor,
  });

  double _getMaxFormWidth(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopMaxWidth ?? 450;
      case DeviceType.tablet:
        return tabletMaxWidth ?? 500;
      case DeviceType.mobile:
        return mobileMaxWidth ?? double.infinity;
    }
  }

  EdgeInsets _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopPadding ?? const EdgeInsets.all(48.0);
      case DeviceType.tablet:
        return tabletPadding ?? const EdgeInsets.all(32.0);
      case DeviceType.mobile:
        return mobilePadding ?? const EdgeInsets.all(24.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final maxFormWidth = _getMaxFormWidth(deviceType);
    final padding = _getPadding(deviceType);

    if (centerContent) {
      return Center(
        child: SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxFormWidth),
              child: child,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxFormWidth),
        child: child,
      ),
    );
  }
}

/// Wrapper pour les pages avec contenu scrollable
/// Idéal pour les pages de paramètres, détails, etc.
class ResponsivePageWrapper extends StatelessWidget {
  final Widget child;
  final double? maxContentWidth;
  final EdgeInsets? padding;
  final bool centerHorizontally;

  const ResponsivePageWrapper({
    super.key,
    required this.child,
    this.maxContentWidth,
    this.padding,
    this.centerHorizontally = true,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final width = maxContentWidth ?? _getMaxWidth(deviceType);
    final contentPadding = padding ?? _getPadding(deviceType);

    Widget content = Padding(padding: contentPadding, child: child);

    if (deviceType != DeviceType.mobile && centerHorizontally) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: content,
        ),
      );
    }

    return content;
  }

  double _getMaxWidth(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return 900;
      case DeviceType.tablet:
        return 700;
      case DeviceType.mobile:
        return double.infinity;
    }
  }

  EdgeInsets _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
    }
  }
}

/// Helper pour obtenir des valeurs adaptatives selon le type d'appareil
class AdaptiveValues {
  final BuildContext context;

  AdaptiveValues(this.context);

  DeviceType get deviceType => context.deviceType;

  /// Retourne une valeur selon le type d'appareil
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Taille de police adaptative
  double fontSize({required double mobile, double? tablet, double? desktop}) {
    return value(mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Spacing adaptatif
  double spacing({required double mobile, double? tablet, double? desktop}) {
    return value(mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Padding adaptatif pour les boutons
  EdgeInsets buttonPadding({double? vertical, double? horizontal}) {
    final v = vertical ?? value(mobile: 16.0, tablet: 18.0, desktop: 20.0);
    final h = horizontal ?? value(mobile: 16.0, tablet: 20.0, desktop: 24.0);
    return EdgeInsets.symmetric(vertical: v!, horizontal: h!);
  }

  /// Taille d'icône adaptative
  double iconSize({required double mobile, double? tablet, double? desktop}) {
    return value(mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Nombre de colonnes pour les grilles
  int gridColumns({required int mobile, int? tablet, int? desktop}) {
    return value(mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Largeur maximale pour le contenu
  double get maxContentWidth {
    switch (deviceType) {
      case DeviceType.desktop:
        return 1200;
      case DeviceType.tablet:
        return 800;
      case DeviceType.mobile:
        return double.infinity;
    }
  }

  /// Largeur maximale pour les formulaires
  double get maxFormWidth {
    switch (deviceType) {
      case DeviceType.desktop:
        return 450;
      case DeviceType.tablet:
        return 500;
      case DeviceType.mobile:
        return double.infinity;
    }
  }
}

/// Affiche un BottomSheet sur mobile ou un Dialog sur tablette/desktop
///
/// Sur mobile: affiche un BottomSheet classique avec DraggableScrollableSheet
/// Sur tablette/desktop: affiche un Dialog centré avec une largeur maximale
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(
    BuildContext context,
    ScrollController? scrollController,
  )
  builder,
  double initialChildSize = 0.7,
  double minChildSize = 0.5,
  double maxChildSize = 0.9,
  double? dialogWidth,
  double? dialogMaxHeight,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  final isDesktopOrTablet = context.isDesktop || context.isTablet;

  if (isDesktopOrTablet) {
    // Afficher un Dialog sur tablette/desktop
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (dialogContext) {
        final width = dialogWidth ?? (context.isDesktop ? 600.0 : 500.0);
        final maxHeight =
            dialogMaxHeight ?? MediaQuery.of(context).size.height * 0.85;

        return Dialog(
          backgroundColor: backgroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SingleChildScrollView(child: builder(dialogContext, null)),
            ),
          ),
        );
      },
    );
  } else {
    // Afficher un BottomSheet sur mobile
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) =>
              builder(context, scrollController),
        ),
      ),
    );
  }
}

/// Affiche un BottomSheet simple (sans DraggableScrollableSheet) sur mobile
/// ou un Dialog sur tablette/desktop
Future<T?> showAdaptiveSimpleSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  double? dialogWidth,
  bool isDismissible = true,
  Color? backgroundColor,
}) {
  final isDesktopOrTablet = context.isDesktop || context.isTablet;

  if (isDesktopOrTablet) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (dialogContext) {
        final width = dialogWidth ?? (context.isDesktop ? 500.0 : 400.0);

        return Dialog(
          backgroundColor: backgroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: builder(dialogContext),
            ),
          ),
        );
      },
    );
  } else {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: builder(sheetContext),
      ),
    );
  }
}
