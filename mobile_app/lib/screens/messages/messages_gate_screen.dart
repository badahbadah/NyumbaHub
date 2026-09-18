import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_gate.dart';
import 'conversations_list_screen.dart';

class MessagesGateScreen extends StatefulWidget {
  const MessagesGateScreen({super.key});

  @override
  State<MessagesGateScreen> createState() => _MessagesGateScreenState();
}

class _MessagesGateScreenState extends State<MessagesGateScreen> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: isLoggedIn
          ? const ConversationsListScreen()
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 44, color: AppColors.textSecondary),
                    const SizedBox(height: 14),
                    const Text('Log in to view and send messages', textAlign: TextAlign.center),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await requireAuth(context);
                        if (ok) setState(() {});
                      },
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}