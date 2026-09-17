import 'package:flutter/material.dart';

class AppColors {
  // Primary branding
  static const Color primary = Color(0xFFE92E5F); // Hot pink from image
  static const Color onPrimary = Colors.white;

  // Backgrounds
  static const Color background = Color(0xFF161618); // Deep dark grey
  static const Color surface = Color(0xFF222226); // Slightly lighter dark grey

  // Text
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textLightSecondary = Color(0xFFA0A0A5);
  static const Color textDark = Color(0xFF161618);
  static const Color textDarkSecondary = Color(0xFF55555A);
  static const Color textDarkTertiary = Color(0xFF88888F);

  // Borders & Dividers
  static const Color borderLight = Color(0xFF333338);
  static const Color borderDark = Color(0xFFE92E5F);

  // Icons
  static const Color iconLight = Color(0xFFF5F5F5);
  static const Color iconDark = Color(0xFFE92E5F);
  static const Color iconDarkSecondary = Color(0xFFA0A0A5);

  // Shadows
  static const Color shadow = Colors.black;

  // Gradients
  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF161618),
      Color(0xFF0D0D0E),
    ],
  );
}
