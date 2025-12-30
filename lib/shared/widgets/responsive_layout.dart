import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1100) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= 650) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.isMobile(context)
            ? 16
            : ResponsiveLayout.isTablet(context)
            ? 32
            : 48,
        vertical: 16,
      ),
      child: child,
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveGrid({super.key, required this.children, this.spacing = 16});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final crossAxisCount = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: isMobile ? 4 : 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveRow({super.key, required this.children, this.spacing = 16});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: children
          .map(
            (child) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: spacing),
                child: child,
              ),
            ),
          )
          .toList(),
    );
  }
}

extension ResponsiveLayoutExtensions on BuildContext {
  bool get isLayoutMobile => ResponsiveLayout.isMobile(this);
  bool get isLayoutTablet => ResponsiveLayout.isTablet(this);
  bool get isLayoutDesktop => ResponsiveLayout.isDesktop(this);

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isLayoutDesktop) return desktop ?? tablet ?? mobile;
    if (isLayoutTablet) return tablet ?? mobile;
    return mobile;
  }
}
