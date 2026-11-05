import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A debounced search field with a clear button.
class ReportSearchBar extends StatefulWidget {
  const ReportSearchBar({
    super.key,
    required this.onChanged,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<ReportSearchBar> createState() => _ReportSearchBarState();
}

class _ReportSearchBarState extends State<ReportSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => widget.onChanged(value),
    );
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      onChanged: _onChanged,
      onSubmitted: (v) {
        _debounce?.cancel();
        widget.onChanged(v);
      },
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Search by title, location or category',
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 22,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: _clear,
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
