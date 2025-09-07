import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.green;
  static const background = Colors.white;
  static const text = Colors.black;
  static const textSecondary = Colors.grey;
  static const error = Colors.red;
  static const messageBubbleMe = Color.fromRGBO(76, 175, 80, 0.8); // Green with opacity
  static const messageBubbleOther = Color.fromRGBO(224, 224, 224, 1.0); // Grey[300]
}

class AppTextStyles {
  static const title = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  
  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  
  static const bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
  
  static const caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontStyle: FontStyle.italic,
  );
  
  static const messageText = TextStyle(
    fontSize: 16,
  );
}

class AppDimensions {
  static const padding = EdgeInsets.all(12.0);
  static const paddingSmall = EdgeInsets.all(8.0);
  static const paddingMedium = 12.0;
  static const spacingSmall = 8.0;
  static const spacingMedium = 12.0;
  static const spacingLarge = 16.0;
  static const borderRadius = 12.0;
  static const borderRadiusSmall = 8.0;
  static const borderRadiusMedium = 12.0;
  static const borderRadiusLarge = 16.0;
  static const avatarSizeSmall = 32.0;
  static const avatarSizeMedium = 40.0;
  static const avatarSizeLarge = 48.0;
}

class AppDecorations {
  static final cardDecoration = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    boxShadow: [
      BoxShadow(
        offset: const Offset(0, 2),
        blurRadius: 4,
        color: Colors.black.withOpacity(0.1),
      ),
    ],
  );
  
  static final inputDecoration = BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
  );
}
