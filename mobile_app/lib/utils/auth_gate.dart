import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

/// Call this before any action that requires being logged in
/// (messaging, booking, posting a listing). If the user is a guest,
/// it opens Login and returns true only if they successfully log in —
/// so the calling code can continue exactly where it left off.
Future<bool> requireAuth(BuildContext context, {String? reason}) async {
  final authProvider = context.read<AuthProvider>();
  if (authProvider.isLoggedIn) return true;

  if (reason != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
  }

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return result ?? false;
}