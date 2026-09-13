import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_wrapper.dart';

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
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthWrapper(),
      ),
    );
  }
}