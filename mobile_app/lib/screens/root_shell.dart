import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home/home_feed_screen.dart';
import 'messages/messages_gate_screen.dart';
import 'profile/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _screens = const [HomeFeedScreen(), MessagesGateScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuthProvider>().checkAuthStatus());
  }

  void _onTap(int i) {
    setState(() => _index = i);
    context.read<AuthProvider>().refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AuthProvider>().unreadMessageCount;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: unread > 0
                ? Badge(label: Text('$unread'), child: const Icon(Icons.chat_bubble_outline))
                : const Icon(Icons.chat_bubble_outline),
            activeIcon: unread > 0
                ? Badge(label: Text('$unread'), child: const Icon(Icons.chat_bubble))
                : const Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}