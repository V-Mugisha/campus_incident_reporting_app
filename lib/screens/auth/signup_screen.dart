import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _autovalidate = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = true);

    if (!_formKey.currentState!.validate()) {
      if (validateName(_nameController.text) != null) {
        _nameFocus.requestFocus();
      } else if (validateEmail(_emailController.text) != null) {
        _emailFocus.requestFocus();
      } else if (validatePassword(_passwordController.text) != null) {
        _passwordFocus.requestFocus();
      } else {
        _confirmFocus.requestFocus();
      }
      return;
    }

    final department = _departmentController.text.trim();
    final auth = context.read<AuthProvider>();
    final ok = await auth.registerStudent(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      department: department.isEmpty ? null : department,
    );
    if (!mounted) return;
    if (ok) {
      showSuccessSnackBar(
        context,
        'Welcome to CampusCare, ${_nameController.text.trim()}!',
      );
    } else {
      showErrorSnackBar(
        context,
        auth.errorMessage ?? 'Something went wrong. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Join your campus community',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign up as a student to report issues and follow their progress.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.headerGap),
                        FadeTransition(
                          opacity: _curve,
                          child: SlideTransition(
                            position: _slide,
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autovalidate
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppTextField(
                                    label: 'Full name',
                                    hint: 'e.g. Amina Hassan',
                                    prefixIcon: Icons.person_outline_rounded,
                                    controller: _nameController,
                                    focusNode: _nameFocus,
                                    validator: validateName,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  AppTextField(
                                    label: 'Email',
                                    hint: 'you@alustudent.com',
                                    prefixIcon: Icons.mail_outline_rounded,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    validator: validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  AppTextField(
                                    label: 'Department / Program',
                                    labelSuffix: '(optional)',
                                    hint: 'e.g. Computer Science',
                                    prefixIcon: Icons.school_outlined,
                                    controller: _departmentController,
                                    textInputAction: TextInputAction.next,
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  PasswordField(
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    helperText:
                                        'At least 8 characters, with a letter and a number.',
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    validator: validatePassword,
                                    textInputAction: TextInputAction.next,
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  PasswordField(
                                    label: 'Confirm password',
                                    hint: 'Re-enter your password',
                                    controller: _confirmController,
                                    focusNode: _confirmFocus,
                                    validator: (v) => validateConfirmPassword(
                                      v,
                                      _passwordController.text,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(),
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'New accounts are student accounts. '
                                            'Staff accounts are set up by campus '
                                            'administration.',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  PrimaryButton(
                                    label: 'Create Account',
                                    isLoading: isLoading,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthFooterLink(
                                    message: 'Already have an account?',
                                    actionText: 'Log in',
                                    onAction: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
