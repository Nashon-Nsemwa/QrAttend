import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Primary color (main color used in the app)
  static Color get primary {
    return Theme.of(Get.context!).colorScheme.primary;
  }

  // Primary container (used for backgrounds or card-like surfaces)
  static Color get primaryContainer {
    return Theme.of(Get.context!).colorScheme.primaryContainer;
  }

  // Background color (used for overall app background)
  static Color get background {
    return Theme.of(Get.context!).colorScheme.background;
  }

  // Surface color (used for surfaces like cards, sheets)
  static Color get surface {
    return Theme.of(Get.context!).colorScheme.surface;
  }

  // Error color (used for errors or warnings)
  static Color get error {
    return Theme.of(Get.context!).colorScheme.error;
  }

  // On primary (text color that appears on primary color)
  static Color get onPrimary {
    return Theme.of(Get.context!).colorScheme.onPrimary;
  }

  // On background (text color that appears on background)
  static Color get onBackground {
    return Theme.of(Get.context!).colorScheme.onBackground;
  }

  // On surface (text color that appears on surfaces)
  static Color get onSurface {
    return Theme.of(Get.context!).colorScheme.onSurface;
  }

  // On error (text color that appears on error color)
  static Color get onError {
    return Theme.of(Get.context!).colorScheme.onError;
  }

  // Secondary color (used for accents and secondary actions)
  static Color get secondary {
    return Theme.of(Get.context!).colorScheme.secondary;
  }

  // Secondary container (used for secondary background or accent areas)
  static Color get secondaryContainer {
    return Theme.of(Get.context!).colorScheme.secondaryContainer;
  }

  // On secondary (text color that appears on secondary color)
  static Color get onSecondary {
    return Theme.of(Get.context!).colorScheme.onSecondary;
  }

  // On secondary container (text color that appears on secondary container)
  static Color get onSecondaryContainer {
    return Theme.of(Get.context!).colorScheme.onSecondaryContainer;
  }

  // Tertiary color (another accent color used for UI elements)
  static Color get tertiary {
    return Theme.of(Get.context!).colorScheme.tertiary;
  }

  // On tertiary (text color that appears on tertiary color)
  static Color get onTertiary {
    return Theme.of(Get.context!).colorScheme.onTertiary;
  }

  // Background color for elevated UI elements (e.g., AppBar)
  static Color get appBarBackground {
    return Theme.of(Get.context!).colorScheme.primary;
  }

  // Surface variant (used for variant surfaces, like card elevations)
  static Color get surfaceVariant {
    return Theme.of(Get.context!).colorScheme.surfaceVariant;
  }

  // On surface variant (text on surface variant color)
  static Color get onSurfaceVariant {
    return Theme.of(Get.context!).colorScheme.onSurfaceVariant;
  }

  // Outline color (used for borders or dividers)
  static Color get outline {
    return Theme.of(Get.context!).colorScheme.outline;
  }

  // Inverse surface (used for inverted colors, e.g., dark mode)
  static Color get inverseSurface {
    return Theme.of(Get.context!).colorScheme.inverseSurface;
  }

  // Inverse on surface (text color for inverse surfaces)
  static Color get inverseOnSurface {
    return Theme.of(Get.context!).colorScheme.inverseSurface;
  }

  // Shadow color (used for shadows in UI elements)
  static Color get shadow {
    return Theme.of(Get.context!).colorScheme.shadow;
  }
}
