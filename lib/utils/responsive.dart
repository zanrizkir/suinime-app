import 'package:flutter/material.dart';

/// Responsive utilities for Suinime app
class Responsive {
  Responsive._();

  /// Device breakpoints
  static const double mobileMaxWidth = 599;
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 1199;
  static const double desktopMinWidth = 1200;

  /// Check screen size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMinWidth &&
      MediaQuery.of(context).size.width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMinWidth;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Screen dimensions
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double screenHeightWithoutAppBar(BuildContext context) =>
      MediaQuery.of(context).size.height -
      AppBar().preferredSize.height -
      MediaQuery.of(context).padding.top;

  static double screenHeightWithoutBottomNav(BuildContext context) =>
      MediaQuery.of(context).size.height - kBottomNavigationBarHeight;

  /// Safe area padding
  static EdgeInsets safePadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  static EdgeInsets viewInsets(BuildContext context) =>
      MediaQuery.of(context).viewInsets;

  /// Adaptive padding
  static double paddingXSmall(BuildContext context) =>
      isMobile(context) ? 4 : 6;

  static double paddingSmall(BuildContext context) =>
      isMobile(context) ? 8 : 12;

  static double paddingMedium(BuildContext context) =>
      isMobile(context) ? 12 : 16;

  static double paddingLarge(BuildContext context) =>
      isMobile(context) ? 16 : 24;

  static double paddingXLarge(BuildContext context) =>
      isMobile(context) ? 20 : 32;

  /// Adaptive spacing
  static double spacingXSmall(BuildContext context) =>
      isMobile(context) ? 2 : 4;

  static double spacingSmall(BuildContext context) => isMobile(context) ? 4 : 6;

  static double spacingMedium(BuildContext context) =>
      isMobile(context) ? 8 : 12;

  static double spacingLarge(BuildContext context) =>
      isMobile(context) ? 12 : 16;

  static double spacingXLarge(BuildContext context) =>
      isMobile(context) ? 16 : 24;

  /// Adaptive font sizes
  /// Adaptive font sizes
  static double fontSizeXSmall(BuildContext context) =>
      isMobile(context) ? 10 : 11;

  static double fontSizeSmall(BuildContext context) =>
      isMobile(context) ? 12 : 14;

  static double fontSizeMedium(BuildContext context) =>
      isMobile(context) ? 14 : 16;

  static double fontSizeLarge(BuildContext context) =>
      isMobile(context) ? 16 : 18;

  static double fontSizeXLarge(BuildContext context) =>
      isMobile(context) ? 18 : 24;

  /// Adaptive icon sizes
  static double iconSizeSmall(BuildContext context) =>
      isMobile(context) ? 16 : 20;

  static double iconSizeMedium(BuildContext context) =>
      isMobile(context) ? 20 : 24;

  static double iconSizeLarge(BuildContext context) =>
      isMobile(context) ? 24 : 32;

  static double iconSizeXLarge(BuildContext context) =>
      isMobile(context) ? 32 : 48;

  /// Adaptive grid configurations - optimized for anime cards
  static SliverGridDelegate gridDelegateSmall(BuildContext context) {
    final width = screenWidth(context);

    // Small phones (< 360px): 2 columns
    if (width < 360) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      );
    }
    // Standard phones (360px - 599px): 3 columns
    else if (width < 600) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      );
    }
    // Tablets (600px - 1199px): 4 columns
    else if (width < 1200) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      );
    }
    // Desktop (1200px+): 5 columns
    else {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.6,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      );
    }
  }

  static SliverGridDelegate gridDelegateMedium(BuildContext context) {
    final width = screenWidth(context);

    // Small phones (< 360px): 2 columns
    if (width < 360) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      );
    }
    // Standard phones (360px - 599px): 3 columns
    else if (width < 600) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      );
    }
    // Tablets (600px - 1199px): 4 columns
    else if (width < 1200) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      );
    }
    // Desktop (1200px+): 5 columns
    else {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      );
    }
  }

  /// Adaptive container width
  static double containerWidth(BuildContext context, {double maxWidth = 1200}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > maxWidth ? maxWidth : screenWidth;
  }

  /// Adaptive max width for content
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  /// Adaptive bottom sheet height
  static double bottomSheetHeight(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * percentage;

  /// Adaptive dialog width
  static double dialogWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isMobile(context)) return width * 0.9;
    if (isTablet(context)) return width * 0.7;
    return 600;
  }

  /// Adaptive button height
  static double buttonHeight(BuildContext context) =>
      isMobile(context) ? 44 : 48;

  /// Adaptive button padding
  static EdgeInsets buttonPadding(BuildContext context) {
    final padding = paddingMedium(context);
    return EdgeInsets.symmetric(horizontal: padding * 1.5, vertical: padding);
  }

  /// Get column crossAxisAlignment based on device
  static CrossAxisAlignment adaptiveCrossAxisAlignment(BuildContext context) =>
      isMobile(context) ? CrossAxisAlignment.start : CrossAxisAlignment.center;

  /// Safe minimum touch target (48dp per Material guidelines)
  static const double minTouchTarget = 48;

  /// Responsive text scale factor
  static double textScaleFactor(BuildContext context) {
    final deviceWidth = screenWidth(context);
    if (deviceWidth < 360) return 0.8;
    if (deviceWidth < 540) return 0.9;
    if (deviceWidth > 1200) return 1.1;
    return 1.0;
  }

  /// Adaptive image height for landscape
  static double adaptiveImageHeight(BuildContext context) {
    if (isLandscape(context)) {
      return screenHeight(context) * 0.4;
    }
    return 200;
  }

  /// Number of columns for multi-column layouts - optimized for mobile
  static int adaptiveColumnCount(BuildContext context, {int minColumns = 1}) {
    final width = screenWidth(context);

    // Small phones (< 360px): 2 columns minimum
    if (width < 360) return 2;
    // Standard phones (360px - 599px): 3 columns
    if (width < 600) return 3;
    // Tablets (600px - 1199px): 4 columns
    if (width < 1200) return 4;
    // Desktop (1200px+): 4-5 columns
    return 5;
  }
}

/// Widget extensions for responsive design
extension ResponsiveWidget on Widget {
  /// Wrap with responsive max width
  Widget withResponsiveMaxWidth(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Responsive.maxContentWidth(context),
      ),
      child: this,
    ),
  );

  /// Add responsive padding
  Widget withResponsivePadding(
    BuildContext context, {
    bool horizontal = true,
    bool vertical = true,
  }) => Padding(
    padding: EdgeInsets.only(
      left: horizontal ? Responsive.paddingMedium(context) : 0,
      right: horizontal ? Responsive.paddingMedium(context) : 0,
      top: vertical ? Responsive.paddingMedium(context) : 0,
      bottom: vertical ? Responsive.paddingMedium(context) : 0,
    ),
    child: this,
  );
}

/// Box constraints helper for responsive design
class ResponsiveBox extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? minHeight;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveBox({
    super.key,
    required this.child,
    this.maxWidth,
    this.minHeight,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final width = maxWidth ?? Responsive.maxContentWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, minHeight: minHeight ?? 0),
        child: child,
      ),
    );
  }
}

/// Responsive flex widget
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
  });

  @override
  Widget build(BuildContext context) {
    // On small screens, convert to column if flex layout too complex
    final newDirection =
        Responsive.isMobile(context) && direction == Axis.horizontal
        ? Axis.vertical
        : direction;

    if (newDirection == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        children: children,
      );
    }
  }
}
