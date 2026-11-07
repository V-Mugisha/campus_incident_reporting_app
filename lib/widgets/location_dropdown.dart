import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// A styled dropdown for selecting a campus location.
class LocationDropdown extends StatelessWidget {
  const LocationDropdown({
    super.key,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.initialValue,
  });

  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        hintText: 'Select a location',
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          size: 22,
          color: AppColors.textSecondary,
        ),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
      ),
      items: [
        for (final location in campusLocations)
          DropdownMenuItem(value: location, child: Text(location)),
      ],
    );
  }
}
