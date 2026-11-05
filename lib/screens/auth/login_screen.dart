import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_footer_link.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = true);

    if (!_formKey.currentState!.validate()) {
      if (validateEmail(_emailController.text) != null) {
        _emailFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      final name = auth.currentUser?.firstName;
      showSuccessSnackBar(
        context,
        (name != null && name.isNotEmpty) ? 'Welcome back, $name!' : 'Welcome back!',
      );
    } else {
      showErrorSnackBar(
        context,
        auth.errorMessage ?? 'Something went wrong. Please try again.',
      );
    }
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _autovalidate = false;
    });
  }

  Future<void> _openForgotPassword() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ForgotPasswordSheet(),
    );
    if (sent == true && mounted) {
      showSuccessSnackBar(context, 'Reset link sent. Check your email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome back 👋',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Log in to report issues and track their resolution.',
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
                                  PasswordField(
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    validator: validateLoginPassword,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(),
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: isLoading
                                          ? null
                                          : _openForgotPassword,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.formGap),
                                  PrimaryButton(
                                    label: 'Log In',
                                    isLoading: isLoading,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthFooterLink(
                                    message: "Don't have an account?",
                                    actionText: 'Sign up',
                                    onAction: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SignupScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MockUserButton(
                                          label: 'Staff User Mock',
                                          onTap: () => _fillCredentials(
                                            'staff@gmail.com',
                                            'admin123',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _MockUserButton(
                                          label: 'Student User Mock',
                                          onTap: () => _fillCredentials(
                                            'smoketest@example.com',
                                            'smoketest123',
                                          ),
                                        ),
                                      ),
                                    ],
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

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendPasswordResetEmail(_emailController.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      showErrorSnackBar(
        context,
        auth.errorMessage ?? 'Something went wrong. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reset password',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email and we will send you a reset link.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.formGap),
            AppTextField(
              label: 'Email',
              hint: 'you@alustudent.com',
              prefixIcon: Icons.mail_outline_rounded,
              controller: _emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _send(),
              enabled: !_sending,
            ),
            const SizedBox(height: AppSpacing.formGap),
            PrimaryButton(
              label: 'Send reset link',
              isLoading: _sending,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _MockUserButton extends StatelessWidget {
  const _MockUserButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
