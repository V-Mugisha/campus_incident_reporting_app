import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showErrorSnackBar(BuildContext context, String message) {
  _show(context, message, AppColors.error, Icons.error_outline_rounded);
}

void showSuccessSnackBar(BuildContext context, String message) {
  _show(context, message, AppColors.successText, Icons.check_circle_outline_rounded);
}

void _show(BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
