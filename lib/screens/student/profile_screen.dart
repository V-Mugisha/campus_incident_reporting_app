import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/date_format.dart';
import '../../utils/snackbar.dart';
import '../../widgets/profile_info_row.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text(
          "You'll need to sign in again to report or track issues.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    final auth = context.read<AuthProvider>();
    final nav = context.read<NavigationProvider>();

    try {
      await auth.signOut();
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }

    nav.setIndex(0);
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    final name = user?.name ?? '';
    final email = user?.email ?? '';
    final roleLabel =
        user?.role == UserRole.staff ? 'Staff' : 'Student';

    final department = user?.department;
    final departmentValue = (department == null || department.trim().isEmpty)
        ? 'Not specified'
        : department.trim();
    final departmentMuted = departmentValue == 'Not specified';

    final createdAt = user?.createdAt;
    final memberSince = createdAt == null ? 'Not specified' : monthYear(createdAt);
    final memberSinceMuted = createdAt == null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: kNavBarClearance,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _HeaderCard(name: name, roleLabel: roleLabel),
            const SizedBox(height: 20),
            _AccountInfoCard(
              email: email,
              department: departmentValue,
              departmentMuted: departmentMuted,
              memberSince: memberSince,
              memberSinceMuted: memberSinceMuted,
            ),
            const SizedBox(height: 24),
            _LogoutButton(
              loading: _loggingOut,
              onTap: _confirmLogout,
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                '${AppStrings.appName} v1.0.0',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.name, required this.roleLabel});

  final String name;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          UserAvatar(name: name, size: 88, ring: true),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({
    required this.email,
    required this.department,
    required this.departmentMuted,
    required this.memberSince,
    required this.memberSinceMuted,
  });

  final String email;
  final String department;
  final bool departmentMuted;
  final String memberSince;
  final bool memberSinceMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ProfileInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          const Divider(height: 1, color: AppColors.border),
          ProfileInfoRow(
            icon: Icons.school_outlined,
            label: 'Department',
            value: department,
            valueMuted: departmentMuted,
          ),
          const Divider(height: 1, color: AppColors.border),
          ProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member since',
            value: memberSince,
            valueMuted: memberSinceMuted,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
