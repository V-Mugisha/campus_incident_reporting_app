import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A circular initials avatar. Optionally adds a primary ring + white gap.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.ring = false,
    this.onTap,
  });

  final String name;
  final double size;
  final bool ring;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);

    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: Colors.white, width: 3) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (ring) {
      circle = Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: circle,
      );
    }

    if (onTap == null) return circle;
    return GestureDetector(onTap: onTap, child: circle);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';
    final letters = (first.isNotEmpty ? first[0] : '') +
        (last.isNotEmpty ? last[0] : '');
    return letters.toUpperCase();
  }
}
