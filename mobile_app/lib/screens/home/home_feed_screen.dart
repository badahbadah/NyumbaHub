import 'package:flutter/material.dart';
import 'hostels_tab.dart';
import 'properties_tab.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NyumbaHub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hostels'),
              Tab(text: 'Real Estate'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HostelsTab(),
            PropertiesTab(),
          ],
        ),
      ),
    );
  }
}