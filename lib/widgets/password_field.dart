import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_text_field.dart';

/// An [AppTextField] specialized for passwords with a visibility toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.focusNode,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: _obscure,
      prefixIcon: Icons.lock_outline_rounded,
      suffix: IconButton(
        onPressed: widget.enabled ? () => setState(() => _obscure = !_obscure) : null,
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 22,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
