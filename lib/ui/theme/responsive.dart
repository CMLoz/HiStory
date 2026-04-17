/// Responsive design utilities for mobile, tablet, and web platforms.
class ResponsiveConstraints {
  // Breakpoint thresholds (width in logical pixels)
  static const double mobileMaxWidth = 600.0;
  static const double tabletMinWidth = 600.0;
  static const double tabletMaxWidth = 1200.0;
  static const double webMinWidth = 1200.0;

  /// Returns true if viewport width indicates a mobile device.
  static bool isMobile(double screenWidth) => screenWidth < tabletMinWidth;

  /// Returns true if viewport width indicates a tablet.
  static bool isTablet(double screenWidth) =>
      screenWidth >= tabletMinWidth && screenWidth < webMinWidth;

  /// Returns true if viewport width indicates a web/desktop display.
  static bool isWeb(double screenWidth) => screenWidth >= webMinWidth;

  /// Returns the current platform category based on screen width.
  static PlatformType getPlatformType(double screenWidth) {
    if (isMobile(screenWidth)) return PlatformType.mobile;
    if (isTablet(screenWidth)) return PlatformType.tablet;
    return PlatformType.web;
  }

  /// Helper to get dialogue box height based on platform.
  /// Mobile: fixed 200px. Tablet/Web: scale with viewport height.
  static double getDialogueBoxHeight(
    double screenWidth,
    double screenHeight, {
    double mobileHeight = 200.0,
    double minWebHeight = 220.0,
    double maxWebHeight = 320.0,
  }) {
    if (isMobile(screenWidth)) {
      return mobileHeight;
    }
    // For tablet/web, scale based on screen height
    // Use ~20-30% of screen height, clamped to reasonable min/max
    final scaledHeight = screenHeight * 0.25;
    return scaledHeight.clamp(minWebHeight, maxWebHeight);
  }

  /// Helper to get sprite overlay bottom offset based on platform.
  /// Mobile: fixed 168px. Web/Tablet: adjust for larger screens.
  static double getSpriteBottomOffset(double screenWidth) {
    if (isMobile(screenWidth)) {
      return 168.0;
    }
    // Web/Tablet: reduce to prevent overlap with larger dialogue box
    return 140.0;
  }

  /// Helper to get sprite width fraction based on platform.
  /// Mobile: 0.34 (larger on narrow screens). Web: 0.25-0.28 (balanced).
  static double getSpriteWidthFraction(double screenWidth) {
    if (isMobile(screenWidth)) {
      return 0.34;
    }
    // Web/Tablet: narrower to not dominate and avoid dialogue overlap
    return 0.26;
  }

  /// Helper to get character select card size based on platform.
  static CharacterSelectSize getCharacterSelectSize(double screenWidth) {
    if (isMobile(screenWidth)) {
      return CharacterSelectSize(
        spriteHeight: 150,
        spriteWidth: 140,
        buttonWidth: 100,
      );
    } else if (isTablet(screenWidth)) {
      return CharacterSelectSize(
        spriteHeight: 180,
        spriteWidth: 160,
        buttonWidth: 120,
      );
    } else {
      // Web
      return CharacterSelectSize(
        spriteHeight: 220,
        spriteWidth: 200,
        buttonWidth: 140,
      );
    }
  }

  /// Helper for character select container max-width.
  static double getCharacterSelectMaxWidth(double screenWidth) {
    if (isMobile(screenWidth)) {
      return double.infinity;
    }
    // Tablet/Web: limit width so cards don't stretch too wide
    return 1000.0;
  }
}

enum PlatformType { mobile, tablet, web }

class CharacterSelectSize {
  final double spriteHeight;
  final double spriteWidth;
  final double buttonWidth;

  CharacterSelectSize({
    required this.spriteHeight,
    required this.spriteWidth,
    required this.buttonWidth,
  });
}
