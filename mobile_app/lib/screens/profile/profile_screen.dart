import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../bookings/my_bookings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: authProvider.isLoggedIn
          ? _LoggedInView(authProvider: authProvider)
          : const _GuestView(),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('You are browsing as a guest', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Log in to message owners and agents, make bookings, or post your own listings.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Log In or Register'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  final AuthProvider authProvider;
  const _LoggedInView({required this.authProvider});

  String _roleLabel(String role) {
    switch (role) {
      case 'hostel_owner': return 'Hostel Owner';
      case 'house_hunter': return 'House Hunter';
      case 'agent': return 'Agent';
      case 'student': return 'Student';
      case 'admin': return 'Admin';
      default: return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(_roleLabel(user.role), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 28),

          if (user.role == 'student')
            _DashboardTile(
              icon: Icons.receipt_long_outlined,
              title: 'My Bookings',
              subtitle: 'View reservations and leave reviews',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                );
              },
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Expanded(child: Text('Your role dashboard is coming soon')),
                  ],
                ),
              ),
            ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => authProvider.logout(),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}