import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A shimmering placeholder card shown while the report list loads.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradientTransform(_controller.value),
            ).createShader(bounds),
            child: Row(
              children: [
                _box(56, 56, 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(double.infinity, 14, 6),
                      const SizedBox(height: 8),
                      _box(120, 12, 6),
                      const SizedBox(height: 8),
                      _box(80, 12, 6),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _box(64, 24, 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _box(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (2 * progress - 1), 0, 0);
  }
}
