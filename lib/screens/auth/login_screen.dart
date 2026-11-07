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
                                    validator: aluEmail,
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
                                            'staff@alueducation.com',
                                            'Campus123',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _MockUserButton(
                                          label: 'Student User Mock',
                                          onTap: () => _fillCredentials(
                                            'm.victor@alustudent.com',
                                            'Campus123',
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
