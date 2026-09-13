import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NyumbaHubApp());
}

class NyumbaHubApp extends StatelessWidget {
  const NyumbaHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'NyumbaHub',
        theme: AppTheme.light(),
        home: const RootShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}