import 'package:flutter/material.dart';

import '../models/incident_category.dart';
import '../theme/app_theme.dart';
import 'category_tile.dart';

/// A grid of [CategoryTile]s wrapped in a [FormField] so it joins validation.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final columns = constraints.maxWidth < 260 ? 2 : 3;
                final tileWidth =
                    (constraints.maxWidth - (columns - 1) * spacing) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final category in IncidentCategory.values)
                      SizedBox(
                        width: tileWidth,
                        child: CategoryTile(
                          category: category,
                          selected: field.value == category.key,
                          onTap: enabled
                              ? () {
                                  field.didChange(category.key);
                                  onChanged(category.key);
                                }
                              : null,
                        ),
                      ),
                  ],
                );
              },
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
