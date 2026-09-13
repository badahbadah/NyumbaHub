import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'hostels/hostel_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NyumbaHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      'Welcome, ${authProvider.currentUser?.fullName ?? ''}!\nRole: ${authProvider.currentUser?.role ?? ''}',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18),
    ),
    const SizedBox(height: 24),
    ElevatedButton.icon(
      icon: const Icon(Icons.apartment),
      label: const Text('Browse Hostels'),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HostelListScreen()),
        );
      },
    ),
  ],
),
    );
  }
}